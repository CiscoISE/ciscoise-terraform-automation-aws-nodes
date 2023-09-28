#       Name: SetPrimaryPANLambda
#       Description: Promotes ISENode01 to Primary Administration Node

import json
import logging
import threading
import time
import requests
# from botocore.vendored import requests
import boto3
import sys
import os
import urllib3
urllib3.disable_warnings()


logging.basicConfig(stream = sys.stdout)
logger = logging.getLogger()
logger.setLevel(logging.INFO)

class PromoteToPrimaryFailed(Exception):
    """Raised when the Set Primary PAN Lambda is failed"""
    pass


def get_ssm_parameter(ssm_client, ssm_parameter_name,WithDecryption=False):
        param_value = ssm_client.get_parameter(
        Name=ssm_parameter_name,
        WithDecryption=WithDecryption
    )

        return param_value.get('Parameter').get('Value')

def timeout(event, context):
        logging.error('Lambda timeout')
        sys.exit(1)


def handler(event, context):
    runtime_region = os.environ['AWS_REGION']
    ssm_client = boto3.client('ssm',region_name=runtime_region)
    timer = threading.Timer((context.get_remaining_time_in_millis() / 1000.00) - 0.5, timeout, args=[event, context])
    logger.info("#Retriving SSM parameters...")
    Primary_IP = get_ssm_parameter(ssm_client,"Primary_IP")
    # Secondary_IP = get_ssm_parameter(ssm_client,"Secondary_IP")
    ADMIN_USERNAME = get_ssm_parameter(ssm_client,"ADMIN_USERNAME")
    ADMIN_PASSWORD = get_ssm_parameter(ssm_client,"ADMIN_PASSWORD",WithDecryption=True)
    API_AUTH = (ADMIN_USERNAME, ADMIN_PASSWORD)
    API_HEADER = {'Content-Type': 'application/json', 'Accept': 'application/json'}

    logger.info("Primmary Polcy Administration node ip : {}".format(Primary_IP))
    # logger.info("Secondary Polcy Administration node ip : {}".format(Secondary_IP))
    logger.info("ADMIN_USERNAME : {}".format(ADMIN_USERNAME))
    #logger.info("API_AUTH : {}".format(API_AUTH))
    logger.info("API_HEADER : {}".format(API_HEADER))

    try:
        url = 'https://{}/api/v1/deployment/primary'.format(Primary_IP)
        data = {}
        resp = requests.post(url, headers=API_HEADER, auth=API_AUTH, data=json.dumps(data), verify=False)

        logger.info("API Response is : {}".format(resp))
        if resp.status_code == 200:
            logger.info("##### Standalone to Primary Successful on {} #####".format(Primary_IP))
            timer.cancel()
            return {
                    "task_status": "Done"
                    }
        raise PromoteToPrimaryFailed({"Setting ISE Node to Primary Failed"})

    except Exception as e:
        # requests_data=json.dumps(dict(Status='FAILURE',Reason='Setting ISE Node to Primary Failed',UniqueId='ISENodeStates',Data='exception')).encode('utf-8')
        # response = requests.put(event['ResourceProperties']['WaitHandle'], data=requests_data, headers={'Content-Type':''})
        # logger.info(response)
        logging.error('Exception: %s' % e, exc_info=True)
        timer.cancel()
