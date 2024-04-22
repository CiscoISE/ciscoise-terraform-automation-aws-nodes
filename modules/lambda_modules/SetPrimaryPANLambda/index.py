#       Name: SetPrimaryPANLambda
#       Description: Promotes ISENode01 to Primary Administration Node

import json
import logging
import requests
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


def handler(event, context):
    runtime_region = os.environ['AWS_REGION']
    ssm_client = boto3.client('ssm',region_name=runtime_region)
    logger.info("#Retriving SSM parameters...")
    Primary_IP = get_ssm_parameter(ssm_client,"Primary_IP")
    ADMIN_USERNAME = get_ssm_parameter(ssm_client,"ADMIN_USERNAME")
    ADMIN_PASSWORD = get_ssm_parameter(ssm_client,"ADMIN_PASSWORD",WithDecryption=True)
    API_AUTH = (ADMIN_USERNAME, ADMIN_PASSWORD)
    API_HEADER = {'Content-Type': 'application/json', 'Accept': 'application/json'}

    logger.info("Primmary Polcy Administration node ip : {}".format(Primary_IP))
    logger.info("ADMIN_USERNAME : {}".format(ADMIN_USERNAME))
    logger.info("API_HEADER : {}".format(API_HEADER))

    try:
        url = 'https://{}/api/v1/deployment/primary'.format(Primary_IP)
        data = {}
        resp = requests.post(url, headers=API_HEADER, auth=API_AUTH, data=json.dumps(data), verify=False)

        logger.info("API Response is : {}".format(resp))
        if resp.status_code == 200:
            logger.info("##### Standalone to Primary Successful on {} #####".format(Primary_IP))
            return {
                    "task_status": "Done"
                    }
        raise PromoteToPrimaryFailed({"Setting ISE Node to Primary Failed"})

    except Exception as e:
        logging.error('Exception: %s' % e, exc_info=True)
