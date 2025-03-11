# Azure Bicep Infrastructure Explanation

This document provides a detailed explanation of the Bicep infrastructure files used in this project to deploy the multi-agent Java banking application to Azure.

## Table of Contents
- [Overview](#overview)
- [Main Deployment File](#main-deployment-file)
- [Application Modules](#application-modules)
- [Shared Infrastructure Modules](#shared-infrastructure-modules)
  - [AI Services](#ai-services)
  - [Hosting Services](#hosting-services)
  - [Monitoring Services](#monitoring-services)
  - [Security Services](#security-services)
  - [Storage Services](#storage-services)

## Overview

The infrastructure is defined using Azure Bicep, a domain-specific language (DSL) that simplifies the authoring of Azure Resource Manager (ARM) templates. The Bicep files are organized into a modular structure that follows best practices for infrastructure as code:

```
infra/
├── main.bicep                  # Main entry point for deployment
├── main.parameters.json        # Parameters for the deployment
├── app/                        # Application-specific modules
│   ├── account.bicep           # Account service infrastructure
│   ├── copilot.bicep           # Copilot service infrastructure
│   ├── payment.bicep           # Payment service infrastructure
│   ├── transaction.bicep       # Transaction service infrastructure
│   └── web.bicep               # Web frontend infrastructure
└── shared/                     # Shared infrastructure modules
    ├── abbreviations.json      # Resource naming conventions
    ├── backend-dashboard.bicep # Backend monitoring dashboard
    ├── ai/                     # AI services
    ├── host/                   # Container hosting services
    ├── monitor/                # Monitoring services
    ├── security/               # Security services
    └── storage/                # Storage services
```

## Main Deployment File

### main.bicep

The `main.bicep` file serves as the entry point for the entire deployment. It has a `targetScope` of 'subscription', which means it can deploy resources at the subscription level, including resource groups.

Key aspects of this file:

1. **Parameters:**
   - `environmentName`: Used to generate unique resource names
   - `location`: Primary location for all resources
   - Multiple parameters for each component of the architecture

2. **Resource Groups:**
   - Creates a main resource group for most resources
   - Uses existing resource groups for OpenAI, Document Intelligence, and storage if specified

3. **Module References:**
   - Calls various modules to deploy different parts of the application
   - Passes appropriate parameters to each module

4. **System Identity Setup:**
   - Creates role assignments for the managed identities
   - Grants the copilot service necessary permissions to access OpenAI, Storage, and Document Intelligence

5. **Outputs:**
   - Exports important values like resource names, connection strings, and endpoints

## Application Modules

### account.bicep, transaction.bicep, payment.bicep

These three files are similar in structure and purpose. Each one deploys a microservice for a specific domain:

- `account.bicep`: Deploys the account management service
- `transaction.bicep`: Deploys the transaction history service
- `payment.bicep`: Deploys the payment processing service

Each file:
1. Creates a user-assigned managed identity for the service
2. Deploys a container app using the `container-app-upsert.bicep` module
3. Configures environment variables for the service, including:
   - Azure client ID
   - Application Insights connection string
   - CORS allowed origins
4. Outputs the identity principal ID, name, URI, and image name of the deployed service

### copilot.bicep

Deploys the Copilot backend service, which is the AI orchestration layer. Similar to the other service modules, but with additional environment variables for connecting to:
- Azure Storage
- Azure OpenAI
- Document Intelligence
- The URLs of the three business services

### web.bicep

Deploys the frontend web application:
1. Creates a user-assigned managed identity
2. Deploys a container app using the `container-app-upsert.bicep` module
3. Configures environment variables for:
   - Application Insights connection string
   - API base URL (to connect to the Copilot backend)
4. Outputs the identity principal ID, name, URI, and image name of the web app

## Shared Infrastructure Modules

### AI Services

#### cognitiveservices.bicep

Deploys either an Azure OpenAI service or a Document Intelligence service:

1. **Parameters:**
   - Standard resource parameters (name, location, tags)
   - `kind`: Specifies the type of cognitive service (OpenAI or FormRecognizer)
   - `deployments`: Array of model deployments (for OpenAI)
   - `disableLocalAuth`: Security setting to disable local authentication
   - Network and SKU settings

2. **Resources:**
   - A Cognitive Services account
   - Model deployments (for OpenAI)

3. **Outputs:**
   - Service endpoint
   - Service ID and name

### Hosting Services

#### container-apps.bicep

Creates both a Container Apps Environment and a Container Registry:

1. **Parameters:**
   - Standard resource parameters
   - Environment and registry names
   - Log Analytics workspace name
   - Application Insights name
   - Dapr settings

2. **Modules:**
   - `containerAppsEnvironment`: Calls the container-apps-environment.bicep module
   - `containerRegistry`: Calls the container-registry.bicep module

3. **Outputs:**
   - Environment details (domain, name, ID)
   - Registry details (login server, name)

#### container-apps-environment.bicep

Creates an Azure Container Apps Environment with logging configured:

1. **Parameters:**
   - Standard resource parameters
   - Log Analytics workspace name
   - Application Insights name
   - Dapr settings

2. **Resources:**
   - A Container Apps Environment with log analytics configuration
   - References to existing Log Analytics workspace
   - Optional reference to Application Insights for Dapr instrumentation

3. **Outputs:**
   - Environment details (domain, ID, name)

#### container-app.bicep

Creates an individual container app within an environment:

1. **Parameters:**
   - Standard resource parameters
   - Container configuration (CPU, memory, replicas, port)
   - Identity settings
   - Registry settings
   - Dapr settings
   - Environment variables
   - Network settings

2. **Resources:**
   - Optional registry access setup
   - Container App with specified configuration

3. **Outputs:**
   - App details (domain, identity, name, URI)

#### container-app-upsert.bicep

A wrapper around `container-app.bicep` that can either create a new container app or update an existing one:

1. **Parameters:**
   - Same as container-app.bicep
   - `exists`: Boolean flag to indicate if the app already exists

2. **Resources:**
   - Reference to an existing app (if `exists` is true)
   - Module call to `container-app.bicep`

3. **Outputs:**
   - Same as container-app.bicep

#### container-registry.bicep

Creates an Azure Container Registry:

1. **Parameters:**
   - Standard resource parameters
   - Various registry settings like admin access, anonymousPullEnabled
   - Policy configurations
   - SKU settings

2. **Resources:**
   - Container Registry with specified configuration
   - Optional diagnostics settings

3. **Outputs:**
   - Registry ID, login server, and name

### Monitoring Services

#### monitoring.bicep

Creates both a Log Analytics workspace and an Application Insights instance:

1. **Parameters:**
   - Workspace and insights names
   - Dashboard name (optional)
   - Standard resource parameters

2. **Modules:**
   - `logAnalytics`: Calls loganalytics.bicep
   - `applicationInsights`: Calls applicationinsights.bicep

3. **Outputs:**
   - Application Insights details (connection string, ID, key)
   - Log Analytics details (ID, name)

#### loganalytics.bicep

Creates a Log Analytics workspace:

1. **Parameters:**
   - Standard resource parameters

2. **Resources:**
   - Log Analytics workspace with 30-day retention

3. **Outputs:**
   - Workspace ID and name

#### applicationinsights-dashboard.bicep

Creates an Azure Portal dashboard for Application Insights:

1. **Parameters:**
   - Dashboard and Application Insights names
   - Standard resource parameters

2. **Resources:**
   - Portal dashboard with a variety of Application Insights widgets:
     - Overview
     - Proactive detection
     - Live metrics
     - Usage statistics
     - Reliability metrics
     - Performance metrics

#### backend-dashboard.bicep

Creates a simplified dashboard specifically for backend services:

1. **Parameters:**
   - Dashboard and Application Insights names
   - Standard resource parameters

2. **Resources:**
   - Portal dashboard with backend-focused widgets:
     - Overview
     - Proactive detection
     - Application map
     - Reliability section
     - Performance section
     - Failed requests chart
     - Response time chart

### Security Services

#### role.bicep

Creates a role assignment for a service principal:

1. **Parameters:**
   - `principalId`: The ID of the principal to assign the role to
   - `principalType`: The type of principal (ServicePrincipal, User, etc.)
   - `roleDefinitionId`: The ID of the role to assign

2. **Resources:**
   - Role assignment with a deterministic name based on subscription, resource group, principal, and role

#### registry-access.bicep

Assigns ACR Pull permissions to access a container registry:

1. **Parameters:**
   - `containerRegistryName`: The name of the registry
   - `principalId`: The ID of the principal to grant access to

2. **Resources:**
   - Role assignment for the ACR Pull role
   - Reference to the existing container registry

#### keyvault.bicep

Creates an Azure Key Vault:

1. **Parameters:**
   - Standard resource parameters
   - `principalId`: Optional ID to grant initial access
   - `enabledForDeployment`: Whether to enable the vault for template deployment

2. **Resources:**
   - Key Vault with specified settings
   - Optional access policy for the provided principal ID

3. **Outputs:**
   - Vault endpoint, ID, and name

#### keyvault-secret.bicep

Creates or updates a secret in an Azure Key Vault:

1. **Parameters:**
   - Secret name and value
   - Key Vault name
   - Content type, expiration, and other settings

2. **Resources:**
   - Reference to the existing Key Vault
   - Secret with specified configuration

### Storage Services

#### storage-account.bicep

Creates an Azure Storage Account with optional containers, file shares, queues, and tables:

1. **Parameters:**
   - Standard resource parameters
   - Storage-specific settings (access tier, public access, etc.)
   - Container, file share, queue, and table definitions
   - Network access rules

2. **Resources:**
   - Storage account with specified configuration
   - Optional blob services with containers
   - Optional file services
   - Optional queue services
   - Optional table services

3. **Outputs:**
   - Account ID, name, and primary endpoints

## Deployment Flow

The overall deployment flow is as follows:

1. `main.bicep` is executed, creating the resource group(s)
2. Shared infrastructure is deployed:
   - Monitoring services
   - Container hosting environment
   - AI services
   - Storage account
3. Application services are deployed:
   - Account service
   - Transaction service
   - Payment service
   - Copilot service
   - Web frontend
4. Role assignments are created to allow the services to access the resources they need
5. Outputs are provided for use in scripts or the Azure Developer CLI

This structured, modular approach makes the infrastructure more maintainable and allows for easier updates and extensions in the future.
