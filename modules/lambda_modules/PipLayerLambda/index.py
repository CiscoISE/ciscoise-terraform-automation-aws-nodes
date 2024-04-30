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
import pathlib
import re
import subprocess
import sys
import tempfile
import typing as t
import shutil
import boto3
logger = logging.getLogger()
logger.setLevel(logging.INFO)
class PipLayerException(Exception):
    pass
def _create():
    try:
        layername = "CiscoISEPackageLayer"
        description = "CiscoISEPackageLayer lambda function"
        packages = ["boto3", "requests"]
    except KeyError as e:
        raise PipLayerException("Missing parameter: %s" % e.args[0])
    description += " ({})".format(", ".join(packages))
    if not isinstance(layername, str):
        raise PipLayerException("LayerName must be a string")
    if not isinstance(description, str):
        raise PipLayerException("Description must be a string")
    if not isinstance(packages, list) or not all(isinstance(p, str) for p in packages):
        raise PipLayerException("Packages must be a list of strings")
    tempdir = pathlib.Path(tempfile.TemporaryDirectory().name) / "python"
    try:
        subprocess.check_call([
            sys.executable, "-m", "pip", "install", *packages, "-t", tempdir])
    except subprocess.CalledProcessError:
        raise PipLayerException("Error while installing %s" % str(packages))
    zipfilename = pathlib.Path(tempfile.NamedTemporaryFile(suffix=".zip").name)
    shutil.make_archive(
        zipfilename.with_suffix(""), format="zip", root_dir=tempdir.parent)
    client = boto3.client("lambda")
    layer = client.publish_layer_version(
        LayerName=layername,
        Description=description,
        Content={"ZipFile": zipfilename.read_bytes()},
        CompatibleRuntimes=["python%d.%d" % sys.version_info[:2]],
    )
    logger.info("Created layer %s", layer["LayerVersionArn"])
    return (layer["LayerVersionArn"], {})
def _delete(physical_id):
    match = re.fullmatch(
        r"arn:aws:lambda:(?P<region>[^:]+):(?P<account>\d+):layer:"
        r"(?P<layername>[^:]+):(?P<version_number>\d+)", physical_id)
    if not match:
        logger.warning("Cannot parse physical id %s, not deleting", physical_id)
        return
    layername = match.group("layername")
    version_number = int(match.group("version_number"))
    logger.info("Now deleting layer %s:%d", layername, version_number)
    client = boto3.client("lambda")
    deletion = client.delete_layer_version(
        LayerName=layername,
        VersionNumber=version_number)
    logger.info("Done")
def handler(event, context):
    logger.info('{"event": %s}', json.dumps(event))
    try:
        _create()
           
    except Exception as e:
        logger.exception("Internal Error")
       

 
