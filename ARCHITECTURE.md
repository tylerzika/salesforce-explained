# JWT Authentication Flow for Salesforce

## Overview

This diagram shows how JWT Bearer Flow works for authenticating to Salesforce in CI/CD pipelines.

```
┌─────────────────────────────────────────────────────────────────┐
│                    JWT Authentication Flow                       │
└─────────────────────────────────────────────────────────────────┘

    ┌──────────────┐                                  ┌──────────────┐
    │   CI/CD      │                                  │  Salesforce  │
    │  Pipeline    │                                  │   Org/DevHub │
    │              │                                  │              │
    │  (GitHub     │                                  │              │
    │   Actions)   │                                  │              │
    └──────┬───────┘                                  └──────┬───────┘
           │                                                 │
           │  1. Generate JWT Token                         │
           │     - Sign with Private Key                    │
           │     - Include Consumer Key                     │
           │     - Include Username                         │
           │                                                 │
           │  2. Send JWT to Salesforce Token Endpoint      │
           ├────────────────────────────────────────────────>│
           │                                                 │
           │                                                 │  3. Verify JWT
           │                                                 │     - Check signature
           │                                                 │     - Validate user
           │                                                 │     - Check Connected App
           │                                                 │
           │  4. Return Access Token                        │
           │<────────────────────────────────────────────────┤
           │                                                 │
           │  5. Use Access Token for API Calls             │
           ├────────────────────────────────────────────────>│
           │                                                 │
           │  6. Create Scratch Org / Deploy / Test         │
           ├────────────────────────────────────────────────>│
           │                                                 │
```

## Key Components

### 1. Private Key & Certificate
- **server.key**: Private key (keep secret!)
- **server.crt**: Public certificate (upload to Connected App)
- Generated using OpenSSL

### 2. Connected App
- Created in Salesforce Setup
- Configured with OAuth and Digital Signatures
- Provides Consumer Key (Client ID)

### 3. Environment Variables
```
SF_USERNAME     → Salesforce user email
SF_CLIENT_ID    → Connected App Consumer Key
SF_JWT_KEY      → Private key content
```

### 4. Authentication Script
```bash
./scripts/auth.sh
```
- Creates JWT token
- Exchanges for access token
- Stores credentials for SF CLI

### 5. Scratch Org Script
```bash
./scripts/create-scratch-org.sh
```
- Uses authenticated Dev Hub
- Creates temporary Salesforce org
- Configures based on project-scratch-def.json

## Security Benefits

✅ **No Password Storage**: Uses cryptographic keys instead of passwords
✅ **Non-Interactive**: Perfect for automated pipelines
✅ **Revocable**: Can disable Connected App anytime
✅ **Scoped Access**: Limited to specified OAuth scopes
✅ **Auditable**: All authentication events logged in Salesforce

## Workflow Example

### Local Development
```bash
# 1. Set environment variables
export SF_USERNAME="dev@company.com"
export SF_CLIENT_ID="3MVG9..."
export SF_JWT_KEY="$(cat server.key)"

# 2. Authenticate
./scripts/auth.sh

# 3. Create scratch org
./scripts/create-scratch-org.sh "feature-branch" 7

# 4. Work with the org
sf org open
```

### CI/CD Pipeline (GitHub Actions)
```yaml
# Secrets are set in GitHub repository settings
- name: Authenticate to Dev Hub
  env:
    SF_USERNAME: ${{ secrets.SF_USERNAME }}
    SF_CLIENT_ID: ${{ secrets.SF_CLIENT_ID }}
    SF_JWT_KEY: ${{ secrets.SF_JWT_KEY }}
  run: ./scripts/auth.sh

- name: Create Scratch Org
  run: ./scripts/create-scratch-org.sh "CI-Test" 1
```

## Troubleshooting

| Error | Solution |
|-------|----------|
| "user hasn't approved this consumer" | Pre-approve users in Connected App or have user authenticate once |
| "invalid_grant" | Check certificate expiration and Consumer Key |
| "INVALID_LOGIN" | Verify username and API access |

## References

- [Salesforce JWT Flow Docs](https://help.salesforce.com/s/articleView?id=sf.remoteaccess_oauth_jwt_flow.htm)
- [SF CLI Auth Commands](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_org.htm)
