# Park & Dial Feature

This document explains how the Park & Dial functionality works in your app.

## 🎯 What is Park & Dial?

Park & Dial allows a user to:
1. **Park** their current active call to an extension
2. **Dial** that same extension to bring someone else into the conversation

This is useful for scenarios like:
- Transferring a call to someone who can help
- Bringing a subject matter expert into a customer call
- Escalating to a manager while keeping the original caller waiting

---

## 🔄 The Workflow

When a user clicks a **"Park & Dial"** button next to a contact:

### Step 1: Check for Active Call
```
GET https://webexapis.com/v1/telephony/calls
```

- Retrieves all active calls for the user
- Looks for a call with `state: "connected"`
- If no connected call found → Show error "No Active Call"
- If found → Save the `callId` and proceed

### Step 2: Park the Call
```
POST https://webexapis.com/v1/telephony/calls/park
Body: {
  "callId": "{CALL_ID_FROM_STEP_1}",
  "destination": "{EXTENSION}"
}
```

- Parks the active call to the selected extension
- The original caller is now on hold/parked
- The parked call can be retrieved by dialing that extension

### Step 3: Dial the Extension
```
POST https://webexapis.com/v1/telephony/calls/dial
Body: {
  "destination": "{EXTENSION}"
}
```

- Initiates a new call to the extension where the call was parked
- The user can now talk to the person at that extension
- That person can retrieve the parked call

---

## 💡 Example Scenario

**Setup:**
- User is on a call with a customer
- Customer has a billing question
- User wants to bring in the billing specialist (ext: 2341)

**Action:**
1. User clicks "Park & Dial" next to "John Doe (ext: 2341)"
2. App parks customer call to extension 2341
3. App dials John Doe at extension 2341
4. User tells John: "I parked a customer call on your extension, they have a billing question"
5. John retrieves the parked call and helps the customer

---

## 🎨 User Experience

### Success Flow:
```
1. Modal shows: "Checking for active calls..."
2. Modal updates: "Parking your current call to extension 2341..."
3. Modal updates: "Now dialing John Doe at extension 2341..."
4. Modal shows: "✅ Success! Call parked and now dialing..."
```

### Error Scenarios:

**No Active Call:**
```
❌ No Active Call
You must be on an active call to use Park & Dial.
Please start a call and try again.
```

**Authentication Error (401):**
```
❌ Error
Authentication failed. Please try logging out and back in.
```

**Permission Error (403):**
```
❌ Error
Permission denied. You may not have the required Webex Calling license.
```

**Invalid Extension (404):**
```
❌ Error
Resource not found. The extension may be invalid.
```

---

## 🔐 Required Permissions

The following OAuth scopes are required (already configured):
- `spark:calls_read` - To check for active calls
- `spark:calls_write` - To park and dial calls
- `spark:telephony_config_read` - For telephony operations

---

## 🧪 Testing the Feature

### Prerequisites:
1. User must be logged in with a Webex account
2. User must have a **Webex Calling license**
3. User must have an active **phone registration** (desk phone, mobile app, or Webex app)

### Test Steps:

1. **Start a Call:**
   - Use your Webex app to call someone (or have someone call you)
   - Make sure the call is **connected** (answered)

2. **Configure Contacts:**
   - Click ⚙️ to open settings
   - Add a valid extension from your Webex system
   - Example:
     ```json
     [
       { "name": "Billing Dept", "ext": "2341" },
       { "name": "Support Team", "ext": "1234" }
     ]
     ```

3. **Test Park & Dial:**
   - While on the active call, click "Park & Dial" next to a contact
   - Watch the modal for progress updates
   - You should be connected to the extension you selected

4. **Verify:**
   - The person at that extension can dial their own extension to retrieve the parked call
   - Or you can demonstrate the park/retrieve flow

---

## 🐛 Troubleshooting

### "No Active Call" Error
- **Cause:** No call is currently connected
- **Solution:** Start a call first, then try Park & Dial

### "Authentication failed"
- **Cause:** Access token expired or invalid
- **Solution:** Click logout and log back in

### "Permission denied"
- **Cause:** Missing Webex Calling license or insufficient permissions
- **Solution:** 
  - Verify user has Webex Calling license
  - Check OAuth scopes in Webex Integration settings

### Park/Dial API Fails
- **Cause:** Extension doesn't exist or network issue
- **Solution:**
  - Verify extension is valid in your Webex system
  - Check browser console (F12) for detailed error messages
  - Ensure user has a registered calling device

### Call Parks but Dial Fails
- **Cause:** Park succeeded but dial failed
- **Result:** Original call is parked and waiting
- **Recovery:** The call can be retrieved by dialing the park extension

---

## 📊 API Reference

### Get Active Calls
```http
GET https://webexapis.com/v1/telephony/calls
Headers:
  Authorization: Bearer {access_token}
  Content-Type: application/json

Response:
{
  "items": [
    {
      "id": "call-id-here",
      "state": "connected",
      "remoteParty": { ... },
      ...
    }
  ]
}
```

### Park Call
```http
POST https://webexapis.com/v1/telephony/calls/park
Headers:
  Authorization: Bearer {access_token}
  Content-Type: application/json
Body:
{
  "callId": "call-id-from-step-1",
  "destination": "2341"
}
```

### Dial Call
```http
POST https://webexapis.com/v1/telephony/calls/dial
Headers:
  Authorization: Bearer {access_token}
  Content-Type: application/json
Body:
{
  "destination": "2341"
}
```

---

## 🔍 Implementation Details

### Code Structure

**API Helper Functions:**
- `getActiveCalls()` - Fetches active calls
- `parkCall(callId, destination)` - Parks a call
- `dialCall(destination)` - Dials an extension
- `updateModal(title, message, isError)` - Updates UI

**Main Function:**
- `handleParkDial(name, ext)` - Orchestrates the entire workflow

### Error Handling
- All API calls are wrapped in try/catch blocks
- Errors are logged to console for debugging
- User-friendly error messages shown in modal
- HTTP status codes are translated to actionable messages

### State Management
- Access token retrieved from localStorage
- Call state checked before parking
- Modal provides real-time feedback
- Each step is logged to console

---

## 🚀 Future Enhancements

Potential improvements:
- Add call history/logging
- Support for multiple simultaneous calls
- Call recording integration
- Call transfer (instead of park & dial)
- Conference call capabilities
- Call queue status display
- Hold/Resume functionality

---

## 📚 Related Documentation

- Webex Calling APIs: https://developer.webex.com/docs/api/v1/calls
- OAuth Configuration: `SETUP.md`
- Configuring Contacts: `CONFIGURING_CONTACTS.md`

---

## ✅ Summary

The Park & Dial feature:
- ✅ Checks for active connected calls
- ✅ Parks the current call to a selected extension
- ✅ Dials that extension to connect with someone
- ✅ Provides real-time feedback during the process
- ✅ Handles errors gracefully with user-friendly messages
- ✅ Requires proper Webex Calling license and permissions

**Ready to use!** Just make sure you're on an active call when you click "Park & Dial".

