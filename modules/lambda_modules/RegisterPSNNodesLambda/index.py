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

class RegisterPSNNodeFailed(Exception):
    """Raised when PSN node registration fails"""
    pass

def get_ssm_parameter(ssm_client, ssm_parameter_name, WithDecryption=False):
    try:
        param_value = ssm_client.get_parameter(
            Name=ssm_parameter_name,
            WithDecryption=WithDecryption
        )
        return param_value.get('Parameter').get('Value')
    except ssm_client.exceptions.ParameterNotFound:
        return None

def timeout(event, context):
    logging.error('Execution is about to time out, sending failure response to CloudFormation')
    requests_data = json.dumps(data=dict(Status='FAILURE', Reason='Lambda timeout', UniqueId='ISENodeStates', Data='failed due to timeout')).encode('utf-8')
    response = requests.put(event['ResourceProperties']['WaitHandle'], data=requests_data, headers={'Content-Type': ''})
    sys.exit(1)

def handler(event, context):
    runtime_region = os.environ['AWS_REGION']
    ssm_client = boto3.client('ssm', region_name=runtime_region)
    timer = threading.Timer((context.get_remaining_time_in_millis() / 1000.00) - 0.5, timeout, args=[event, context])

    try:
        retries = 10  # Polling rate to restrict Step functions looping
        counter = 1
        psn_nodes = []

        while True:
            psn_ip_param_name = "PSN_ISE_SERVER_" + str(counter) + "_IP"
            psn_fqdn_param_name = "PSN_ISE_SERVER_" + str(counter) + "_FQDN"
           
            
            psn_ip = get_ssm_parameter(ssm_client, psn_ip_param_name)
            psn_fqdn = get_ssm_parameter(ssm_client, psn_fqdn_param_name)

            if psn_ip is None or psn_fqdn is None:
                break

            psn_nodes.append({'ip': psn_ip, 'fqdn': psn_fqdn})
            counter += 1

        logger.info("Found {} PSN nodes to register".format(len(psn_nodes)))

        # Retrieve other necessary SSM parameters
        primary_ip = get_ssm_parameter(ssm_client, "Primary_IP")
        admin_username = get_ssm_parameter(ssm_client, "ADMIN_USERNAME")
        admin_password = get_ssm_parameter(ssm_client, "ADMIN_PASSWORD", WithDecryption=True)

        api_auth = (admin_username, admin_password)
        api_header = {'Content-Type': 'application/json', 'Accept': 'application/json'}

        for psn_node in psn_nodes:
            url = 'https://{}/api/v1/deployment/node'.format(primary_ip)
            data = {
                "allowCertImport": True,
                "fqdn": psn_node['fqdn'],
                "userName": admin_username,
                "password": admin_password,
                "services": ["Session", "Profiler"]
            }

            try:
                resp = requests.post(url, headers=api_header, auth=api_auth, data=json.dumps(data), verify=False)
                logger.info("Response psn nodes",resp)
                if resp.status_code == 200:
                    logger.info("Registered PSN node {} successfully".format(psn_node['fqdn']))
                else:
                    raise RegisterPSNNodeFailed("Failed to register PSN node {}".format(psn_node['fqdn']))
            except Exception as e:
                logging.error('Exception: %s' % e, exc_info=True)
                raise RegisterPSNNodeFailed("Exception occurred while registering PSN node {}".format(psn_node['fqdn']))

        timer.cancel()
        return {"Status": "SUCCESS"}

    except RegisterPSNNodeFailed as e:
        logging.error('Registration failed: %s' % e)
        timer.cancel()
        sys.exit(1)

    except Exception as e:
        logging.error('Exception: %s' % e, exc_info=True)

