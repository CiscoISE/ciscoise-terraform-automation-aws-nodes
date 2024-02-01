import json
import logging
import threading
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
        while True:
            psn_ip_parameters = ssm_client.describe_parameters(ParameterFilters=[{"Key": "tag:type", "Values": ["psn_ip"]}])['Parameters']
            if len(psn_ip_parameters) == 0:
                sys.exit('No PSN node found')
            psn_ips = {param['Name']: get_ssm_parameter(ssm_client, param['Name']) for param in psn_ip_parameters}
            psn_roles_parameters = ssm_client.describe_parameters(ParameterFilters=[{"Key": "tag:type", "Values": ["psn_roles"]}])['Parameters']
            psn_services_parameters = ssm_client.describe_parameters(ParameterFilters=[{"Key": "tag:type", "Values": ["psn_services"]}])['Parameters']

            psn_roles = {param['Name']: get_ssm_parameter(ssm_client, param['Name']) for param in psn_roles_parameters}
            psn_services = {param['Name']: get_ssm_parameter(ssm_client, param['Name']) for param in psn_services_parameters}
            logger.info(f"PSN Roles: {psn_roles}")
            logger.info(f"PSN Services: {psn_services}")
            logger.info(f"PSN IPs: {psn_ips}")

            # Fetch FQDN parameters
            psn_fqdn_parameters = ssm_client.describe_parameters(ParameterFilters=[{"Key": "tag:type", "Values": ["psn_fqdn"]}])['Parameters']
            psn_fqdn = {param['Name']: get_ssm_parameter(ssm_client, param['Name']) for param in psn_fqdn_parameters}

            logger.info(f"PSN FQDN: {psn_fqdn}")
            primary_ip = get_ssm_parameter(ssm_client, "Primary_IP")
            admin_username = get_ssm_parameter(ssm_client, "ADMIN_USERNAME")
            admin_password = get_ssm_parameter(ssm_client, "ADMIN_PASSWORD", WithDecryption=True)

            api_auth = (admin_username, admin_password)
            api_header = {'Content-Type': 'application/json', 'Accept': 'application/json'}
            logger.info(f"PSN IPs: {psn_ips}")

            for psn_ip_param, psn_ip_value in psn_ips.items():
                psn_node_roles = list(psn_roles.values())
                psn_node_services = list(psn_services.values())
                
            for index, role in enumerate(psn_node_roles):
                psn_fqdn_param = f"{psn_ip_param.split('_')[0]}_FQDN"
                

                logger.info(f"psn_ip_param: {psn_ip_param}, psn_ip_value: {psn_ip_value}")

                psn_fqdn_list = list(psn_fqdn.values())
                psn_fqdn_list_data = psn_fqdn_list[index].split(',') if index < len(psn_fqdn_list) else ""
                print(psn_fqdn_list_data)
                # Prepare the data for API request
                url = 'https://{}/api/v1/deployment/node'.format(primary_ip)
                data = {
                    "allowCertImport": True,
                    "fqdn": psn_fqdn_list_data[0],  # Using the extracted FQDN value
                    "userName": admin_username,
                    "password": admin_password,
                }

                logger.info(f"PSN Node Roles: {psn_node_roles}")
                logger.info(f"PSN Node Services: {psn_node_services}")
                
            
                current_services = psn_node_services[index].split(',') if index < len(psn_node_services) else ""
                current_role = role.split(',') if role else []

                if current_role == [' '] and current_services == [' ']:
                    logger.error('PSN node should contain either role or serive')
                    sys.exit(1)


                if current_role != [' ']:
                    data["roles"] = current_role
                else:
                    logger.info(f"No roles found for PSN node {index}")
                    
                if "PrimaryDedicatedMonitoring" in current_role or "SecondaryDedicatedMonitoring" in current_role:
                
                    logger.info(f"No services required as it is dedicated monitoring node")
                    
                elif current_services:
                    data["services"] = current_services
                    
                else:
                    data["services"] = [' ']

                logger.info('Url: {}, Data: {}'.format(url, data))
                # Logic for API requests with these roles and services

                try:
                    resp = requests.post(url, headers=api_header, auth=api_auth, data=json.dumps(data), verify=False)
                    logger.info(f'Register psn response: {resp.status_code}, {resp.text}')
                    if resp.status_code == 200:
                        logger.info(f"Registered PSN node {psn_ip_param} successfully")
                    else:
                        raise RegisterPSNNodeFailed(f"Failed to register PSN node {psn_ip_param}")
                except Exception as e:
                    logging.error(f'Exception: {e}', exc_info=True)
                    raise RegisterPSNNodeFailed(f"Exception occurred while registering PSN node {psn_ip_param}")
        
            timer.cancel()
            return {"Status": "SUCCESS"}
        
    except Exception as e:
            logging.error(f'Exception: {e}', exc_info=True)
