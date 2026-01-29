# AWS Lambda OAuth Handler Deployment Guide

This Lambda function handles the Webex OAuth Authorization Code flow for the park-and-dial GitHub Pages app.

## Prerequisites

- AWS Account
- AWS CLI installed and configured (optional but recommended)
- Webex Integration created at https://developer.webex.com/my-apps

## Step 1: Create the Webex Integration

1. Go to https://developer.webex.com/my-apps
2. Click "Create a New App" → "Integration"
3. Fill in the details:
   - **Name**: Park and Dial OAuth
   - **Description**: OAuth handler for park and dial app
   - **Redirect URI**: `https://YOUR-LAMBDA-FUNCTION-URL` (you'll update this after creating Lambda)
   - **Scopes**: Select the scopes you need (e.g., `spark:all`, `spark:people_read`)
4. Save and note down your **Client ID** and **Client Secret**

## Step 2: Create Lambda Deployment Package

From the `lambda` directory, run:

```bash
cd lambda
npm run package
```

This creates `lambda-function.zip` ready for upload.

## Step 3: Create Lambda Function in AWS Console

### 3.1 Create the Function

1. Go to AWS Lambda Console: https://console.aws.amazon.com/lambda
2. Click "Create function"
3. Choose "Author from scratch"
4. Configure:
   - **Function name**: `park-and-dial-oauth`
   - **Runtime**: Node.js 20.x (or latest)
   - **Architecture**: x86_64
   - **Permissions**: Create a new role with basic Lambda permissions
5. Click "Create function"

### 3.2 Upload Code

1. In the "Code" tab, click "Upload from" → ".zip file"
2. Upload the `lambda-function.zip` file
3. Click "Save"

### 3.3 Set Environment Variables

1. Go to "Configuration" tab → "Environment variables"
2. Click "Edit" and add these variables:
   - `CLIENT_ID`: Your Webex Integration Client ID
   - `CLIENT_SECRET`: Your Webex Integration Client Secret
   - `REDIRECT_URI`: (wait for next step to get Lambda URL)
   - `GITHUB_PAGES_URL`: `https://wxsd-sales.github.io/park-and-dial`
3. Click "Save"

### 3.4 Configure Function Settings

1. Go to "Configuration" tab → "General configuration"
2. Click "Edit"
3. Set **Timeout** to 30 seconds (default 3 seconds may be too short)
4. Click "Save"

## Step 4: Create Lambda Function URL

1. In your Lambda function, go to "Configuration" tab → "Function URL"
2. Click "Create function URL"
3. Configure:
   - **Auth type**: NONE (public access)
   - **Cross-origin resource sharing (CORS)**: Check "Configure CORS"
      - **Allow origin**: `https://wxsd-sales.github.io`
      - **Allow methods**: GET, OPTIONS
      - **Allow headers**: Content-Type
4. Click "Save"
5. **Copy the Function URL** - it will look like: `https://abcd1234.lambda-url.us-east-1.on.aws/`

## Step 5: Update Environment Variables with Function URL

1. Go back to "Configuration" → "Environment variables"
2. Click "Edit"
3. Update `REDIRECT_URI` with your Lambda Function URL
4. Click "Save"

## Step 6: Update Webex Integration Redirect URI

1. Go back to https://developer.webex.com/my-apps
2. Edit your Integration
3. Update the **Redirect URI** to your Lambda Function URL
4. Save

## Step 7: Update GitHub Pages Frontend

The `index.html` file needs to be updated with your Lambda Function URL. Update this line:

```javascript
const OAUTH_LAMBDA_URL = 'YOUR-LAMBDA-FUNCTION-URL'; // Replace with your actual Lambda URL
```

## Testing

1. Deploy your updated `index.html` to GitHub Pages
2. Visit https://wxsd-sales.github.io/park-and-dial/
3. Click "Login with Webex"
4. Authorize the integration
5. You should be redirected back with an access token

## Troubleshooting

### Check Lambda Logs

1. Go to Lambda function → "Monitor" tab → "View CloudWatch logs"
2. Look for errors in the latest log stream

### Common Issues

- **CORS errors**: Make sure Function URL CORS settings include your GitHub Pages domain
- **Timeout errors**: Increase Lambda timeout in Configuration → General configuration
- **Token exchange fails**: Verify CLIENT_ID, CLIENT_SECRET, and REDIRECT_URI are correct
- **Redirect URI mismatch**: Ensure Webex Integration redirect URI matches Lambda Function URL exactly

## Cost

AWS Lambda Free Tier includes:
- 1 million requests per month
- 400,000 GB-seconds of compute time per month

This should be more than sufficient for your use case and will likely cost $0.

## Security Notes

- Client secret is securely stored in Lambda environment variables
- Access tokens are passed via URL fragment (#) to keep them client-side only
- Consider adding AWS API Gateway with custom domain and rate limiting for production use

