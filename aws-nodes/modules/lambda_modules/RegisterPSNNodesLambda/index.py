# Copyright 2024 Cisco Systems, Inc. and its affiliates
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

import json
import logging
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


def set_ssm_parameter(ssm_client, ssm_parameter_name, value, Overwrite=True, Type="String"):
    response = ssm_client.put_parameter(
        Name=ssm_parameter_name,
        Value=value,
        Overwrite=True,
        Type=Type
    )
    return response


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
        set_ssm_parameter(ssm_client, param_name, str(current_retry_count))
        return current_retry_count
    except Exception as e:
        logger.error(f"Error while getting/incrementing retry count from SSM: {e}")
        return 0  # In case of an error, start with 0
    

def handler(event, context):
    runtime_region = os.environ['AWS_REGION']
    ssm_client = boto3.client('ssm', region_name=runtime_region)
    buffer_time_in_milliseconds = 150000
    try:
        psn_roles = json.loads(get_ssm_parameter(ssm_client, "psn_roles_list"))
        psn_services = json.loads(get_ssm_parameter(ssm_client, "psn_services_list"))
        psn_fqdn = json.loads(get_ssm_parameter(ssm_client, "psn_fqdn_list"))
        logging.info(f"PSN Roles json retrieved from SSM : {psn_roles}")
        logging.info(f"PSN Services json retrieved from SSM : {psn_services}")
        logging.info(f"PSN FQDN json retrieved from SSM : {psn_fqdn}")
    except Exception as e:
        logging.error(f'Exception while fetching SSM Parameters: {e}', exc_info=True)

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

            nodes_fqdn = psn_fqdn.copy()
            psn_nodes_fqdn = psn_fqdn.copy()
            logging.info(f'nodes_fqdn : {nodes_fqdn}')
            for fqdn_key, fqdn_value in psn_fqdn.items():
                # Exit the code before timeout (Limit 20s)
                time_left_in_milliseconds = context.get_remaining_time_in_millis()
                logger.info(f"time_left_in_milliseconds: ===== {time_left_in_milliseconds}")
                if time_left_in_milliseconds <= buffer_time_in_milliseconds:
                    current_retry_count = get_and_increment_retry_count(ssm_client)
                    # Perform any necessary cleanup here
                    # Return a response indicating that we're stopping early to avoid a timeout
                    logging.info(f"Updated SSM Roles : {psn_roles}")
                    logging.info(f"Updated SSM Services : {psn_services}")
                    logging.info(f"Updated SSM FQDN : {psn_nodes_fqdn}")
                    set_ssm_parameter(ssm_client, "psn_roles_list", json.dumps(psn_roles))
                    set_ssm_parameter(ssm_client, "psn_services_list", json.dumps(psn_services))
                    set_ssm_parameter(ssm_client, "psn_fqdn_list", json.dumps(psn_nodes_fqdn))
                    return {
                        "PSNState": "timeout",
                        "retries": str(current_retry_count)
                    }

                # Prepare the data for API request
                url = 'https://{}/api/v1/deployment/node'.format(primary_ip)
                logger.info(f"Current FQDN: {fqdn_value}")
                data = {
                    "allowCertImport": True,
                    "fqdn": fqdn_value,  # Using the extracted FQDN value
                    "userName": admin_username,
                    "password": admin_password,
                }
                node_name = fqdn_value.split(".")[0]
                role = psn_roles.get(f'{node_name}_roles')
                service = psn_services.get(f'{node_name}_services')
                logger.info(f"Current PSN Node Role: {role}")
                logger.info(f"Current PSN Node service: {service}")
                
                current_services = service.split(',')
                current_role = role.split(',') if role else []

                if current_role == [' '] and current_services == [' ']:
                    logger.error('PSN node should contain either role or serive')
                    sys.exit(1)

                if current_role != [' ']:
                    data["roles"] = current_role
                else:
                    logger.info(f"No roles found for PSN node {node_name}")
                    
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
                if resp.status_code == 200 or resp.status_code == 400 or resp.status_code == 500:
                    logger.info(f"Registered PSN node {fqdn_value} successfully")
                    logger.info(f"FQDN key {fqdn_key}")
                    del psn_nodes_fqdn[fqdn_key]
                    del nodes_fqdn[fqdn_key]
                    del psn_roles[f'{node_name}_roles']
                    del psn_services[f'{node_name}_services']
            if nodes_fqdn:
                    
                if len(nodes_fqdn) > 0:
                    current_retry_count = get_and_increment_retry_count(ssm_client)
                    return {
                        "PSNState": "pending",
                        "retries": str(current_retry_count)
                    }
            else:
               logger.info("Nodes FQDN list is empty")
               set_ssm_parameter(ssm_client, "psn_roles_list", "{}")
               set_ssm_parameter(ssm_client, "psn_services_list", "{}")
               set_ssm_parameter(ssm_client, "psn_fqdn_list", "{}")
            set_ssm_parameter(ssm_client, "PSN_RETRY_COUNT", str(0))
            return {
                "PSNState": "running",
                "retries": 0
                }
        
    except Exception as e:
            logging.error(f'Exception: {e}', exc_info=True)
            return {
                    "PSNState": "exception",
                    "retries": 10
                }
