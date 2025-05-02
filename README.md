
# LeadAccountMatching

A Salesforce solution to automatically match Leads to existing Accounts based on email domains and company name similarity using Apex triggers, custom metadata, and the Levenshtein distance algorithm.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Components](#components)
  - [Apex Classes](#apex-classes)
  - [Apex Trigger](#apex-trigger)
  - [Custom Metadata](#custom-metadata)
  - [Custom Labels](#custom-labels)
  - [Reports and Dashboards](#reports-and-dashboards)
- [Configuration](#configuration)
- [Usage](#usage)
- [Testing](#testing)

---

## Overview

The **LeadAccountMatching** project automates the process of associating incoming Salesforce Leads with existing Accounts. It matches Leads to Accounts by comparing email domains and calculating company name similarity using the Levenshtein distance algorithm. The solution is highly configurable via custom metadata and custom labels, ensuring flexibility and maintainability.

---

## Features

- **Email Domain Matching**: Groups Leads by email domain and matches them to Accounts with the same domain.
- **Company Name Normalization**: Removes noise words (e.g., "Inc", "LLC") and applies synonyms for consistent matching using custom label.
- **Levenshtein Similarity**: Uses the Levenshtein distance algorithm to compute company name similarity.
- **Configurable Thresholds**: Matching threshold is defined in a custom label.
- **Bulk Processing**: Optimized for large datasets.
- **Custom Metadata for Synonyms**: Stores company name synonyms to improve matching accuracy.
- **Reports and Dashboards**: Provides insights into lead-to-account matching success rates and unmatched leads.

---

## Architecture

The solution follows a modular architecture:

- **Trigger**: `LeadTrigger` captures Lead events.
- **Handler**: `LeadTriggerHandler` processes Leads.
- **Processor**: `LeadAccountMatchingProcessor` filters and prepares Leads for matching.
- **Service**: `LeadAccountMatchingService` performs domain grouping, account retrieval, similarity calculations and Account Matching.
- **Utilities**: `ConstantsUtils` manages configuration settings like thresholds and noise words.

---

## Components

### Custom Field

- **Account__c**: Created on the Lead object to store the matching account. This field established the lookup relationship between Account and Lead object.
- **WebsiteDomain__c**: Created on the Account object to extract the domain from the website field to elimate the costly extraction during the runtime.

### Permission Set:

- **LeadAccountMatchAccess** : Used to assign read permission to the `Account__c` field on the Lead object and `WebsiteDomain__c` field on the 'Account' Object.

### Apex Classes

- **LeadTriggerHandler**: Extends `BaseTriggerHandler` and invokes the processor.
- **LeadAccountMatchingProcessor**: Filters Leads and calls the service layer.
- **LeadAccountMatchingService**: 
  - Groups Leads by domain.
  - Queries Domain matching Accounts.
  - Normalizes company names.
  - Calculates similarity.
  - Assigns best match to `Account__c` field on the Lead.
- **ConstantsUtils**: Retrieves values from custom labels.

### Apex Trigger

- **LeadTrigger**: A flexible trigger supporting all DML operations. Uses `TriggerDispatcher`.

### Custom Metadata

- **Company Name Synonyms**: Maps terms like "Corp" → "Corporation" to match the accounts with legal structure in short form and full form. We have the flexibility to add/remove as per our needs.

### Custom Labels

- **LeadMatchingThreshold**: Defines similarity threshold (e.g., 60%).
- **NoiseWords**: Words like "Inc", "LLC" to be removed in normalization. We have the flexibility to add/ remove based on our needs.

### Reports and Dashboards

- **Lead Matching Success Report**: Shows the matched leads metrics
- **Unmatched Leads Report** : Shows the unmatched lead metrics
- **Lead Matching Dashboard** : Shows both matched and unmatched leads metrics

---

## Configuration

### Custom Metadata

1. Go to **Setup > Custom Metadata Types > Company Name Synonyms**.
2. Click **Manage Records**.
3. Add entries like:
   - `Corp` → `Corporation`
   - `Tech` → `Technology`
   - `Intl` → `International`

### Custom Labels

1. Go to **Setup > Custom Labels**.
2. Update or create:
   - **LeadMatchingThreshold**: `60.0`
   - **NoiseWords**: `Inc,LLC,Co,Corp,Technologies,Intl`

### Account Field

- Ensure the `WebsiteDomain__c` field exists on the **Account** object. It populates with the domain name from the account website.

### Lead Field

- Ensure the `Account__c` lookup field exists on the **Lead** object.
- Used to store the matched Account ID.

### Lead Field

- Ensure Assigning `LeadAccountMatchAccess` Permissionset to the required users.
  
---

## Usage

1. Create or update a Lead with valid **Email** and **Company**.
2. The `LeadTrigger` invokes matching logic:
   - Extracts domain
   - Queries Accounts
   - Normalizes names and computes similarity
   - Assigns best match if above threshold
3. Monitor results with dashboards/reports.

---

## Testing

### Unit Tests

Should cover:

- Exact matches
- Fuzzy matches
- Edge cases (e.g., missing emails)

### Manual Testing

- Create various Leads
- Check `Account__c` field
- Use reports for review

### Test Configuration

- Use `SObjectTriggerSetting` and `SObjectTriggerActionSetting` in the custom metadata to turn on and off the Lead Trigger and Lead Account Matching Logic for everyone or for specific users/profiles using custom permissions.

---

## Installing the app using a Scratch Org

1. Set up your environment. The steps include:

    - Enable Dev Hub in your Org
    - Install Salesforce CLI
    - Install Visual Studio Code
    - Install the Visual Studio Code Salesforce extensions

1. If you haven't already updated your CLI, update using the below command:

    ```
    sf update
    ```
    
1. Create an alias **DevHub** by using **-a** and make this the default org using **-d**. To authorize the Dev Hub, in the command window enter the web login flow. The following command opens the Salesforce login page in the web browser:

    ```
    sf org login web -d -a DevHub
    ```
     - Log in using your Dev Hub org credentials. Please note that this is a special org for Salesforce DX. You must use a Dev Hub enabled org for this project.
     - Click **Allow**.
       
1. Clone the LeadAccountMatching repository:

    ```
    git clone https://github.com/Subramanik/LeadAccountMatching.git
    ```
    
1. Open the above cloned folder `LeadAccountMatching` in your VS Code.

1. Create a scratch org and provide it with an alias (**leadAccountMatching** in the command below):

    ```
    sf org create scratch -d -f config/project-scratch-def.json -a leadAccountMatching
    ```

1. Push the app to your scratch org:

    ```
    sf project deploy start
    ```

1. Open your scratch org:

    ```
    sf org open
    ```

1. Assign `LeadAccountMatchAccess` permissionset your user.

1. 

## Questions and Feedbacks

- Reach out to **`subramani.rkumarasamy@gmail.com`**
