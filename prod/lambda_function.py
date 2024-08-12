import os
import ast
import json
from ipaddress import ip_network, ip_address


def check_ip(IP_ADDRESS, IP_RANGE):
    VALID_IP = False
    cidr_blocks = list(filter(lambda element: "/" in element, IP_RANGE))
    if cidr_blocks:
        for cidr in cidr_blocks:
            net = ip_network(cidr)
            VALID_IP = ip_address(IP_ADDRESS) in net
            if VALID_IP:
                break
    if not VALID_IP and IP_ADDRESS in IP_RANGE:
        VALID_IP = True

    return VALID_IP

def return_func(event, context):
    try:
        # Get the current directory
        current_dir = os.path.dirname(os.path.realpath(__file__))
        
        # Construct the path to index.html
        file_path = os.path.join(current_dir, 'index.html')
        
        # Read the contents of index.html
        with open(file_path, 'r') as file:
            html_content = file.read()
        
        # Return the HTML content
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'text/html'
            },
            'body': html_content
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

def deny_access():
    return {
            'statusCode': 403,
            'body': "Unauthorized"
        }
def handler(event, context):
    IP_ADDRESS = event["requestContext"]["http"]["sourceIp"]
    IP_RANGE = ast.literal_eval(os.environ.get("IP_RANGE", "[]"))
    METHOD = event["requestContext"]["http"]["method"]

    if not IP_RANGE:
        return deny_access()

    VALID_IP = check_ip(IP_ADDRESS, IP_RANGE)

    if not VALID_IP:
        return deny_access()

    if METHOD == "GET":
        return return_func(event, context)

    if METHOD == "POST":
        return deny_access()

    return deny_access()

