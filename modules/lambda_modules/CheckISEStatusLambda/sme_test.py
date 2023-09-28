import boto3

def get_ssm_parameter(parameter_name, region_name='us-east-2'):
    try:
        # Create an SSM client
        ssm_client = boto3.client('ssm', region_name=region_name)

        # Retrieve the parameter's value
        response = ssm_client.get_parameter(
            Name=parameter_name,
            WithDecryption=True  # Decrypt the parameter if it's SecureString
        )

        # Extract and return the parameter's value
        parameter_value = response['Parameter']['Value']
        return parameter_value

    except Exception as e:
        return str(e)

# Example usage
if __name__ == "__main__":
    parameter_name = "Primary_FQDN"  # Replace with your SSM parameter name
    parameter_value = get_ssm_parameter(parameter_name)

    if parameter_value:
        print(f"The value of parameter {parameter_name} is: {parameter_value}")
    else:
        print(f"Failed to retrieve the parameter {parameter_name}")
