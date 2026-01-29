/**
 * AWS Lambda function for Webex OAuth Authorization Code flow
 * This handles the OAuth callback and token exchange
 */

const https = require('https');

// Environment variables to set in Lambda
const CLIENT_ID = process.env.CLIENT_ID;
const CLIENT_SECRET = process.env.CLIENT_SECRET;
const REDIRECT_URI = process.env.REDIRECT_URI; // Your Lambda function URL
const GITHUB_PAGES_URL = process.env.GITHUB_PAGES_URL; // e.g., https://wxsd-sales.github.io/park-and-dial/

/**
 * Exchange authorization code for access token
 */
function getAccessToken(code) {
    return new Promise((resolve, reject) => {
        const postData = new URLSearchParams({
            grant_type: 'authorization_code',
            client_id: CLIENT_ID,
            client_secret: CLIENT_SECRET,
            code: code,
            redirect_uri: REDIRECT_URI
        }).toString();

        const options = {
            hostname: 'webexapis.com',
            path: '/v1/access_token',
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Content-Length': Buffer.byteLength(postData)
            }
        };

        const req = https.request(options, (res) => {
            let data = '';

            res.on('data', (chunk) => {
                data += chunk;
            });

            res.on('end', () => {
                if (res.statusCode === 200) {
                    resolve(JSON.parse(data));
                } else {
                    reject(new Error(`Token exchange failed: ${res.statusCode} - ${data}`));
                }
            });
        });

        req.on('error', (e) => {
            reject(e);
        });

        req.write(postData);
        req.end();
    });
}

/**
 * Lambda handler
 */
exports.handler = async (event) => {
    console.log('Event:', JSON.stringify(event, null, 2));

    // Handle preflight CORS requests
    if (event.requestContext?.http?.method === 'OPTIONS') {
        return {
            statusCode: 200,
            headers: {
                'Access-Control-Allow-Origin': GITHUB_PAGES_URL,
                'Access-Control-Allow-Methods': 'GET, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            body: ''
        };
    }

    try {
        // Extract query parameters
        const queryParams = event.queryStringParameters || {};
        const code = queryParams.code;
        const state = queryParams.state || '/';

        if (!code) {
            return {
                statusCode: 400,
                headers: {
                    'Content-Type': 'text/html'
                },
                body: '<h1>Error: Missing authorization code</h1>'
            };
        }

        // Exchange code for access token
        console.log('Exchanging code for token...');
        const tokenData = await getAccessToken(code);
        console.log('Token exchange successful');

        // Redirect back to GitHub Pages with token in URL fragment
        // Using fragment (#) instead of query (?) keeps token client-side only
        const redirectUrl = `${GITHUB_PAGES_URL}#access_token=${tokenData.access_token}&expires_in=${tokenData.expires_in}&state=${encodeURIComponent(state)}`;

        return {
            statusCode: 302,
            headers: {
                'Location': redirectUrl,
                'Cache-Control': 'no-cache, no-store, must-revalidate'
            },
            body: ''
        };

    } catch (error) {
        console.error('OAuth error:', error);
        
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'text/html'
            },
            body: `<h1>OAuth Error</h1><p>${error.message}</p><p><a href="${GITHUB_PAGES_URL}">Return to app</a></p>`
        };
    }
};

