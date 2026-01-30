# Salesforce Authentication Setup for CI/CD

This guide explains how to set up JWT-based authentication to your Salesforce Developer Org, which is commonly used in CI/CD pipelines.

## What is JWT Bearer Flow?

JWT (JSON Web Token) Bearer Flow is a secure authentication method that allows applications to authenticate to Salesforce without interactive login. This is essential for CI/CD pipelines where you need automated authentication.

## Prerequisites

1. A Salesforce Developer Hub org (or any org with DevHub enabled)
2. Salesforce CLI installed locally
3. Access to create Connected Apps in Salesforce

## Step 1: Create a Private Key and Certificate

First, you need to generate a private key and self-signed certificate:

```bash
# Generate private key
openssl genrsa -out server.key 2048

# Generate certificate signing request
openssl req -new -key server.key -out server.csr

# Generate self-signed certificate (valid for 365 days)
openssl x509 -req -sha256 -days 365 -in server.csr -signkey server.key -out server.crt
```

Keep the `server.key` file secure - you'll need it for authentication.

## Step 2: Create a Connected App in Salesforce

1. Log in to your Salesforce org
2. Go to **Setup** → **Apps** → **App Manager**
3. Click **New Connected App**
4. Fill in the basic information:
   - Connected App Name: `CI/CD Integration` (or any name you prefer)
   - API Name: Will auto-populate
   - Contact Email: Your email
5. Enable OAuth Settings:
   - Check **Enable OAuth Settings**
   - Callback URL: `http://localhost:1717/OauthRedirect`
   - Check **Use digital signatures**
   - Upload the `server.crt` file you created
   - Selected OAuth Scopes:
     - `Access and manage your data (api)`
     - `Perform requests on your behalf at any time (refresh_token, offline_access)`
     - `Provide access to your data via the Web (web)`
6. Click **Save**
7. Click **Continue**

## Step 3: Get the Consumer Key

After creating the Connected App:

1. Go back to **App Manager**
2. Find your Connected App and click the dropdown → **View**
3. Click **Manage Consumer Details**
4. Copy the **Consumer Key** (this is your `SF_CLIENT_ID`)

## Step 4: Pre-Approve the Connected App (Optional but Recommended)

1. In the Connected App details, click **Edit Policies**
2. Under **OAuth Policies**:
   - Permitted Users: Select **Admin approved users are pre-authorized**
3. Save
4. Go to **Manage Profiles** and add your profile

## Step 5: Set Up Environment Variables

You need three pieces of information:

1. **SF_USERNAME**: Your Salesforce username (email)
2. **SF_CLIENT_ID**: The Consumer Key from the Connected App
3. **SF_JWT_KEY**: The contents of your `server.key` file

### For Local Development

Create a `.env` file (don't commit this!):

```bash
export SF_USERNAME="your.email@example.com"
export SF_CLIENT_ID="your_consumer_key_here"
export SF_JWT_KEY="$(cat server.key)"
```

Source it before running scripts:
```bash
source .env
```

### For GitHub Actions (or other CI/CD)

Add these as secrets in your repository:

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Add three secrets:
   - `SF_USERNAME`: Your Salesforce username
   - `SF_CLIENT_ID`: The Consumer Key
   - `SF_JWT_KEY`: Paste the entire contents of `server.key` (including the BEGIN and END lines)

## Step 6: Test Authentication

Run the authentication script:

```bash
chmod +x scripts/auth.sh
./scripts/auth.sh
```

If successful, you should see: "Successfully authenticated to Salesforce Developer Hub!"

## Step 7: Create a Scratch Org

After authenticating, you can create a scratch org:

```bash
chmod +x scripts/create-scratch-org.sh
./scripts/create-scratch-org.sh "MyScratchOrg" 7
```

Parameters:
- First parameter: Scratch org alias (default: "ScratchOrg")
- Second parameter: Duration in days (default: 7, max: 30)

## Using in CI/CD

The GitHub Actions workflow (`.github/workflows/ci.yml`) is already configured to:

1. Authenticate to your Dev Hub using JWT
2. Create a scratch org
3. Deploy your code (if `force-app` directory exists)
4. Run tests
5. Clean up the scratch org

The workflow runs on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches
- Manual trigger (workflow_dispatch)

## Troubleshooting

### "user hasn't approved this consumer"

Your user needs to authenticate to the Connected App at least once, or you need to pre-approve users (see Step 4).

### "invalid_grant: expired access/refresh token"

Check that your certificate hasn't expired and that the Consumer Key is correct.

### "INVALID_LOGIN: Invalid username, password, security token; or user locked out"

Verify that:
- The username is correct (including any sandbox instance URLs)
- The Connected App is deployed and active
- Your user has API access enabled

## Security Best Practices

1. **Never commit** your `server.key` file to version control
2. Store secrets securely (use GitHub Secrets, environment variables, or secret managers)
3. Regularly rotate your certificates (before they expire)
4. Use IP restrictions on your Connected App if possible
5. Monitor your Connected App usage in Salesforce

## Additional Resources

- [Salesforce JWT Bearer Flow Documentation](https://help.salesforce.com/s/articleView?id=sf.remoteaccess_oauth_jwt_flow.htm)
- [Salesforce CLI Authentication Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_auth_jwt_flow.htm)
- [Connected App Setup](https://help.salesforce.com/s/articleView?id=sf.connected_app_create.htm)
