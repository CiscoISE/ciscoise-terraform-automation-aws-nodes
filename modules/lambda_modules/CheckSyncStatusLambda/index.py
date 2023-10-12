import json
import logging
import threading
import time
import requests
import boto3
import sys
import os
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
    return param_value.get('Parameter').get('Value')

def set_ssm_parameter(ssm_client, ssm_parameter_name, value, Overwrite=True, Type="String"):
    response = ssm_client.put_parameter(
        Name=ssm_parameter_name,
        Value=value,
        Overwrite=Overwrite,
        Type=Type
    )
    return response

def check_node_sync_status(primary_ip, admin_username, admin_password):
    API_AUTH = (admin_username, admin_password)
    API_HEADER = {'Content-Type': 'application/json', 'Accept': 'application/json'}
    data = {}

    url = 'https://{}/api/v1/deployment/node'.format(primary_ip)
    
    try:
        resp = requests.get(url, headers=API_HEADER, auth=API_AUTH, data=json.dumps(data), verify=False)
        logger.info("API response for checking node sync status and roles is: {} ".format(resp.text))
   
        if resp.status_code == 200:
            json_resp = json.loads(resp.content.decode("utf-8"))
            connected_node = 0
            for node in json_resp["response"]:
                if node['nodeStatus'] == "Connected":
                    logger.info("SyncStatus success for: '%s'", node["hostname"])
                    connected_node += 1
                elif node['nodeStatus'] == "RegistrationFailed":
                    logger.info("Sync failed for: '%s'", node["hostname"])
                    return "SYNC_FAILED"
                else:
                    time.sleep(180)
                    status = check_node_sync_status(primary_ip, admin_username, admin_password)
                    return status
                if connected_node == len(json_resp["response"]):
                    return "SYNC_COMPLETED"

    except Exception as e:
        logging.error('Exception: %s' % e, exc_info=True)
        logger.info("Exception occurred while executing get node details API for {}".format(primary_ip))
        return "SYNC_INPROGRESS"



def handler(event, context):
    runtime_region = os.environ['AWS_REGION']
    ssm_client = boto3.client('ssm', region_name=runtime_region)

    try:
        logger.info("#Retrieving SSM parameters...")
        admin_username = get_ssm_parameter(ssm_client, "ADMIN_USERNAME")
        admin_password = get_ssm_parameter(ssm_client, "ADMIN_PASSWORD", WithDecryption=True)
        primary_ip = get_ssm_parameter(ssm_client, "Primary_IP")

        # Check synchronization status for primary node
        status = check_node_sync_status(primary_ip, admin_username, admin_password)
        logger.info(status)
        set_ssm_parameter(ssm_client, "SyncStatus", status)


    except Exception as e:
        logging.error('Exception: %s' % e, exc_info=True)
        raise Exception("Sync still in progress")  