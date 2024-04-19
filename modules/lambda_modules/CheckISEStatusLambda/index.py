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

logging.basicConfig(stream=sys.stdout)
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_ssm_parameter(ssm_client, ssm_parameter_name, WithDecryption=False):
    param_value = ssm_client.get_parameter(
        Name=ssm_parameter_name,
        WithDecryption=WithDecryption
    )
    value = param_value.get('Parameter').get('Value')
    logger.info(f"Retrieved SSM parameter {ssm_parameter_name}: {value}")
    return value

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
    requests_data = json.dumps(data=dict(Status='FAILURE', Reason='Lambda timeout', UniqueId='ISENodeStates', Data='failed due to timeout')).encode('utf-8')
    response = requests.put(event['ResourceProperties']['WaitHandle'], data=requests_data, headers={'Content-Type': ''})
    
def get_and_increment_retry_count(ssm_client):
    try:
        # Retrieve the current retry count
        param_name = "RETRY_COUNT"  # Replace with your SSM parameter name
        response = ssm_client.get_parameter(Name=param_name, WithDecryption=False)
        current_retry_count = int(response['Parameter']['Value'])

        # Increment the retry count
        current_retry_count += 1

        # Update the SSM Parameter with the new retry count
        set_ssm_parameter(ssm_client, param_name, str(current_retry_count))
        # ssm_client.put_parameter(
        #     Name=param_name,
        #     Value=str(current_retry_count),
        #     Overwrite=True,
        #     Type="String"
        # )

        return current_retry_count
    except Exception as e:
        logger.error(f"Error while getting/incrementing retry count from SSM: {e}")
        return 0  # In case of an error, start with 0

def get_psn_parameters(ssm_client, config_type, psn_token=None, ssm_parameter_name=None, psn_enable_ip=False):
    try:
        psn_parameters = []
        while True:
            # Fetch PSN parameters
            if psn_token:
                response = ssm_client.describe_parameters(
                    ParameterFilters=[{"Key": "tag:type", "Values": [config_type]}],
                    MaxResults=50,
                    NextToken=psn_token
                    )
            else:
                response = ssm_client.describe_parameters(
                    ParameterFilters=[{"Key": "tag:type", "Values": [config_type]}],
                    MaxResults=50
                    )
                
            logger.info(f"PSN response: {response}")
            psn_parameters.extend(response['Parameters'])
            psn_token = response.get('NextToken')
            logger.info(f'PSN Config parameters fetched from SSM : {psn_parameters}')

            if not psn_token:
            # If no NextToken, we've retrieved all results
                break

        psn_config = {param['Name']: get_ssm_parameter(ssm_client, param['Name']) for param in psn_parameters}
        logger.info(f"PSN Data List: {psn_config}")

        if psn_enable_ip:
            return psn_config
        else:
            logger.info(f"PSN Config Details: {psn_config.values()}")
            set_ssm_parameter(ssm_client, ssm_parameter_name, value=json.dumps(psn_config), Type="String")
    except Exception as e:
        logger.info("Exception occur in getting PSN parameters")
        logger.error('Exception: %s' % e, exc_info=True)

def handler(event, context):
    runtime_region = os.environ['AWS_REGION']
    ssm_client = boto3.client('ssm', region_name=runtime_region)
    timer = threading.Timer((context.get_remaining_time_in_millis() / 1000.00) - 0.5, timeout, args=[event, context])

    try:
        retries = 10  # Polling rate to restrict Step functions looping
        if "taskresult" in event:
            retries = int(event['taskresult']['retries'])
        else:
            # PPAN_fqdn = get_ssm_parameter(ssm_client, "Primary_FQDN")
            # SPAN_fqdn = get_ssm_parameter(ssm_client, "Secondary_FQDN")
            ADMIN_USERNAME = get_ssm_parameter(ssm_client, "ADMIN_USERNAME")
            ADMIN_PASSWORD = get_ssm_parameter(ssm_client, "ADMIN_PASSWORD")

        logger.info("#Retrieving SSM parameters...")
        Primary_IP = get_ssm_parameter(ssm_client, "Primary_IP")
        Secondary_IP = get_ssm_parameter(ssm_client, "Secondary_IP")
        ADMIN_USERNAME = get_ssm_parameter(ssm_client, "ADMIN_USERNAME")
        ADMIN_PASSWORD = get_ssm_parameter(ssm_client, "ADMIN_PASSWORD", WithDecryption=True)
        API_AUTH = (ADMIN_USERNAME, ADMIN_PASSWORD)
        API_HEADER = {'Content-Type': 'application/json', 'Accept': 'application/json'}
        Secondary_FQDN = get_ssm_parameter(ssm_client, "Secondary_FQDN")

        logger.info("Primary Policy Administration node IP: {}".format(Primary_IP))
        logger.info("Secondary Policy Administration node IP: {}".format(Secondary_IP))
        logger.info("ADMIN_USERNAME: {}".format(ADMIN_USERNAME))
        logger.info("API_HEADER: {}".format(API_HEADER))
        logger.info("Secondary Policy Administration node FQDN: {}".format(Secondary_FQDN))
        data = {}
        nodes_to_check = [Primary_IP, Secondary_IP]
        # Getting PSN values using function

        psn_ip_parameters = ssm_client.describe_parameters(
                    ParameterFilters=[{"Key": "tag:type", "Values": ["psn_ip"]}],
                    MaxResults=1
                    )['Parameters']
        if len(psn_ip_parameters) != 0:
            logger.info('PSN node found')
            get_psn_parameters(ssm_client, config_type="psn_roles", psn_token=None, ssm_parameter_name="psn_roles_list")
            get_psn_parameters(ssm_client, config_type="psn_services", psn_token=None, ssm_parameter_name="psn_services_list")
            get_psn_parameters(ssm_client, config_type="psn_fqdn", psn_token=None, ssm_parameter_name="psn_fqdn_list")
            
            # Get all PSN IPs for check status
            psn_ips = get_psn_parameters(ssm_client, config_type="psn_ip", psn_token=None, psn_enable_ip=True)
            logger.info(f"PSN IPS Final List: {psn_ips}")
            for ip_value in psn_ips.values():
                nodes_to_check.append(ip_value)

        logger.info("Nodes to check: {}".format(nodes_to_check))
        nodes_list = list(nodes_to_check)

        for ip in nodes_to_check:
            url = 'https://{}/api/v1/deployment/node'.format(ip)
            logger.info("Checking node: {}".format(ip))
            try:
                resp = requests.get(url, headers=API_HEADER, auth=API_AUTH, data=json.dumps(data), verify=False)
                if resp.status_code == 200:
                    nodes_list.remove(ip)
                    logger.info("ISE - {} is up and running".format(ip))
            except Exception as e:
                logger.error('Exception: %s' % e, exc_info=True)
                logger.error("Exception occurred while executing get node details API for {}".format(ip))
                retries -= 1
                current_retry_count = get_and_increment_retry_count(ssm_client)
                return {
                    "IseState": "pending",
                    "retries": str(current_retry_count)
                }
        
        if nodes_list:
            timer.cancel()
            retries -= 1
            current_retry_count = get_and_increment_retry_count(ssm_client)
            return {
                "IseState": "pending",
                "retries": str(current_retry_count)
            }
        else:
            timer.cancel()
            ssm_client.put_parameter(
                Name="RETRY_COUNT",
                Value="0",
                Overwrite=True,
                Type="String"
            )
            return {
                "IseState": "running",
                "retries": "0"
            }
    except Exception as e:
        logger.error('Exception: %s' % e, exc_info=True)