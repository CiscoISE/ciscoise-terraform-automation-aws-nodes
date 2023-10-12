import json
import logging
import threading
import time
import requests
import boto3
import sys
import os
import socket
import urllib3
urllib3.disable_warnings()

logging.basicConfig(stream = sys.stdout)
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_ssm_parameter(ssm_client, ssm_parameter_name,WithDecryption=False):
    param_value = ssm_client.get_parameter(
    Name=ssm_parameter_name,
    WithDecryption=WithDecryption
)

    return param_value.get('Parameter').get('Value')
def set_ssm_parameter(ssm_client, ssm_parameter_name, value, Overwrite=True, Type="String"):
    response = ssm_client.put_parameter(
    Name=ssm_parameter_name,
    Value=value,
    Overwrite=True,
    Type=Type
)

    return response

def timeout(event, context):
    logging.error('Execution is about to time out, sending failure response to CloudFormation')
    requests_data=json.dumps(data=dict(Status='FAILURE',Reason='Lambda timeout',UniqueId='ISENodeStates',Data='failed due to timeout')).encode('utf-8')
    response = requests.put(event['ResourceProperties']['WaitHandle'], data=requests_data, headers={'Content-Type':''})
    sys.exit(1)

def handler(event, context):
    runtime_region = os.environ['AWS_REGION']
    ssm_client = boto3.client('ssm',region_name=runtime_region)
    timer = threading.Timer((context.get_remaining_time_in_millis() / 1000.00) - 0.5, timeout, args=[event, context])
    try:
        retries = 10 #Polling rate to restrict Step functions looping
        if "taskresult" in event:
            retries = int(event['taskresult']['retries'])
        else:
            PPAN_fqdn = get_ssm_parameter(ssm_client,"Primary_FQDN")
            SPAN_fqdn = get_ssm_parameter(ssm_client,"Secondary_FQDN")
            ADMIN_USERNAME = get_ssm_parameter(ssm_client,"ADMIN_USERNAME")
            ADMIN_PASSWORD = get_ssm_parameter(ssm_client,"ADMIN_PASSWORD")


        logger.info("#Retriving SSM parameters...")
        Primary_IP = get_ssm_parameter(ssm_client,"Primary_IP")
        Secondary_IP = get_ssm_parameter(ssm_client,"Secondary_IP")
        ADMIN_USERNAME = get_ssm_parameter(ssm_client,"ADMIN_USERNAME")
        ADMIN_PASSWORD = get_ssm_parameter(ssm_client,"ADMIN_PASSWORD",WithDecryption=True)
        API_AUTH = (ADMIN_USERNAME, ADMIN_PASSWORD)
        API_HEADER = {'Content-Type': 'application/json', 'Accept': 'application/json'}
        Secondary_FQDN = get_ssm_parameter(ssm_client,"Secondary_FQDN")

        logger.info("Primmary Polcy Administration node ip : {}".format(Primary_IP))
        logger.info("Secondary Polcy Administration node ip : {}".format(Secondary_IP))
        logger.info("ADMIN_USERNAME : {}".format(ADMIN_USERNAME))
        logger.info("API_HEADER : {}".format(API_HEADER))
        logger.info("Secondary Polcy Administration node fqdn : {}".format(Secondary_FQDN))
        data = {}
        nodes_to_check = [Primary_IP, Secondary_IP]
        nodes_list = [Primary_IP, Secondary_IP]
        num_psn_nodes = len([param for param in ssm_client.describe_parameters(ParameterFilters=[{'Key': 'Name', 'Values': ['PSN_ISE_SERVER_*_IP']}])['Parameters']])
        for ip in nodes_to_check:
            url = 'https://{}/api/v1/deployment/node'.format(ip)
            try:
                resp = requests.get(url, headers=API_HEADER, auth=API_AUTH, data=json.dumps(data), verify=False)
                logger.info("API response for {} is {} ".format(ip, resp.text))
                if resp.status_code == 200:
                    nodes_list.remove(ip)
                    logger.info("ISE - {} is up and running".format(ip))
            except Exception as e:
                logging.error('Exception: %s' % e, exc_info=True)
                logger.error("Exception occured while executing get node details api for {}".format(ip))
                retries -= 1
                return {
                        "IseState": "pending",
                        "retries": str(retries)
                        }
            
         # Check the health of PSN nodes
        psn_nodes_to_check = [get_ssm_parameter(ssm_client, "PSN_ISE_SERVER_{}_IP".format(i + 1)) for i in range(num_psn_nodes)]
        for psn_ip in psn_nodes_to_check:
            url = 'https://{}/api/v1/health'.format(psn_ip)
            try:
                resp = requests.get(url, headers=API_HEADER, auth=API_AUTH, data=json.dumps(data), verify=False)
                logger.info("Health check response for PSN node {} is {} ".format(psn_ip, resp.text))
                if resp.status_code != 200:
                    logger.error("PSN node - {} is not healthy".format(psn_ip))
                    retries -= 1
                    return {
                        "IseState": "unhealthy",
                        "retries": str(retries)
                    }
            except Exception as e:
                logging.error('Exception: %s' % e, exc_info=True)
                logger.error("Exception occurred while executing health check for PSN node {}".format(psn_ip))
                retries -= 1
                return {
                    "IseState": "pending",
                    "retries": str(retries)
                }
        if nodes_list:
            timer.cancel()
            retries -= 1
            return {
                    "IseState": "pending",
                    "retries": str(retries)
                    }
        else:
            timer.cancel()
            return {
                    "IseState": "running",
                    "retries": "0"
                    }

    except Exception as e:
        logging.error('Exception: %s' % e, exc_info=True)
