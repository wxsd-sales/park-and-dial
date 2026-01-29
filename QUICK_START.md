# Quick Start Checklist

Follow these steps in order:

## ☐ 1. Create Webex Integration
- Go to: https://developer.webex.com/my-apps
- Create new Integration
- Save Client ID and Client Secret
- Use placeholder redirect URI for now

## ☐ 2. Package Lambda Function
```bash
cd lambda
npm run package
```

## ☐ 3. Deploy to AWS Lambda
- Create function in AWS Console
- Upload `lambda-function.zip`
- Create Function URL
- Save the Function URL

## ☐ 4. Configure Lambda
Add environment variables:
- `CLIENT_ID` = (from step 1)
- `CLIENT_SECRET` = (from step 1)
- `REDIRECT_URI` = (Function URL from step 3)
- `GITHUB_PAGES_URL` = `https://wxsd-sales.github.io/park-and-dial`

## ☐ 5. Update Webex Integration
- Edit integration at https://developer.webex.com/my-apps
- Set Redirect URI to your Lambda Function URL

## ☐ 6. Update index.html
Edit the CONFIG object with:
- `OAUTH_LAMBDA_URL` = (Lambda Function URL)
- `CLIENT_ID` = (Webex Client ID)

## ☐ 7. Deploy to GitHub
```bash
git add .
git commit -m "Add OAuth authentication"
git push
```

## ☐ 8. Test!
Visit: https://wxsd-sales.github.io/park-and-dial/

---

**Need detailed instructions?** See `SETUP.md`

**Lambda setup help?** See `lambda/README.md`

