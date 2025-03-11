# Multi Agents Sample Application with Java and Semantic Kernel

This application is designed to explore the capabilities of generative AI within the context of multi-agent architecture. By leveraging Java and Semantic Kernel, this project aim is to build a chat application that facilitates real-time communication among multiple agents.

## Description

### Application Overview

This application is a multi-agent banking assistant powered by Java and Semantic Kernel, demonstrating how generative AI can transform traditional banking interactions into natural language conversations. The system allows users to:

- Inquire about account balances and details
- Review transaction history and search for specific transactions
- Process payments and pay bills, including through invoice image uploads
- Verify payment methods and account funds before transactions

The application employs a vertical multi-agent architecture where specialized AI agents handle different domains of the banking experience:

1. **Router Agent** - The central coordinator that analyzes user intent from chat messages and routes conversations to the appropriate specialist agent
2. **Account Agent** - Provides information about bank accounts, balances, and payment methods
3. **Transaction History Agent** - Retrieves and presents transaction history with filtering capabilities
4. **Payment Agent** - Processes bill payments, including image-based invoice scanning using Azure Document Intelligence

Each agent is equipped with specific tools to interact with banking microservices through OpenAPI definitions, providing a seamless experience where users can accomplish banking tasks through natural conversation rather than navigating traditional web interfaces.

### Tools and Products

#### Programming Languages and Frameworks
1. **Java** - Primary language for backend services.
2. **Spring Boot** - Framework for building Java-based backend services.
3. **TypeScript** - Primary language for the frontend application.
4. **React** - JavaScript library for building user interfaces.
5. **Semantic Kernel** - AI orchestration framework.

#### AI and Cognitive Services
1. **Azure OpenAI** - Provides AI capabilities for natural language processing.
2. **Azure Document Intelligence** - Used for processing and extracting data from documents.

#### Containerization and Orchestration
1. **Docker** - Used for containerizing the application services.
2. **Docker Compose** - Tool for defining and running multi-container Docker applications.
3. **Azure Container Apps** - Managed service for running containerized applications.
4. **Kubernetes** - Orchestration tool for managing containerized applications (used in deployment manifests).

#### Infrastructure as Code
1. **Bicep** - Used for defining and deploying Azure resources declaratively.

#### Build and Dependency Management
1. **Maven** - Build automation tool for Java projects.
2. **NPM** - Package manager for JavaScript and TypeScript.

#### Continuous Integration and Deployment
1. **GitHub Actions** - CI/CD tool for automating workflows.

#### Monitoring and Logging
1. **Azure Monitor** - Provides monitoring and logging capabilities.
2. **Application Insights** - Part of Azure Monitor, used for application performance management.
3. **Log Analytics** - Used for querying and analyzing logs.

#### Authentication and Security
1. **Azure AD (Active Directory)** - Provides authentication and authorization services.
2. **MSAL (Microsoft Authentication Library)** - Library for handling authentication in the frontend.

#### Storage
1. **Azure Blob Storage** - Used for storing files and documents.

#### Development and Collaboration
1. **Visual Studio Code** - Integrated development environment (IDE) for coding.
2. **GitHub** - Platform for version control and collaboration.

#### Frontend Tooling
1. **Vite** - Build tool for frontend projects.
2. **Fluent UI** - UI framework for building user interfaces.

#### Miscellaneous
1. **NGINX** - Web server for serving the frontend application.

### Project Structure

#### Application folder

The application follows a microservices architecture organized as follows:

```
app/
├── compose.yaml                # Docker Compose configuration for local deployment
├── start-compose.ps1           # PowerShell script to start services using Docker Compose
├── start-compose.sh            # Bash script to start services using Docker Compose
├── business-api/               # Backend business microservices
│   ├── account/                # Account management service
│   │   ├── Dockerfile          # Container definition for account service
│   │   ├── pom.xml             # Maven build configuration
│   │   └── src/                # Source code for account service
│   ├── payment/                # Payment processing service
│   │   ├── Dockerfile          # Container definition for payment service
│   │   ├── pom.xml             # Maven build configuration
│   │   └── src/                # Source code for payment service
│   └── transactions-history/   # Transaction history service
│       ├── Dockerfile          # Container definition for transaction history service
│       ├── pom.xml             # Maven build configuration
│       └── src/                # Source code for transaction history service
├── copilot/                    # Copilot service - AI orchestration layer
│   ├── Dockerfile              # Container definition for copilot service
│   ├── pom.xml                 # Maven parent build configuration
│   ├── copilot-backend/        # Main copilot service implementation
│   │   ├── pom.xml             # Maven build configuration
│   │   ├── manifests/          # Kubernetes manifests for deployment
│   │   └── src/                # Source code for copilot backend
│   └── semantickernel-openapi-plugin/ # Semantic Kernel OpenAPI plugin
│       ├── pom.xml             # Maven build configuration
│       └── src/                # Plugin source code
└── frontend/                   # User interface application
    ├── Dockerfile              # Container definition for production
    ├── Dockerfile-aks          # Container definition for AKS deployment
    ├── package.json            # NPM dependencies and scripts
    ├── tsconfig.json           # TypeScript configuration
    ├── vite.config.ts          # Vite build configuration
    ├── manifests/              # Kubernetes manifests for deployment
    ├── nginx/                  # NGINX configuration for serving frontend
    ├── public/                 # Static assets
    └── src/                    # React application source code
        ├── api/                # API client code
        ├── components/         # Reusable UI components
        ├── pages/              # Application pages
        └── assets/             # Frontend assets (images, styles)
```

The project consists of three main components:
1. **Business API Services** - A set of Java microservices that handle various business domains:
   - Account Service - Manages user account information
   - Payment Service - Processes payment transactions
   - Transaction History Service - Stores and retrieves transaction records

2. **Copilot Service** - The AI orchestration layer built with Java and Semantic Kernel:
   - Copilot Backend - Core backend service that integrates with Azure OpenAI
   - Semantic Kernel OpenAPI Plugin - Extends functionality through OpenAPI integration

3. **Frontend Application** - A React-based web interface built with:
   - React/TypeScript
   - Modern frontend tooling (Vite)
   - Containerized for deployment

#### Infra folder

The infrastructure is defined using Bicep templates (Infrastructure as Code) and organized as follows:

```
infra/
├── main.bicep                  # Main Bicep deployment template
├── main.parameters.json        # Parameters for the main Bicep deployment
├── app/                        # Application-specific infrastructure definitions
│   ├── account.bicep           # Account service infrastructure
│   ├── copilot.bicep           # Copilot service infrastructure
│   ├── payment.bicep           # Payment service infrastructure
│   ├── transaction.bicep       # Transaction history service infrastructure
│   └── web.bicep               # Web frontend infrastructure
└── shared/                     # Shared infrastructure components
    ├── abbreviations.json      # Resource naming abbreviations
    ├── backend-dashboard.bicep # Dashboard for backend monitoring
    ├── ai/                     # AI service definitions
    │   └── cognitiveservices.bicep  # Azure Cognitive Services (OpenAI, Document Intelligence)
    ├── host/                   # Container hosting infrastructure
    │   ├── container-app-upsert.bicep    # Container App creation/update
    │   ├── container-app.bicep           # Container App definition
    │   ├── container-apps-environment.bicep  # Container Apps Environment
    │   ├── container-apps.bicep          # Container Apps orchestration
    │   └── container-registry.bicep      # Container Registry definition
    ├── monitor/                # Monitoring infrastructure
    │   ├── applicationinsights-dashboard.bicep  # Application Insights dashboard
    │   ├── applicationinsights.bicep           # Application Insights definition
    │   ├── loganalytics.bicep                 # Log Analytics workspace
    │   └── monitoring.bicep                   # Monitoring resources orchestration
    ├── security/               # Security infrastructure
    │   ├── keyvault-access.bicep             # Key Vault access policies
    │   ├── keyvault-secret.bicep             # Key Vault secrets
    │   ├── keyvault.bicep                    # Key Vault definition
    │   ├── registry-access.bicep             # Container Registry access
    │   └── role.bicep                        # Azure RBAC role assignments
    └── storage/                # Storage infrastructure
        └── storage-account.bicep              # Azure Storage Account definition
```

This infrastructure code defines the deployment of all Azure cloud resources required by the application:

1. **Application Services** - Each application component (account, payment, transaction, copilot, web) has a dedicated Bicep template in the `app/` folder that defines its specific infrastructure needs.

2. **AI Services** - Templates for provisioning Azure OpenAI and Document Intelligence services.

3. **Container Hosting** - Templates for Container Apps Environment, Container Registry, and Container App definitions that host the application's microservices.

4. **Monitoring** - Application Insights, Log Analytics, and dashboard resources for observability.

5. **Security** - Key Vault for secrets management, role-based access control (RBAC), and registry access configurations.

6. **Storage** - Azure Storage Account configuration for blob storage needs.

The main Bicep template (`main.bicep`) orchestrates the deployment of all these components, while the parameters file (`main.parameters.json`) provides configuration values that can be customized for different environments.

### Architecture

#### Flowchart

![Flowchart](https://github.com/user-attachments/assets/9ec84997-9a95-4584-b2d6-539c64405a17)

<details>
<summary>Mermaid Diagram</summary>

```mermaid
flowchart TB
    User(User)--"Chat/Uploads"-->Frontend

    subgraph "Frontend Layer"
        Frontend[React Frontend Application]
    end

    Frontend--API Requests-->CopilotBackend

    subgraph "AI Orchestration Layer"
        CopilotBackend[Copilot Backend]

        subgraph "Multi-Agent System"
            RouterAgent[Router Agent\nAnalyzes Intent]
            PaymentAgent[Payment Agent]
            AccountAgent[Account Agent]
            TransactionAgent[Transaction History Agent]

            RouterAgent-->PaymentAgent
            RouterAgent-->AccountAgent
            RouterAgent-->TransactionAgent
        end

        CopilotBackend-->RouterAgent

        SemanticKernel[Semantic Kernel]
        OpenAPIPlugin[OpenAPI Plugin]

        PaymentAgent-->SemanticKernel
        AccountAgent-->SemanticKernel
        TransactionAgent-->SemanticKernel
        SemanticKernel-->OpenAPIPlugin
    end

    subgraph "Azure AI Services"
        AzureOpenAI[Azure OpenAI]
        AzureDocIntel[Azure Document Intelligence]
        AzureStorage[Azure Blob Storage]
    end

    subgraph "Business API Layer"
        AccountAPI[Account Service API]
        PaymentAPI[Payment Service API]
        TransactionAPI[Transaction History Service API]
    end

    OpenAPIPlugin-->AccountAPI
    OpenAPIPlugin-->PaymentAPI
    OpenAPIPlugin-->TransactionAPI

    CopilotBackend-->AzureOpenAI
    PaymentAgent-->AzureDocIntel
    AzureDocIntel-->AzureStorage

    style Frontend fill:#f9f9f9,stroke:#333,stroke-width:2px
    style CopilotBackend fill:#d1e7dd,stroke:#333,stroke-width:2px
    style RouterAgent fill:#d1e7dd,stroke:#333,stroke-width:2px
    style PaymentAgent fill:#d1e7dd,stroke:#333,stroke-width:2px
    style AccountAgent fill:#d1e7dd,stroke:#333,stroke-width:2px
    style TransactionAgent fill:#d1e7dd,stroke:#333,stroke-width:2px
    style AccountAPI fill:#dbeafe,stroke:#333,stroke-width:2px
    style PaymentAPI fill:#dbeafe,stroke:#333,stroke-width:2px
    style TransactionAPI fill:#dbeafe,stroke:#333,stroke-width:2px
    style AzureOpenAI fill:#fde68a,stroke:#333,stroke-width:2px
    style AzureDocIntel fill:#fde68a,stroke:#333,stroke-width:2px
    style AzureStorage fill:#fde68a,stroke:#333,stroke-width:2px
    style User fill:#fff,stroke:#333,stroke-width:2px
```
</details>

The architecture follows a vertical multi-agent design pattern where:

1. Users interact with the React frontend interface for natural language conversations and document uploads.
2. The Copilot Backend serves as the AI orchestration layer that hosts the multi-agent system.
3. A Router Agent analyzes user intent and delegates tasks to specialized domain agents:
   - Account Agent for handling account information requests
   - Transaction History Agent for retrieving transaction records
   - Payment Agent for processing payments and scanning invoices
4. Each agent uses Semantic Kernel to reason and execute operations via tools.
5. The OpenAPI Plugin maps natural language intents to structured API calls.
6. Business API services handle the actual banking operations.
7. Azure services provide the AI capabilities (Azure OpenAI) and document processing (Azure Document Intelligence).

This architecture enables a conversational interface to traditional banking services by leveraging AI to understand user intent and orchestrate appropriate actions across multiple specialized microservices.

#### Sequence Diagram

![Interactive Flow](https://github.com/user-attachments/assets/c4ab6904-e2fa-4f9a-963a-f7b2f8a049fe)

- [Mermaid Notation](README-Backend-Diagram.md)

This sequence diagram illustrates the flow of interactions in the application:

1. **Initial Request Processing**: The user interacts with the frontend, which forwards the request to the Copilot Backend.

2. **Intent Determination**: The Router Agent uses Azure OpenAI to analyze the user's intent and routes the request to the appropriate specialist agent.

3. **Agent-Specific Processing**:
   - For account information, the Account Agent communicates with both Azure OpenAI and the Account API to gather and present information.
   - For transaction history, the Transaction Agent retrieves and formats transaction data.
   - For payments, the Payment Agent might process document uploads, validate payment details, and execute transactions.

4. **Response Flow**: The response flows back through the system to the user with appropriate formatting and presentation.

Each agent follows a similar pattern of using Azure OpenAI to generate completions with tools, calling the appropriate business APIs, and formatting responses for the user, creating a consistent and natural conversational experience.

#### Class Diagram

![Class Diagram](https://github.com/user-attachments/assets/b084329a-f7d7-4bf6-aa5c-980cd9a1e3b8)

- [Mermaid Notation](README-Backend-Diagram.md)

The class diagram shows the key classes of the multi-agent banking application, including:

1. **Core Application Classes**:
   - `CopilotApplication`: The main Spring Boot application entry point
   - `ChatController`: Handles API requests from the frontend and coordinates with agents

2. **Agent System**:
   - `RouterAgent`: The central coordinator that analyzes intent and delegates to specialized agents
   - `PaymentAgent`: Processes payment requests and invoice scanning
   - `AccountAgent`: Handles account information requests
   - `TransactionsReportingAgent`: Manages transaction history queries
   - `IntentExtractor`: Uses Azure OpenAI to determine user intent from messages

3. **Domain Models**:
   - `Transaction`: Represents payment transactions with details
   - `Account`: Contains account information and payment methods
   - `Payment`: Represents a payment request
   - `PaymentMethodSummary`: Holds details about available payment methods

4. **Services**:
   - `TransactionService`: Manages transaction data storage and retrieval
   - `LoggedUserService`: Handles user authentication and context

5. **Semantic Kernel Integration**:
   - `SemanticKernelOpenAPIImporter`: Connects the AI agents to business APIs via OpenAPI definitions

Each agent follows a similar pattern of using Semantic Kernel to process natural language interactions, determine intent, and execute appropriate business logic through the OpenAPI plugin.

### Frontend Architecture

The frontend is a modern React application built with TypeScript that provides the user interface for interacting with the multi-agent banking system. It follows a component-based architecture with clear separation of concerns.

#### Component Diagram

![Frontend Architecture](https://github.com/user-attachments/assets/b845e55d-8d4a-4e90-849a-a8f39247145b)

- [Mermaid Notation](README-Frontend-Diagram.md)

#### Key Features and Components

1. **Routing and Layout**
   - Uses React Router for navigation
   - Main layout with header, navigation, and content areas
   - Chat page as the primary interface

2. **Component Hierarchy**
   - **QuestionInput**: Allows users to enter queries and upload attachments
   - **AnswerDisplay**: Shows AI-generated responses with formatting and citations
   - **UserChatMessage**: Displays user messages and attachments
   - **AnalysisPanel**: Shows thought processes and supporting content
   - **Examples**: Provides example queries for users to try

3. **API Communication**
   - RESTful API client for backend communication
   - Support for streaming responses for real-time AI generation
   - File upload functionality for document processing
   - Authentication token handling

4. **Authentication**
   - Azure AD integration via MSAL (Microsoft Authentication Library)
   - Token acquisition and management
   - Conditional rendering based on authentication status

5. **State Management**
   - React hooks for local state management
   - Configuration settings for AI behavior
   - Chat history and streaming state management

This frontend architecture provides a responsive and interactive user interface that enables natural conversation with the multi-agent banking system, seamlessly handling different types of queries, file uploads, and displaying AI-generated responses with supporting evidence.

## Demo

## Features

- feature:1
- feature:2

## Requirement

## Usage

### 🚀 Step-by-Step Deployment Guide (Using Azure Developer CLI)

🎯 Overview of `azd up` Steps
|Step| Description | What Happens|
|---|---|---|
|1| Authentication | Checks Azure login (azd auth login)|
|2| Environment Setup | Initializes or verifies Azure environment|
|3| Infrastructure Provisioning | Deploys Azure resources using Bicep|
|4| Application Build | Builds Docker images|
|5| Push Images | Pushes images to Azure Container Registry|
|6| Application Deployment | Deploys apps to Azure Container Apps|
|7| Output Information | Provides deployment details and URLs|

#### ✅ Prerequisites
- Azure Subscription
- Azure CLI (az) installed
- Azure Developer CLI (azd) installed ([Installation Guide](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd?tabs=winget-windows%2Cbrew-mac%2Cscript-linux&pivots=os-linux))
- Docker installed
- GitHub account (for CI/CD automation)

#### 🛠️ Step 1: Clone and Navigate to Project

```bash
git clone <your-repo-url>
cd getting-started-with-multi-agent-java-app
```

#### 🔑 Step 2: Login to Azure

```bash
az login
```

#### ⚙️ Step 3: Initialize Azure Developer CLI Environment

```bash
azd init
```

#### 🏗️ Step 4: Provision Infrastructure and Deploy Application
Run the following command to provision Azure resources and deploy your application:

```bash
azd up
```

This command will:

- Provision Azure resources defined in main.bicep
- Build and push Docker images to Azure Container Registry
- Deploy your application services to Azure Container Apps

#### 📦 Step 5: Verify Deployment
After deployment, azd will output URLs and resource names. You can also verify resources in the Azure Portal:

- **Azure Container Apps:** Check deployed services (frontend, backend, APIs).
- **Azure OpenAI & Document Intelligence:** Verify AI services.
- **Azure Storage Account:** Check blob storage.
- **Application Insights:** Monitor application performance and logs.

<details>
<summary>Click to expand</summary>

```bash
  (✓) Done: Resource group: rg-shinyay-demo (3.564s)
  (✓) Done: Log Analytics workspace: log-duqxwgc4mdkmm (20.095s)
  (✓) Done: Storage account: stduqxwgc4mdkmm (25.746s)
  (✓) Done: Application Insights: appi-duqxwgc4mdkmm (4.182s)
  (✓) Done: Azure OpenAI: cog-duqxwgc4mdkmm (40.139s)
  (✓) Done: Azure AI Services Model Deployment: cog-duqxwgc4mdkmm/gpt-4o (40.563s)
  (✓) Done: Document Intelligence: cog-fr-duqxwgc4mdkmm (40.446s)
  (✓) Done: Container Registry: crduqxwgc4mdkmm (38.556s)
  (✓) Done: Container Apps Environment: cae-duqxwgc4mdkmm (55.455s)
  (✓) Done: Container App: ca-transaction-duqxwgc4mdkmm (31.304s)
  (✓) Done: Container App: ca-account-duqxwgc4mdkmm (31.581s)
  (✓) Done: Container App: ca-payment-duqxwgc4mdkmm (33.404s)
  (✓) Done: Container App: ca-copilot-duqxwgc4mdkmm (26.941s)
  (✓) Done: Container App: ca-web-duqxwgc4mdkmm (32.686s)

Deploying services (azd deploy)

  (✓) Done: Deploying service account
  - Endpoint: https://ca-account-duqxwgc4mdkmm.internal.greenbeach-f4c6d4b9.eastus2.azurecontainerapps.io/

  (✓) Done: Deploying service copilot
  - Endpoint: https://ca-copilot-duqxwgc4mdkmm.internal.greenbeach-f4c6d4b9.eastus2.azurecontainerapps.io/

  (✓) Done: Deploying service payment
  - Endpoint: https://ca-payment-duqxwgc4mdkmm.internal.greenbeach-f4c6d4b9.eastus2.azurecontainerapps.io/

  (✓) Done: Deploying service transaction
  - Endpoint: https://ca-transaction-duqxwgc4mdkmm.internal.greenbeach-f4c6d4b9.eastus2.azurecontainerapps.io/

  (✓) Done: Deploying service web
  - Endpoint: https://ca-web-duqxwgc4mdkmm.greenbeach-f4c6d4b9.eastus2.azurecontainerapps.io/
```

</details>

#### 🔐 Step 6: Configure Authentication and Security
Your application uses Azure AD and Managed Identities:

- Managed Identities are provisioned automatically by Bicep templates.
- Ensure Azure AD authentication is configured correctly in your frontend (MSAL) and backend (Managed Identity).

#### 📈 Step 7: Monitoring and Logging

- **Azure Monitor** and **Application Insights** are provisioned automatically.
- Use Azure Portal → Application Insights to monitor application performance and logs.

### 🔄 Optional: Local Development with Docker Compose

#### Step 1: Login to Azure

```bash
az login
```

#### Step 2: Local Development with Docker Compose

```bash
cd app
./start-compose.sh
```
or
```shell
cd app
./start-compose.fish
```

#### Step 3. Browse the App

- Open your browser and navigate to:
  - http://localhost

### 🚦 Optional: Kubernetes Deployment
This project includes Kubernetes manifests. To deply to `Azure Kubernetes Services`(AKS):

1. Ensure AKS Cluster is provisioned.
2. Update image references in manifests.
3. Deploy the application using Kubernetes manifests.

```bash
kubectl apply -f ./app/copilot/copilot-backend/manifests/
kubectl apply -f ./app/frontend/manifests/frontend-deployment.tmpl.yml
```

## Installation

## References

- [Azure Samples - Agent OpenAI Java Banking Assistant](https://github.com/Azure-Samples/agent-openai-java-banking-assistant)

## Licence

Released under the [MIT license](https://gist.githubusercontent.com/shinyay/56e54ee4c0e22db8211e05e70a63247e/raw/f3ac65a05ed8c8ea70b653875ccac0c6dbc10ba1/LICENSE)

## Author

- github: <https://github.com/shinyay>
- twitter: <https://twitter.com/yanashin18618>
- mastodon: <https://mastodon.social/@yanashin>
