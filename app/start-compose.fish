#!/usr/bin/env fish

# Loading azd .env file from current environment
for line in (azd -C ../ env get-values)
    set parts (string split = $line)
    set key $parts[1]
    set value (string trim --chars='"' $parts[2])
    set -gx $key $value
    echo "export $key=$value"
end

if test $status -ne 0
    echo "Failed to load environment variables from azd environment"
    exit $status
end

# Checking Service Principal and get password
set roles a97b65f3-24c7-4388-baec-2e87135dc908 5e0bd9bd-7b93-4f28-af87-19fc36ad61bd ba92f5b4-2d11-453d-a403-e96b0029c9fe 7f951dda-4ed3-4680-a7ca-43fe172d538d

set -gx servicePrincipal (az ad sp list --display-name "agent-java-banking-spi" --query [].appId --output tsv)

if test -z "$servicePrincipal"
    echo "Service principal not found. Creating service principal..."
    set -gx servicePrincipal (az ad sp create-for-rbac --name "agent-java-banking-spi" --role reader --scopes /subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$AZURE_RESOURCE_GROUP --query appId --output tsv)
    if test $status -ne 0
        echo "Failed to create service principal"
        exit $status
    end
    set -gx servicePrincipalObjectId (az ad sp show --id "$servicePrincipal" --query id --output tsv)
    echo "Assigning Roles to service principal agent-java-banking-spi with principal id:$servicePrincipal and object id[$servicePrincipalObjectId]"
    for role in $roles
        echo "Assigning Role[$role] to principal id[$servicePrincipal] for resource[/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$AZURE_RESOURCE_GROUP]"
        az role assignment create --role "$role" --assignee-object-id "$servicePrincipalObjectId" --scope /subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$AZURE_RESOURCE_GROUP --assignee-principal-type ServicePrincipal
    end
end

set -gx servicePrincipalPassword (az ad sp credential reset --id "$servicePrincipal" --query password --output tsv)
set -gx servicePrincipalTenant (az ad sp show --id "$servicePrincipal" --query appOwnerOrganizationId --output tsv)

# Starting solution locally using docker compose

docker compose -f ./compose.yaml up
