# Salesforce Explained

A Salesforce DX project with CI/CD capabilities for automated authentication and scratch org management.

## Authentication & CI/CD Setup

This repository includes JWT-based authentication for CI/CD pipelines.

- **Quick Start**: See [QUICKSTART.md](QUICKSTART.md) for a 5-minute setup guide
- **Detailed Guide**: See [AUTHENTICATION.md](AUTHENTICATION.md) for comprehensive setup instructions

### Quick Start

1. Set up your Connected App in Salesforce (see [AUTHENTICATION.md](AUTHENTICATION.md))
2. Configure your environment variables or GitHub secrets
3. Run authentication: `./scripts/auth.sh`
4. Create a scratch org: `./scripts/create-scratch-org.sh "MyScratchOrg" 7`

### CI/CD Pipeline

The repository includes a GitHub Actions workflow that automatically:
- Authenticates to your Salesforce Dev Hub
- Creates a scratch org for testing
- Deploys your code
- Runs tests
- Cleans up resources

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
