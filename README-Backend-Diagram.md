# Backend Architecture

## Sequence Diagram

<details>
<summary>Mermaid Diagram</summary>

```mermaid
sequenceDiagram
    participant User
    participant Frontend as Frontend (React)
    participant Copilot as Copilot Backend
    participant Router as Router Agent
    participant Account as Account Agent
    participant Transaction as Transaction Agent
    participant Payment as Payment Agent
    participant OpenAI as Azure OpenAI
    participant DocIntel as Document Intelligence
    participant APIs as Business APIs

    User->>Frontend: Sends message or uploads document
    Frontend->>Copilot: Forwards request

    Copilot->>OpenAI: Request conversation history analysis
    OpenAI-->>Copilot: Returns analysis

    Copilot->>Router: Determine user intent
    Router->>OpenAI: Extract intent from message
    OpenAI-->>Router: Return intent classification

    alt Account Information Request
        Router->>Account: Route to Account Agent
        Account->>OpenAI: Generate completion with tools
        OpenAI-->>Account: Suggest tool calls
        Account->>APIs: Call Account API
        APIs-->>Account: Return account data
        Account->>OpenAI: Format response
        OpenAI-->>Account: Generate final response
        Account-->>Router: Return formatted response

    else Transaction History Request
        Router->>Transaction: Route to Transaction Agent
        Transaction->>OpenAI: Generate completion with tools
        OpenAI-->>Transaction: Suggest tool calls
        Transaction->>APIs: Call Transaction API
        APIs-->>Transaction: Return transaction data
        Transaction->>OpenAI: Format response
        OpenAI-->>Transaction: Generate final response
        Transaction-->>Router: Return formatted response

    else Payment Request
        Router->>Payment: Route to Payment Agent

        alt Document Upload
            Payment->>DocIntel: Process uploaded invoice
            DocIntel-->>Payment: Extract invoice data
            Payment->>OpenAI: Validate and format data
            OpenAI-->>Payment: Formatted invoice data
        end

        Payment->>OpenAI: Generate completion with tools
        OpenAI-->>Payment: Suggest tool calls
        Payment->>APIs: Verify funds & payment methods
        APIs-->>Payment: Return verification
        Payment->>APIs: Submit payment
        APIs-->>Payment: Confirm payment status
        Payment->>OpenAI: Format response
        OpenAI-->>Payment: Generate final response
        Payment-->>Router: Return formatted response

    else Unknown Intent
        Router-->>Copilot: Request clarification
    end

    Router-->>Copilot: Return agent response
    Copilot-->>Frontend: Return formatted response
    Frontend-->>User: Display response
```
</details>

This sequence diagram illustrates the flow of interactions in the application:

1. **Initial Request Processing**: The user interacts with the frontend, which forwards the request to the Copilot Backend.

2. **Intent Determination**: The Router Agent uses Azure OpenAI to analyze the user's intent and routes the request to the appropriate specialist agent.

3. **Agent-Specific Processing**:
   - For account information, the Account Agent communicates with both Azure OpenAI and the Account API to gather and present information.
   - For transaction history, the Transaction Agent retrieves and formats transaction data.
   - For payments, the Payment Agent might process document uploads, validate payment details, and execute transactions.

4. **Response Flow**: The response flows back through the system to the user with appropriate formatting and presentation.

Each agent follows a similar pattern of using Azure OpenAI to generate completions with tools, calling the appropriate business APIs, and formatting responses for the user, creating a consistent and natural conversational experience.

## Class Diagram

<details>
<summary>Mearmaid Diagram</summary>

```mermaid
classDiagram
    %% Main Application Classes
    class CopilotApplication {
        +main(String[] args): void
    }

    %% Controller Classes
    class ChatController {
        -RouterAgent agentRouter
        +ChatController(RouterAgent)
        +openAIAsk(ChatAppRequest): ResponseEntity~ChatResponse~
        -convertSKChatHistory(ChatAppRequest): ChatHistory
    }

    %% Agent Classes
    class RouterAgent {
        -IntentExtractor intentExtractor
        -PaymentAgent paymentAgent
        -TransactionsReportingAgent historyReportingAgent
        -AccountAgent accountAgent
        -ToolsExecutionCache toolsExecutionCache
        +RouterAgent(LoggedUserService, ToolsExecutionCache, OpenAIAsyncClient, DocumentIntelligenceClient, BlobStorageProxy, String, String, String, String)
        +run(ChatHistory, AgentContext): void
        -routeToAgent(IntentResponse, ChatHistory, AgentContext): void
    }

    class PaymentAgent {
        -OpenAIAsyncClient client
        -Kernel kernel
        -ChatCompletionService chat
        -LoggedUserService loggedUserService
        -ToolsExecutionCache toolsExecutionCache
        -String PAYMENT_AGENT_SYSTEM_MESSAGE
        +PaymentAgent(OpenAIAsyncClient, LoggedUserService, ToolsExecutionCache, String, DocumentIntelligenceClient, BlobStorageProxy, String, String, String)
        +run(ChatHistory, AgentContext): void
    }

    class AccountAgent {
        -OpenAIAsyncClient client
        -Kernel kernel
        -ChatCompletionService chat
        -LoggedUserService loggedUserService
        -ToolsExecutionCache toolsExecutionCache
        -String ACCOUNT_AGENT_SYSTEM_MESSAGE
        +AccountAgent(OpenAIAsyncClient, LoggedUserService, ToolsExecutionCache, String, String)
        +run(ChatHistory, AgentContext): void
    }

    class TransactionsReportingAgent {
        -OpenAIAsyncClient client
        -Kernel kernel
        -ChatCompletionService chat
        -LoggedUserService loggedUserService
        -ToolsExecutionCache toolsExecutionCache
        -String HISTORY_AGENT_SYSTEM_MESSAGE
        +TransactionsReportingAgent(OpenAIAsyncClient, LoggedUserService, ToolsExecutionCache, String, String, String)
        +run(ChatHistory, AgentContext): void
    }

    class IntentExtractor {
        -OpenAIAsyncClient client
        -String modelId
        -String INTENT_PROMPT_TEMPLATE
        +IntentExtractor(OpenAIAsyncClient, String)
        +run(ChatHistory): IntentResponse
    }

    %% Request/Response Classes
    class ChatAppRequest {
        +String approach
        +List~HistoryChat~ messages
        +List~String~ attachments
        +ChatAppRequestContext context
        +boolean stream
    }

    class ChatResponse {
        +List~ResponseChoice~ choices
        +static buildChatResponse(ChatHistory, AgentContext): ChatResponse
    }

    %% Models - Business APIs
    class Transaction {
        +String id
        +String description
        +String type
        +String recipientName
        +String recipientBankReference
        +String accountId
        +String paymentType
        +String amount
        +String timestamp
    }

    class Account {
        +String id
        +String userName
        +String accountHolderFullName
        +String currency
        +String activationDate
        +String balance
        +List~PaymentMethodSummary~ paymentMethods
    }

    class Payment {
        +String description
        +String recipientName
        +String recipientBankCode
        +String accountId
        +String paymentMethodId
        +String paymentType
        +String amount
        +String timestamp
    }

    class PaymentMethodSummary {
        +String id
        +String type
        +String activationDate
        +String expirationDate
    }

    %% Service Classes
    class TransactionService {
        -Map~String,List~Transaction~~ lastTransactions
        -Map~String,List~Transaction~~ allTransactions
        +TransactionService()
        +getTransactionsByRecipientName(String, String): List~Transaction~
        +getlastTransactions(String): List~Transaction~
        +notifyTransaction(String, Transaction): void
    }

    class LoggedUserService {
        +getLoggedUser(): LoggedUser
        -getDefaultUser(): LoggedUser
    }

    %% Semantic Kernel Integration
    class SemanticKernelOpenAPIImporter {
        +builder(): Builder
        +fromSchema(String, String, HttpHeaders, HttpClient, Function): KernelPlugin
        -getHttpClient(HttpHeaders, HttpClient): HttpClient
        -getFunctions(HttpClient, String, Paths, String, HttpHeaders): Map
        -formOperation(HttpClient, String, String, String, PathItem, HttpHeaders): List
    }

    %% Relationships
    CopilotApplication ..> ChatController
    ChatController --> RouterAgent
    RouterAgent --> IntentExtractor
    RouterAgent --> PaymentAgent
    RouterAgent --> AccountAgent
    RouterAgent --> TransactionsReportingAgent

    PaymentAgent --> SemanticKernelOpenAPIImporter
    AccountAgent --> SemanticKernelOpenAPIImporter
    TransactionsReportingAgent --> SemanticKernelOpenAPIImporter

    PaymentAgent --> LoggedUserService
    AccountAgent --> LoggedUserService
    TransactionsReportingAgent --> LoggedUserService

    %% Business relationships
    Transaction --o TransactionService
    TransactionService --* TransactionsReportingAgent
```
</details>

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
