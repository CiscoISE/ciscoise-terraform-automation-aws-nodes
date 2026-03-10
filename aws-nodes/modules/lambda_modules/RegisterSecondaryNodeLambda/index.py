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

#       Name: RegisterSecondaryNodeLambda
#       Description: Registers ISENode02 to Primary Administration Node ISENode01

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

class RegisterSecondaryNodeFailed(Exception):
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
        url = 'https://{}/api/v1/deployment/node'.format(Primary_IP)
        data = {"allowCertImport": True,
                "fqdn": Secondary_FQDN,
                "userName": ADMIN_USERNAME,
                "password": ADMIN_PASSWORD,
               }
                # Retrieve roles_enabled parameter from SSM
        roles_enabled_str = get_ssm_parameter(ssm_client, "secondary_node_roles")
        if roles_enabled_str:
            roles_enabled = roles_enabled_str.split(',')
            
        else:
            # If no roles are found, skip this node
            roles_enabled = ["SecondaryAdmin"]
        data["roles"] = roles_enabled  # Include roles_enabled parameter   
        # Retrieve PSN services from SSM parameter
        psn_services_str = get_ssm_parameter(ssm_client, "secondary_node_services")
        psn_services_list = psn_services_str.split(',')
        if psn_services_list != [' ']:
            psn_services_enabled = psn_services_list
        else:
            logging.warning("Services parameter for secondary pan node is empty or missing.")
            psn_services_enabled = []

        data["services"] = psn_services_enabled
 


        logger.info('Url: {}, Data: {}'.format(url, data))

        resp = requests.post(url, headers=API_HEADER, auth=API_AUTH, data=json.dumps(data), verify=False)
        logger.info('Register secondary response: {}, {}'.format(resp.status_code, resp.text))
        if resp.status_code == 200:
            logger.info("Register Secondary node is successfull, API response is {}".format(resp.text))
            return {
                    "task_status": "Done"
                    }
        raise RegisterSecondaryNodeFailed({"Register Secondary node to form deployment Failed"})


    except RegisterSecondaryNodeFailed:
        requests_data=json.dumps(dict(Status='FAILURE',Reason='Secondary Node Registration Failed',UniqueId='ISENodeStates',Data='exception')).encode('utf-8')
        logging.error('Exception: %s', exc_info=True)


    except Exception as e:
        requests_data=json.dumps(dict(Status='FAILURE',Reason='Secondary Node Registration Failed',UniqueId='ISENodeStates',Data='exception')).encode('utf-8')
        logging.error('Exception: %s' % e, exc_info=True)