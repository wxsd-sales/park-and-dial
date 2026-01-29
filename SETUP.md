# Park & Dial - AWS Lambda OAuth Setup Guide

This guide will walk you through setting up OAuth authentication for your Park & Dial GitHub Pages app using AWS Lambda.

## Overview

**Architecture:**
- **Frontend**: Hosted on GitHub Pages (static HTML/CSS/JS)
- **Backend**: Single AWS Lambda function for OAuth token exchange
- **Auth Flow**: Webex OAuth 2.0 Authorization Code flow

## Prerequisites

- [x] AWS Account
- [x] GitHub account (you already have this set up)
- [x] Webex account

## Step-by-Step Setup

### 1. Create Webex Integration

1. Go to https://developer.webex.com/my-apps
2. Click **"Create a New App"** → **"Integration"**
3. Fill in the details:
   ```
   Name: Park and Dial OAuth
   Icon: (optional - choose an icon or upload one)
   Description: OAuth handler for park and dial contact directory
   Redirect URI: https://PLACEHOLDER.com (we'll update this after creating Lambda)
   Scopes: 
     ☑ spark:all
     ☑ spark:people_read
   ```
4. Click **"Add Integration"**
5. **SAVE** your credentials:
   - **Client ID**: `Copy this value`
   - **Client Secret**: `Copy this value` ⚠️ Keep this secret!

### 2. Deploy AWS Lambda Function

#### 2.1 Create Deployment Package

```bash
cd /Users/tahanson/Documents/sales/park-and-dial/lambda
npm run package
```

This creates `lambda-function.zip`.

#### 2.2 Create Lambda Function

1. Open AWS Console: https://console.aws.amazon.com/lambda
2. Click **"Create function"**
3. Select **"Author from scratch"**
4. Configure:
   ```
   Function name: park-and-dial-oauth
   Runtime: Node.js 20.x (or latest available)
   Architecture: x86_64
   Execution role: Create a new role with basic Lambda permissions
   ```
5. Click **"Create function"**

#### 2.3 Upload Code

1. In the Lambda function page, go to **"Code"** tab
2. Click **"Upload from"** → **".zip file"**
3. Select `lambda-function.zip`
4. Click **"Save"**

#### 2.4 Create Function URL

1. Go to **"Configuration"** tab → **"Function URL"**
2. Click **"Create function URL"**
3. Configure:
   ```
   Auth type: NONE
   
   Configure cross-origin resource sharing (CORS): ☑ Checked
     Allowed origins: https://wxsd-sales.github.io
     Allowed methods: GET, OPTIONS
     Allowed headers: Content-Type
     Max age: 86400
   ```
4. Click **"Save"**
5. **COPY YOUR FUNCTION URL** - looks like:
   ```
   https://abcdef1234567890.lambda-url.us-east-1.on.aws/
   ```

#### 2.5 Configure Environment Variables

1. Still in **"Configuration"** tab → **"Environment variables"**
2. Click **"Edit"** → **"Add environment variable"** for each:
   ```
   CLIENT_ID = <Your Webex Client ID>
   CLIENT_SECRET = <Your Webex Client Secret>
   REDIRECT_URI = <Your Lambda Function URL from step 2.4>
   GITHUB_PAGES_URL = https://wxsd-sales.github.io/park-and-dial
   ```
3. Click **"Save"**

#### 2.6 Adjust Timeout

1. **"Configuration"** tab → **"General configuration"**
2. Click **"Edit"**
3. Set **Timeout** to `30 seconds`
4. Click **"Save"**

### 3. Update Webex Integration with Lambda URL

1. Return to https://developer.webex.com/my-apps
2. Click on your **"Park and Dial OAuth"** integration
3. Edit the **Redirect URI** field:
   ```
   Replace: https://PLACEHOLDER.com
   With: <Your Lambda Function URL>
   ```
4. Click **"Save"**

### 4. Update index.html Configuration

1. Open `index.html` in your editor
2. Find the `CONFIG` object (around line 167)
3. Update these values:
   ```javascript
   const CONFIG = {
       OAUTH_LAMBDA_URL: 'https://YOUR-ACTUAL-LAMBDA-URL.lambda-url.REGION.on.aws/',
       CLIENT_ID: 'YOUR-WEBEX-CLIENT-ID',
       SCOPES: 'spark:all spark:people_read',
       GITHUB_PAGES_URL: 'https://wxsd-sales.github.io/park-and-dial/'
   };
   ```

### 5. Deploy to GitHub Pages

```bash
cd /Users/tahanson/Documents/sales/park-and-dial
git add .
git commit -m "Add OAuth authentication with AWS Lambda"
git push
```

Wait 1-2 minutes for GitHub Pages to deploy.

### 6. Test Your App! 🎉

1. Visit: https://wxsd-sales.github.io/park-and-dial/
2. Click **"Login with Webex"**
3. Authorize the integration
4. You should be redirected back to your app, logged in!

## Troubleshooting

### "Failed to fetch user profile" or infinite redirects
- Check that `CLIENT_ID` and `CLIENT_SECRET` are correct in Lambda environment variables
- Verify `REDIRECT_URI` in Lambda matches your Function URL exactly
- Verify Webex Integration Redirect URI matches Lambda Function URL exactly

### CORS errors in browser console
- Check Lambda Function URL CORS settings include `https://wxsd-sales.github.io`
- Ensure both GET and OPTIONS methods are allowed

### Lambda timeout errors
- Increase timeout to 30 seconds in Lambda Configuration → General configuration

### Token exchange fails
- View CloudWatch logs: Lambda → Monitor → View CloudWatch logs
- Check for errors in the token exchange request
- Verify CLIENT_SECRET is correct

### Authorization code already used
- This happens if you refresh the callback page
- Just click "Login with Webex" again to get a new code

## Security Notes

✅ **Secure:**
- Client Secret stored in Lambda environment variables (encrypted at rest)
- Token passed via URL fragment (#) keeps it client-side only
- CORS configured to only allow your GitHub Pages domain

⚠️ **Important:**
- Access tokens stored in browser localStorage
- Anyone with access to the user's browser can access the token
- Tokens expire based on `expires_in` (typically 14 days for Webex)
- This is acceptable for a demo/internal tool, but consider additional security for production

## Cost Estimate

**AWS Lambda Free Tier:**
- 1,000,000 requests per month - FREE
- 400,000 GB-seconds compute - FREE

**Expected cost:** $0/month (well within free tier limits)

## Next Steps

Now that OAuth is working, you can:
1. Add actual Webex Calling API integration
2. Implement the "Park & Dial" functionality using Webex APIs
3. Store user preferences
4. Add more contacts or load from Webex directory

## Support

For questions or issues:
- Check AWS CloudWatch logs for Lambda errors
- Test OAuth flow step-by-step using browser dev tools
- Verify all URLs match exactly (trailing slashes matter!)

