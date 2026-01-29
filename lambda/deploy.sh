#!/bin/bash

# Park and Dial Lambda Deployment Script
# This script deploys the OAuth Lambda function to AWS

set -e  # Exit on error

echo "🚀 Starting Lambda deployment..."
echo ""

# Configuration
FUNCTION_NAME="park-and-dial-oauth"
ROLE_NAME="park-and-dial-oauth-role"
REGION="us-east-2"  # Force us-east-2 region
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "📋 Configuration:"
echo "   Function: $FUNCTION_NAME"
echo "   Region: $REGION"
echo "   Account: $ACCOUNT_ID"
echo ""

# Step 1: Create deployment package
echo "📦 Step 1: Creating deployment package..."
cd "$(dirname "$0")"
zip -r lambda-function.zip oauth-handler.js package.json > /dev/null 2>&1
echo "   ✅ Package created: lambda-function.zip"
echo ""

# Step 2: Create or verify IAM role (REQUIRED by Lambda)
echo "🔐 Step 2: Setting up IAM execution role..."
echo "   ℹ️  Lambda requires an IAM role to write logs to CloudWatch"
if aws iam get-role --role-name $ROLE_NAME > /dev/null 2>&1; then
    echo "   ℹ️  Role '$ROLE_NAME' already exists - using it"
else
    echo "   Creating new role '$ROLE_NAME'..."
    aws iam create-role \
        --role-name $ROLE_NAME \
        --assume-role-policy-document file://trust-policy.json \
        > /dev/null
    
    echo "   Attaching basic execution policy (allows CloudWatch logs only)..."
    aws iam attach-role-policy \
        --role-name $ROLE_NAME \
        --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
    
    echo "   Waiting for role to propagate..."
    sleep 10
fi

ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"
echo "   ✅ Role ARN: $ROLE_ARN"
echo ""

# Step 3: Create or update Lambda function
echo "⚡ Step 3: Deploying Lambda function to $REGION..."
if aws lambda get-function --function-name $FUNCTION_NAME --region $REGION > /dev/null 2>&1; then
    echo "   Updating existing function..."
    aws lambda update-function-code \
        --function-name $FUNCTION_NAME \
        --region $REGION \
        --zip-file fileb://lambda-function.zip \
        > /dev/null
    
    echo "   Updating configuration..."
    aws lambda update-function-configuration \
        --function-name $FUNCTION_NAME \
        --region $REGION \
        --timeout 30 \
        --memory-size 128 \
        > /dev/null
    
    echo "   ✅ Function updated"
else
    echo "   Creating new function..."
    aws lambda create-function \
        --function-name $FUNCTION_NAME \
        --region $REGION \
        --runtime nodejs20.x \
        --role $ROLE_ARN \
        --handler oauth-handler.handler \
        --zip-file fileb://lambda-function.zip \
        --timeout 30 \
        --memory-size 128 \
        --description "OAuth handler for park-and-dial GitHub Pages app" \
        > /dev/null
    
    echo "   ✅ Function created"
    echo "   Waiting for function to be active..."
    sleep 5
fi
echo ""

# Step 4: Create Function URL if it doesn't exist
echo "🌐 Step 4: Setting up Function URL..."
FUNCTION_URL=$(aws lambda get-function-url-config --function-name $FUNCTION_NAME --region $REGION --query 'FunctionUrl' --output text 2>/dev/null || echo "")

if [ -z "$FUNCTION_URL" ]; then
    echo "   Creating Function URL..."
    FUNCTION_URL=$(aws lambda create-function-url-config \
        --function-name $FUNCTION_NAME \
        --region $REGION \
        --auth-type NONE \
        --cors '{
            "AllowOrigins": ["https://wxsd-sales.github.io"],
            "AllowMethods": ["GET", "OPTIONS"],
            "AllowHeaders": ["Content-Type"],
            "MaxAge": 86400
        }' \
        --query 'FunctionUrl' \
        --output text)
    echo "   ✅ Function URL created"
else
    echo "   ℹ️  Function URL already exists"
    
    # Update CORS configuration
    aws lambda update-function-url-config \
        --function-name $FUNCTION_NAME \
        --region $REGION \
        --cors '{
            "AllowOrigins": ["https://wxsd-sales.github.io"],
            "AllowMethods": ["GET", "OPTIONS"],
            "AllowHeaders": ["Content-Type"],
            "MaxAge": 86400
        }' \
        > /dev/null
    echo "   ✅ CORS configuration updated"
fi
echo ""

# Step 5: Add public invoke permission
echo "🔓 Step 5: Setting up permissions..."
aws lambda add-permission \
    --function-name $FUNCTION_NAME \
    --region $REGION \
    --statement-id FunctionURLAllowPublicAccess \
    --action lambda:InvokeFunctionUrl \
    --principal "*" \
    --function-url-auth-type NONE \
    2>/dev/null || echo "   ℹ️  Permission already exists"
echo "   ✅ Permissions configured"
echo ""

# Display summary
echo "════════════════════════════════════════════════════════════════"
echo "✅ DEPLOYMENT COMPLETE!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "🔗 Lambda Function URL:"
echo "   $FUNCTION_URL"
echo ""
echo "📝 Next Steps:"
echo ""
echo "1. Create Webex Integration at https://developer.webex.com/my-apps"
echo "   - Set Redirect URI to: $FUNCTION_URL"
echo "   - Copy Client ID and Client Secret"
echo ""
echo "2. Configure Lambda environment variables:"
echo "   Run: ./configure-env.sh"
echo "   (You'll be prompted for Client ID, Client Secret, etc.)"
echo ""
echo "3. Update index.html CONFIG section with:"
echo "   - OAUTH_LAMBDA_URL: $FUNCTION_URL"
echo "   - CLIENT_ID: (from Webex Integration)"
echo ""
echo "4. Deploy to GitHub Pages:"
echo "   git add ."
echo "   git commit -m 'Add OAuth configuration'"
echo "   git push"
echo ""
echo "════════════════════════════════════════════════════════════════"

