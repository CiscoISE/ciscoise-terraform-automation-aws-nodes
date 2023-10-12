#       Name: RegisterSecondaryNodeLambda
#       Description: Registers ISENode02 to Primary Administration Node ISENode01

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


logging.basicConfig(stream = sys.stdout)
logger = logging.getLogger()
logger.setLevel(logging.INFO)

class RegisterSecondaryNodeFailed(Exception):
    """Raised when the Set Primary PAN Lambda is failed"""
    pass


def get_ssm_parameter(ssm_client, ssm_parameter_name,WithDecryption=False):
        param_value = ssm_client.get_parameter(
        Name=ssm_parameter_name,
        WithDecryption=WithDecryption
    )

        return param_value.get('Parameter').get('Value')

def timeout():
        logging.error('Lambda timeout RegisterSecondaryNodeLambda failed')
        sys.exit(1)

def handler(event, context):
    runtime_region = os.environ['AWS_REGION']
    ssm_client = boto3.client('ssm',region_name=runtime_region)
    timer = threading.Timer((context.get_remaining_time_in_millis() / 1000.00) - 0.5, timeout)
    logger.info("#Retriving SSM parameters...")
    Primary_IP = get_ssm_parameter(ssm_client,"Primary_IP")
    Secondary_IP = get_ssm_parameter(ssm_client,"Secondary_IP")
    Secondary_FQDN = get_ssm_parameter(ssm_client,"Secondary_FQDN")
    ADMIN_USERNAME = get_ssm_parameter(ssm_client,"ADMIN_USERNAME")
    ADMIN_PASSWORD = get_ssm_parameter(ssm_client,"ADMIN_PASSWORD",WithDecryption=True)
    API_AUTH = (ADMIN_USERNAME, ADMIN_PASSWORD)
    API_HEADER = {'Content-Type': 'application/json', 'Accept': 'application/json'}

    logger.info("Primmary Polcy Administration node ip : {}".format(Primary_IP))
    logger.info("Secondary Polcy Administration node ip : {}".format(Secondary_IP))
    logger.info("ADMIN_USERNAME : {}".format(ADMIN_USERNAME))
    logger.info("API_HEADER : {}".format(API_HEADER))
    logger.info("# Register Secondary node to deployment - start...")
    try:
        roles_enabled = ["SecondaryAdmin","SecondaryMonitoring"]
        service_enabled = ["Session", "Profiler", "pxGrid"]

        url = 'https://{}/api/v1/deployment/node'.format(Primary_IP)
        data = {"allowCertImport": True,
                "fqdn": Secondary_FQDN,
                "userName": ADMIN_USERNAME,
                "password": ADMIN_PASSWORD,
                "roles": roles_enabled,
                "services": service_enabled,
                }
        logger.info('Url: {}, Data: {}'.format(url, data))

        resp = requests.post(url, headers=API_HEADER, auth=API_AUTH, data=json.dumps(data), verify=False)
        logger.info('Register secondary response: {}, {}'.format(resp.status_code, resp.text))
        if resp.status_code == 200:
            logger.info("Register Secondary node is successfull, API response is {}".format(resp.text))
            timer.cancel()
            return {
                    "task_status": "Done"
                    }
        raise RegisterSecondaryNodeFailed({"Register Secondary node to form deployment Failed"})


    except RegisterSecondaryNodeFailed:
        requests_data=json.dumps(dict(Status='FAILURE',Reason='Secondary Node Registration Failed',UniqueId='ISENodeStates',Data='exception')).encode('utf-8')
        logging.error('Exception: %s', exc_info=True)


    except Exception as e:
        requests_data=json.dumps(dict(Status='FAILURE',Reason='Secondary Node Registration Failed',UniqueId='ISENodeStates',Data='exception')).encode('utf-8')
        timer.cancel()
        logging.error('Exception: %s' % e, exc_info=True)