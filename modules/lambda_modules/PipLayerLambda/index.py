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
        description = "testing lambda function"
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
        # if event["RequestType"].upper() in ("CREATE", "UPDATE"):
        #     # Note: treat UPDATE as CREATE; it will create a new physical ID,
        #     # signalling CloudFormation that it's a replace and the old should be
        #     # deleted
        #     physicalId, attributes = _create()
        # else:
        #     assert event["RequestType"].upper() == "DELETE"
        #     _delete(event["PhysicalResourceId"])
        _create()
           
    except Exception as e:
        logger.exception("Internal Error")
       

 
