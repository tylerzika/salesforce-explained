# Setup Checklist

Use this checklist to ensure you've completed all steps for JWT authentication setup.

## Prerequisites
- [ ] Salesforce Developer Org with Dev Hub enabled
- [ ] Salesforce CLI installed (`npm install -g @salesforce/cli`)
- [ ] OpenSSL installed (usually pre-installed on Mac/Linux)
- [ ] Admin access to your Salesforce org

## Step 1: Generate Certificate
- [ ] Run: `openssl genrsa -out server.key 2048`
- [ ] Run: `openssl req -new -key server.key -out server.csr`
- [ ] Run: `openssl x509 -req -sha256 -days 365 -in server.csr -signkey server.key -out server.crt`
- [ ] Verify files exist: `server.key`, `server.csr`, `server.crt`

## Step 2: Create Connected App in Salesforce
- [ ] Log in to your Salesforce org
- [ ] Navigate to Setup → Apps → App Manager
- [ ] Click "New Connected App"
- [ ] Fill in basic information (name, API name, contact email)
- [ ] Check "Enable OAuth Settings"
- [ ] Set Callback URL: `http://localhost:1717/OauthRedirect`
- [ ] Check "Use digital signatures"
- [ ] Upload `server.crt` file
- [ ] Add OAuth Scopes:
  - [ ] Access and manage your data (api)
  - [ ] Perform requests on your behalf at any time (refresh_token, offline_access)
  - [ ] Provide access to your data via the Web (web)
- [ ] Click "Save" then "Continue"
- [ ] Copy the Consumer Key (you'll need this as SF_CLIENT_ID)

## Step 3: Pre-Approve Users (Recommended)
- [ ] In Connected App, click "Edit Policies"
- [ ] Under OAuth Policies, set Permitted Users to "Admin approved users are pre-authorized"
- [ ] Click "Save"
- [ ] Click "Manage Profiles" or "Manage Permission Sets"
- [ ] Add your profile/permission set

## Step 4: Set Up Environment Variables

### For Local Development:
- [ ] Copy `.env.example` to `.env`
- [ ] Set `SF_USERNAME` to your Salesforce email
- [ ] Set `SF_CLIENT_ID` to the Consumer Key from Step 2
- [ ] Set `SF_JWT_KEY` to contents of `server.key` file
- [ ] Run: `source .env` (or add to your shell profile)

### For GitHub Actions:
- [ ] Go to your GitHub repository
- [ ] Navigate to Settings → Secrets and variables → Actions
- [ ] Add secret: `SF_USERNAME`
- [ ] Add secret: `SF_CLIENT_ID`
- [ ] Add secret: `SF_JWT_KEY` (paste entire contents of server.key)

## Step 5: Test Authentication
- [ ] Make scripts executable: `chmod +x scripts/*.sh`
- [ ] Run authentication: `./scripts/auth.sh`
- [ ] Verify success message: "Successfully authenticated to Salesforce Developer Hub!"
- [ ] Check org list: `sf org list`

## Step 6: Test Scratch Org Creation
- [ ] Run: `./scripts/create-scratch-org.sh "TestOrg" 1`
- [ ] Verify scratch org is created
- [ ] Open scratch org: `sf org open --target-org TestOrg`
- [ ] Delete test org: `sf org delete scratch --target-org TestOrg --no-prompt`

## Step 7: Verify CI/CD (GitHub Actions)
- [ ] Push changes to GitHub
- [ ] Go to Actions tab in GitHub
- [ ] Verify workflow runs successfully
- [ ] Check that scratch org is created and deleted

## Security Checklist
- [ ] `server.key` is NOT committed to git
- [ ] `.env` is NOT committed to git  
- [ ] `.gitignore` includes `server.key`, `.env`, `server.crt`, `server.csr`
- [ ] GitHub secrets are properly configured
- [ ] Connected App uses digital signatures (not client secret)
- [ ] Certificate expiration date is noted (check yearly)

## Troubleshooting
If authentication fails:
- [ ] Verify Consumer Key is correct
- [ ] Check username matches exactly
- [ ] Ensure certificate is uploaded correctly
- [ ] Verify user has API access enabled
- [ ] Check Connected App is pre-approved or user has logged in once
- [ ] Review Salesforce login history for authentication attempts

## Notes
- Certificates expire after 365 days - set a reminder!
- Keep `server.key` secure - treat it like a password
- You can rotate certificates by creating new ones and updating the Connected App
- For production use, consider using a longer certificate validity period

## Resources
- [Quick Start Guide](QUICKSTART.md)
- [Detailed Authentication Guide](AUTHENTICATION.md)
- [Architecture Documentation](ARCHITECTURE.md)
