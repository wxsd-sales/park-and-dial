# OAuth Flow Diagram

## How the Authentication Works

```
┌─────────────┐
│   User      │
│  (Browser)  │
└──────┬──────┘
       │
       │ 1. Visits GitHub Pages
       ▼
┌─────────────────────────────┐
│   GitHub Pages              │
│   (Static HTML/JS)          │
│   wxsd-sales.github.io      │
└──────┬──────────────────────┘
       │
       │ 2. Clicks "Login with Webex"
       │    Redirects to Webex OAuth
       ▼
┌─────────────────────────────┐
│   Webex OAuth Server        │
│   webexapis.com             │
└──────┬──────────────────────┘
       │
       │ 3. User authorizes app
       │    Webex redirects with code
       ▼
┌─────────────────────────────┐
│   AWS Lambda Function       │
│   (Your OAuth Handler)      │
│   *.lambda-url.*.on.aws     │
│                             │
│   - Receives code           │
│   - Exchanges for token     │
│     using CLIENT_SECRET     │
└──────┬──────────────────────┘
       │
       │ 4. Redirects to GitHub Pages
       │    with token in URL fragment (#)
       ▼
┌─────────────────────────────┐
│   GitHub Pages              │
│   (Static HTML/JS)          │
│                             │
│   - Extracts token from #   │
│   - Stores in localStorage  │
│   - Fetches user profile    │
│   - Shows app               │
└─────────────────────────────┘
```

## Detailed Step-by-Step

### Step 1: User Visits Page
```
URL: https://wxsd-sales.github.io/park-and-dial/
Action: index.html loads and checks localStorage for token
Result: No token found → Shows login screen
```

### Step 2: User Clicks Login
```
Browser redirects to:
https://webexapis.com/v1/authorize?
  client_id=YOUR_CLIENT_ID&
  response_type=code&
  redirect_uri=https://YOUR-LAMBDA-URL&
  scope=spark:all%20spark:people_read&
  state=/
```

### Step 3: User Authorizes
```
User logs in to Webex and authorizes the app
Webex redirects to Lambda with authorization code:
https://YOUR-LAMBDA-URL/?code=ABC123&state=/
```

### Step 4: Lambda Exchanges Code
```
Lambda makes POST request to:
https://webexapis.com/v1/access_token

Body:
  grant_type=authorization_code
  client_id=YOUR_CLIENT_ID
  client_secret=YOUR_CLIENT_SECRET  ← Kept secret in Lambda!
  code=ABC123
  redirect_uri=https://YOUR-LAMBDA-URL

Response:
{
  "access_token": "XYZ789...",
  "expires_in": 1209600,
  "refresh_token": "...",
  ...
}
```

### Step 5: Lambda Redirects Back
```
Lambda redirects browser to:
https://wxsd-sales.github.io/park-and-dial/#access_token=XYZ789&expires_in=1209600

Note: Using # (fragment) instead of ? (query) keeps token client-side only!
```

### Step 6: Page Processes Token
```javascript
// JavaScript in index.html:
1. Extracts token from URL fragment
2. Stores in localStorage:
   - webex_access_token
   - webex_token_expiry
3. Removes fragment from URL (clean URL)
4. Fetches user profile from Webex API
5. Shows authenticated app view
```

## Security Highlights

✅ **Client Secret never exposed**
- Stored securely in Lambda environment variables
- Never sent to browser
- Never in JavaScript code

✅ **Token in URL fragment**
- `#access_token=...` stays client-side
- Not sent in HTTP requests
- Not logged in server logs

✅ **CORS Protection**
- Lambda only accepts requests from your GitHub Pages domain
- Prevents other sites from using your OAuth endpoint

✅ **Token Expiry**
- Tokens expire after ~14 days
- Expiry time stored and checked
- User must re-authenticate when expired

## Why Lambda is Needed

**Without Lambda (IMPOSSIBLE):**
```
GitHub Pages → Webex OAuth → GitHub Pages with code
                               ↓
                          ❌ Cannot exchange code for token
                             (Requires CLIENT_SECRET)
```

**With Lambda (WORKS):**
```
GitHub Pages → Webex OAuth → Lambda (has secret)
                               ↓
                          ✅ Exchanges code for token
                               ↓
                          GitHub Pages with token
```

The Lambda function is the **only** part that knows your CLIENT_SECRET, making it impossible for someone to steal your secret by viewing your HTML/JavaScript source code.

