import os

import boto3


client = boto3.client("ec2",
                      region_name=os.environ.get("AWS_REGION", "us-east-1"),
                      aws_access_key_id=os.environ.get("AWS_ACCESS_KEY_ID"),
                      aws_secret_access_key=os.environ.get("AWS_SECRET_ACCESS_KEY"))


def get_all_key_value_pairs():
    response = client.describe_key_pairs()

    if not isinstance(response, dict):
        return {"result": False, "message": "output is not in json format", "data": None}
    return {"result": True, "message": "output is not in json format", "data": response}


def parse_key_value_pairs(kv_response):
    if "KeyPairs" not in kv_response:
        return {"result": False, "message": "key value pairs not present", "data": None}

    key_value_pairs = kv_response.get("KeyPairs")
    if not key_value_pairs:
        return {"result": False, "message": "no key value pair found! create one before using this service", "data": None}

    all_key_value_pairs = [kv.get("KeyName") for kv in key_value_pairs]
    return {"result": True, "message": "key value pairs found", "data": all_key_value_pairs}


if __name__ == '__main__':
    all_kv_pairs = get_all_key_value_pairs()
    if all_kv_pairs.get("result"):
        print(parse_key_value_pairs(all_kv_pairs["data"]))
