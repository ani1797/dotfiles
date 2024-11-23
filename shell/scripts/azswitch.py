#!/usr/bin/env python

import os
import json
import subprocess

def load_available_accounts():
    # Load the available accounts from OnePassword
    # and return them as a tuple of (vault_name, identifier)
    # Calls the OnePassword CLI to get the list of accounts
    # op items list --tags=Azure --format=JSON

    process = subprocess.run(["op", "item", "list", "--tags=Azure", "--format=JSON"], check=True, stdout=subprocess.PIPE)
    accounts = json.loads(process.stdout)
    return map(lambda x: (x["vault"]["name"], x["title"]), accounts)


def get_field_value(details, field) -> str:
    fields = details['fields']
    f_item = list(filter(lambda x: x['label'] == field, fields))
    if f_item:
        return f_item[0]['value']
    return None

type Value = str | None

def call(command: str) -> tuple[Value, Value]:
    process = subprocess.run(command.split(' '), check=True, stdout=subprocess.PIPE)
    if process.returncode != 0:
        return None, process.stderr.decode("utf-8")
    else:
        return process.stdout.decode("utf-8"), None

if __name__ == "__main__":
    accounts = list(load_available_accounts())
    print("Available accounts:")
    for i, (vault, account) in enumerate(accounts):
        print(f"{i+1}. {vault} - {account}")

    choice = int(input("Choose an account: ")) - 1
    vault, account = accounts[choice]

    # Get the account details
    process = subprocess.run(["op", "item", "get", account, "--vault", vault, "--format=JSON"], check=True, stdout=subprocess.PIPE)
    account_details = json.loads(process.stdout)

    def is_service_principal(account_details):
        return "Service Principal" in account_details['tags']

    if is_service_principal(account_details):
        print("Logging in using Service Principal")
        client_id = get_field_value(account_details, "username")
        client_secret = get_field_value(account_details, "password")
        tenant_id = get_field_value(account_details, "tenant_id")
        if not all([client_id, client_secret, tenant_id]):
            print("Missing required fields")
            exit(1)

        cmd = f"az login --allow-no-subscription --service-principal -u {client_id} -p {client_secret} --tenant {tenant_id}"
        res, err = call(cmd)
        if err:
            print(f"Error: {err}")
        else:
            print(res)
            os.environ['AZURE_CLIENT_ID'] = client_id
            os.environ['AZURE_TENANT_ID'] = tenant_id
            os.environ['AZURE_CLIENT_SECRET'] = client_secret
    else:
        print("Logging in using User Account")
        username = get_field_value(account_details, "username")
        password = get_field_value(account_details, "password")
        tenant_id = get_field_value(account_details, "tenant_id")
        if not all([username, password, tenant_id]):
            print("Missing required fields")
            exit(1)
        cmd = f"az login -u {username} -p {password} --tenant {tenant_id}"
        res, err = call(cmd)
        if err:
            print(f"Error: {err}")
        else:
            print(res)
