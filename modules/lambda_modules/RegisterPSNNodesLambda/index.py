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
    

def get_and_increment_retry_count(ssm_client):
    try:
        # Retrieve the current retry count
        param_name = "PSN_RETRY_COUNT"  # Replace with your SSM parameter name
        response = ssm_client.get_parameter(Name=param_name, WithDecryption=False)
        current_retry_count = int(response['Parameter']['Value'])

        # Increment the retry count
        current_retry_count += 1
        logger.info(f"PSN_RETRY_COUNT: {current_retry_count}")
        # Update the SSM Parameter with the new retry count
        ssm_client.put_parameter(
            Name=param_name,
            Value=str(current_retry_count),
            Overwrite=True,
            Type="String"
        )

        return current_retry_count
    except Exception as e:
        logger.error(f"Error while getting/incrementing retry count from SSM: {e}")
        return 0  # In case of an error, start with 0
    

def timeout(event, context):
    logging.error('Execution is about to time out, sending failure response to CloudFormation')
    requests_data = json.dumps(data=dict(Status='FAILURE', Reason='Lambda timeout', UniqueId='ISENodeStates', Data='failed due to timeout')).encode('utf-8')
    response = requests.put(event['ResourceProperties']['WaitHandle'], data=requests_data, headers={'Content-Type': ''})
    sys.exit(1)

def handler(event, context):
    runtime_region = os.environ['AWS_REGION']
    ssm_client = boto3.client('ssm', region_name=runtime_region)
    timer = threading.Timer((context.get_remaining_time_in_millis() / 1000.00) - 0.5, timeout, args=[event, context])
    roles_token = None
    services_token = None
    fqdn_token = None
    psn_roles_parameters = []
    psn_services_parameters = []
    psn_fqdn_parameters = []
    try:
    # Loop to retrieve all parameters
        while True:
            # Fetch roles for PSN
            if roles_token:
                response = ssm_client.describe_parameters(
                    ParameterFilters=[{"Key": "tag:type", "Values": ["psn_roles"]}],
                    MaxResults=50,
                    NextToken=roles_token
                    )
            else:
                response = ssm_client.describe_parameters(
                    ParameterFilters=[{"Key": "tag:type", "Values": ["psn_roles"]}],
                    MaxResults=50
                    )
            logger.info(f"PSN Roles: {response}")
            psn_roles_parameters.extend(response['Parameters'])
            roles_token = response.get('NextToken')
            #roles_token = psn_roles_parameters.get('NextToken')
            
            # Fetch Services for PSN
            if services_token:
                response = ssm_client.describe_parameters(
                    ParameterFilters=[{"Key": "tag:type", "Values": ["psn_services"]}],
                    MaxResults=50,
                    NextToken=services_token
                    )
            else:
                response = ssm_client.describe_parameters(
                    ParameterFilters=[{"Key": "tag:type", "Values": ["psn_services"]}],
                    MaxResults=50
                    )
            logger.info(f"PSN Services: {response}")
            psn_services_parameters.extend(response['Parameters'])
            services_token = response.get('NextToken')
            psn_roles = {param['Name']: get_ssm_parameter(ssm_client, param['Name']) for param in psn_roles_parameters}
            psn_services = {param['Name']: get_ssm_parameter(ssm_client, param['Name']) for param in psn_services_parameters}
            logger.info(f"PSN Roles: {psn_roles}")
            logger.info(f"PSN Services: {psn_services}")


            # Fetch FQDN parameters
            if fqdn_token:
                response = ssm_client.describe_parameters(
                    ParameterFilters=[{"Key": "tag:type", "Values": ["psn_fqdn"]}],
                    MaxResults=50,
                    NextToken=fqdn_token
                    )
            else:
                response = ssm_client.describe_parameters(
                    ParameterFilters=[{"Key": "tag:type", "Values": ["psn_fqdn"]}],
                    MaxResults=50
                    )
            logger.info(f"PSN FQDN: {response}")
            psn_fqdn_parameters.extend(response['Parameters'])
            fqdn_token = response.get('NextToken')
            #psn_fqdn_parameters = ssm_client.describe_parameters(ParameterFilters=[{"Key": "tag:type", "Values": ["psn_fqdn"]}],MaxResults=50)['Parameters']
            logger.info(f'PSN FQDN parameters fetched from SSM : {psn_fqdn_parameters}')
            psn_fqdn = {param['Name']: get_ssm_parameter(ssm_client, param['Name']) for param in psn_fqdn_parameters}
            logger.info(f"PSN FQDN: {psn_fqdn}")
            print(fqdn_token)
            if not fqdn_token:
            # If no NextToken, we've retrieved all results
                break
            
    except Exception as e:
        logging.error(f'Exception: {e}', exc_info=True)
    # except botocore.exceptions.ClientError as error:
        # Handle the error appropriately
        print(error)

    try:
        while True:
            psn_ip_parameters = ssm_client.describe_parameters(ParameterFilters=[{"Key": "tag:type", "Values": ["psn_ip"]}], MaxResults=50)['Parameters']
            logger.info(f'PSN IP parameters fetched from SSM : {psn_ip_parameters}')
            if len(psn_ip_parameters) == 0:
                logger.info('No PSN node found')
                return {
                    "PSNState": "running",
                    "retries": 0
                }
                
            psn_ips = {param['Name']: get_ssm_parameter(ssm_client, param['Name']) for param in psn_ip_parameters}
            primary_ip = get_ssm_parameter(ssm_client, "Primary_IP")
            admin_username = get_ssm_parameter(ssm_client, "ADMIN_USERNAME")
            admin_password = get_ssm_parameter(ssm_client, "ADMIN_PASSWORD", WithDecryption=True)

            api_auth = (admin_username, admin_password)
            api_header = {'Content-Type': 'application/json', 'Accept': 'application/json'}
            logger.info(f"PSN IPs: {psn_ips}")
            nodes_fqdn_list = psn_fqdn.values()

            for psn_ip_param, psn_ip_value in psn_ips.items():
                psn_node_roles = list(psn_roles.values())
                psn_node_services = list(psn_services.values())
                
            for index, role in enumerate(psn_node_roles):
                psn_fqdn_param = f"{psn_ip_param.split('_')[0]}_FQDN"
                

                logger.info(f"psn_ip_param: {psn_ip_param}, psn_ip_value: {psn_ip_value}")

                psn_fqdn_list = list(psn_fqdn.values())
                logger.info(psn_fqdn_list)
                # psn_fqdn_list_data = psn_fqdn_list[index].split(',') if index < len(psn_fqdn_list) else ""
                # logger.info(f"psn_fqdn_list_data: >>>> {psn_fqdn_list_data} <<<<")
                if psn_fqdn_list:  # Check if the list is not empty
                    if index < len(psn_fqdn_list):  # Check if index is within the valid range
                        psn_fqdn_list_data = psn_fqdn_list[index].split(',')
                    else:
                        # Handle the case where index is out of range (e.g., assign a default value)
                        psn_fqdn_list_data = "Index out of range"
                else:
                    # Handle the case where the list is empty (e.g., assign a default value)
                    psn_fqdn_list_data = "Empty list"
                logger.info(f"psn_fqdn_list_data: >>>> {psn_fqdn_list_data} <<<<")
                # Prepare the data for API request
                url = 'https://{}/api/v1/deployment/node'.format(primary_ip)
                logger.info(f"Current FQDN: {psn_fqdn_list_data[0]}")
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
                    
                elif current_services and current_services != [' ']:
                    data["services"] = current_services
                else:
                    # If current_services is [' '], remove the "services" key from the data dictionary
                    data.pop("services", None)

                logger.info('Url: {}, Data: {}'.format(url, data))
                # Logic for API requests with these roles and services
                resp = requests.post(url, headers=api_header, auth=api_auth, data=json.dumps(data), verify=False)
                logger.info(f'Register psn response: {resp.status_code}, {resp.text}')
                if resp.status_code == 200 or resp.status_code == 400:
                    logger.info(f"Registered PSN node {psn_ip_param} successfully")
                    #psn_fqdn_values_list = list(psn_fqdn.values())
                    
                    #if psn_fqdn_list_data and psn_fqdn_list_data[0] in psn_fqdn_values_list:
                        #psn_fqdn_values_list.remove(psn_fqdn_list_data[0])
                    #psn_fqdn = dict(zip(psn_fqdn.keys(), psn_fqdn_values_list))
                    
            logger.info(f"FQDN before List: {psn_fqdn}")
            nodes_fqdn_list = psn_fqdn.values()
            logger.info(f"Node FQDN LIST: {nodes_fqdn_list}")
            if nodes_fqdn_list:
                    
                if len(nodes_fqdn_list) > 0:
                    current_retry_count = get_and_increment_retry_count(ssm_client)
                    return {
                        "PSNState": "pending",
                        "retries": str(current_retry_count)
                    }
            else:
               logger.error("Nodes FQDN list is empty")    
            timer.cancel()
            return {
                "PSNState": "running",
                "retries": str(current_retry_count)
                }
        
    except Exception as e:
            logging.error(f'Exception: {e}', exc_info=True)
            return {
                    "PSNState": "pending",
                    "retries": 3
                }
