# Park & Dial - Setup Guide

A GitHub Pages app for parking calls and dialing extensions using Webex Calling APIs.

## Quick Setup

### 1. Create Webex Integration

1. Go to https://developer.webex.com/my-apps
2. Create new **Integration**
3. Set **Redirect URI** to: `YOUR-LAMBDA-URL` (get this after step 2)
4. Add these **Scopes**:
   - `spark:calls_write`
   - `spark:calls_read`
   - `spark:telephony_config_write`
   - `spark:telephony_config_read`
   - `spark:people_read`
   - `spark:kms`
   - `spark:xsi`
   - `spark:devices_read`
   - `spark:xapi_statuses`
   - `spark:xapi_commands`
   - `spark:rooms_read`
5. Save **Client ID** and **Client Secret**

### 2. Deploy Lambda Function (us-east-2)

```bash
cd lambda
zip -r lambda-function.zip oauth-handler.js package.json
```

Create Lambda via AWS Console or CLI:
```bash
aws lambda create-function \
  --function-name park-and-dial-oauth \
  --runtime nodejs20.x \
  --role arn:aws:iam::YOUR-ACCOUNT:role/lambda-execution-role \
  --handler oauth-handler.handler \
  --zip-file fileb://lambda-function.zip \
  --region us-east-2
```

Create Function URL:
```bash
aws lambda create-function-url-config \
  --function-name park-and-dial-oauth \
  --region us-east-2 \
  --auth-type NONE \
  --cors '{"AllowOrigins": ["https://wxsd-sales.github.io"], "AllowMethods": ["*"], "AllowHeaders": ["Content-Type"], "MaxAge": 86400}'
```

Add permissions:
```bash
aws lambda add-permission \
  --function-name park-and-dial-oauth \
  --region us-east-2 \
  --statement-id FunctionURLAllowPublicAccess \
  --action lambda:InvokeFunctionUrl \
  --principal "*" \
  --function-url-auth-type NONE
```

Set environment variables:
```bash
aws lambda update-function-configuration \
  --function-name park-and-dial-oauth \
  --region us-east-2 \
  --environment "Variables={
    CLIENT_ID=YOUR_CLIENT_ID,
    CLIENT_SECRET=YOUR_CLIENT_SECRET,
    REDIRECT_URI=YOUR_LAMBDA_FUNCTION_URL,
    GITHUB_PAGES_URL=https://wxsd-sales.github.io/park-and-dial
  }"
```

### 3. Update index.html

Edit the `CONFIG` section (around line 280):
```javascript
const CONFIG = {
    OAUTH_LAMBDA_URL: 'YOUR-LAMBDA-FUNCTION-URL',
    CLIENT_ID: 'YOUR-CLIENT-ID',
    SCOPES: 'spark:calls_write spark:telephony_config_write...',
    GITHUB_PAGES_URL: 'https://wxsd-sales.github.io/park-and-dial/'
};
```

### 4. Deploy to GitHub Pages

```bash
git add .
git commit -m "Configure OAuth"
git push
```

Enable GitHub Pages:
- Go to repo **Settings** → **Pages**
- Set source to **main** branch
- Save

Visit: `https://YOUR-ORG.github.io/YOUR-REPO/`

## Features

- **OAuth Login** - Secure authentication via AWS Lambda
- **Configurable Contacts** - Customize via settings (⚙️) or URL parameters
- **Park & Dial** - Park current call and dial extension
- **Endpoint Selection** - Choose which device dials calls
- **Shareable URLs** - Generate URLs with pre-configured contacts

## Usage

### Configure Contacts

Click ⚙️ button to edit contacts JSON:
```json
[
  { "name": "John Doe", "ext": "2341" },
  { "name": "Jane Smith", "ext": "1234" }
]
```

### Share Configuration

Click "Copy Shareable URL" to generate a URL with your contacts embedded.

### Park & Dial

1. Start a call on Webex
2. Click "Park & Dial" next to any contact
3. Current call is parked, new call dials the extension

## Requirements

- Webex Calling license
- Registered calling device (Webex app or desk phone)
- AWS account (for Lambda)
- GitHub account (for Pages)

## Troubleshooting

**No Active Call error:** Must be on a connected call to use Park & Dial

**Authentication failed:** Logout and login again

**Permission denied:** Verify Webex Calling license and OAuth scopes

**Lambda errors:** Check CloudWatch logs:
```bash
aws logs tail /aws/lambda/park-and-dial-oauth --region us-east-2 --follow
```

## Architecture

```
GitHub Pages (Frontend)
    ↓ OAuth redirect
AWS Lambda (Token Exchange)
    ↓ Access token
Webex APIs (Calling)
```

## Files

- `index.html` - Main application
- `lambda/oauth-handler.js` - OAuth token exchange
- `lambda/deploy.sh` - Deployment script

