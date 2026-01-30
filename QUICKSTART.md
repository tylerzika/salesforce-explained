# Quick Setup Guide

## TL;DR - Get Started in 5 Minutes

### 1. Generate Certificate (One-time setup)
```bash
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr
openssl x509 -req -sha256 -days 365 -in server.csr -signkey server.key -out server.crt
```

### 2. Create Connected App in Salesforce
1. Go to Setup → Apps → App Manager → New Connected App
2. Enable OAuth Settings
3. Use digital signatures → Upload `server.crt`
4. OAuth Scopes: `api`, `refresh_token`, `web`
5. Save and copy the Consumer Key

### 3. Set Environment Variables

**For Local Testing:**
```bash
export SF_USERNAME="your.email@salesforce.com"
export SF_CLIENT_ID="your_consumer_key_from_step_2"
export SF_JWT_KEY="$(cat server.key)"
```

**For GitHub Actions:**
Add these as repository secrets:
- `SF_USERNAME` - Your Salesforce email
- `SF_CLIENT_ID` - Consumer Key from Connected App
- `SF_JWT_KEY` - Contents of server.key file

### 4. Authenticate
```bash
./scripts/auth.sh
```

### 5. Create Scratch Org
```bash
./scripts/create-scratch-org.sh "MyScratchOrg" 7
```

## What This Does

- **JWT Authentication**: Secure, non-interactive authentication perfect for CI/CD
- **Scratch Org Creation**: Automatically spin up temporary Salesforce environments
- **CI/CD Pipeline**: Automated testing on every push/PR

## Yes, This is CI/CD!

This setup enables:
- ✅ Automated authentication without interactive login
- ✅ Scratch org creation for isolated testing
- ✅ Continuous Integration via GitHub Actions
- ✅ Automated deployment and testing

See [AUTHENTICATION.md](AUTHENTICATION.md) for detailed documentation.
