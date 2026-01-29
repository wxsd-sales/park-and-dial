# Preferred Answer Endpoint Selection

This document explains the preferred answer endpoint selection feature.

## 🎯 What Are Preferred Answer Endpoints?

Preferred answer endpoints are the devices/applications where you want incoming calls to ring. Examples:
- **Webex Desktop Application** - Your computer
- **Webex Mobile App** - Your phone
- **Desk Phone** - Cisco IP Phone (e.g., Cisco 9851)
- **MPP Phone** - Multiplatform Phone

When you dial from Park & Dial, this selection determines **which device initiates the outbound call**.

---

## 🔄 How It Works

### On First Login (or Endpoint List Changes):

1. **App fetches available endpoints** from Webex
   ```
   GET https://webexapis.com/v1/telephony/config/people/me/settings/availablePreferredAnswerEndpoints
   ```

2. **User is prompted to select:**
   - User sees a dropdown with available devices
   - User selects preferred device or "None"
   - Selection is saved to browser localStorage

3. **On subsequent page loads:**
   - App fetches latest endpoint list
   - Checks if previously selected endpoint is still valid
   - If valid → uses it automatically
   - If invalid → prompts user to select again

---

## 📱 User Experience

### First Time or When Endpoints Change:

```
┌─────────────────────────────────────────┐
│ 📞 Select Your Dial Endpoint:           │
│ ┌─────────────────────────────────────┐ │
│ │ Cisco 9851                        ▼ │ │
│ └─────────────────────────────────────┘ │
│ [Save Selection]                        │
└─────────────────────────────────────────┘
```

Options include:
- **None** (default - Webex decides)
- **Webex Desktop Application**
- **Cisco Desk Phone**
- **Mobile App**
- etc.

### After Selection:

```
┌─────────────────────────────────────────┐
│ 📞 Dialing from: Cisco 9851  [Change]   │
└─────────────────────────────────────────┘
```

User can click "Change" to select a different endpoint.

---

## 💾 Storage and Persistence

### Stored in Browser localStorage:
```javascript
{
  "id": "Y2lzY29zcGFyazovL3VybjpURUFNOnVzLXdlc3QtMl9yL0NBTExJTkdfREVWSUNFLzIw...",
  "name": "Cisco 9851",
  "type": "CALLING_DEVICE"
}
```

### Special Case - "None":
```javascript
{
  "id": "none",
  "name": "None"
}
```

---

## 🔌 API Integration

### Fetching Available Endpoints:

```http
GET https://webexapis.com/v1/telephony/config/people/me/settings/availablePreferredAnswerEndpoints
Authorization: Bearer {access_token}
Content-Type: application/json

Response:
{
  "endpoints": [
    {
      "id": "Y2lzY29zcGFyazovL3VzL0FQUExJQ0FUSU9OL2FiNGEzMDVm...",
      "type": "APPLICATION",
      "name": "Webex Desktop Application",
      "isPreferredAnswerEndpoint": false
    },
    {
      "id": "Y2lzY29zcGFyazovL3VybjpURUFNOnVzLXdlc3QtMl9yL0NBTExJTkc...",
      "type": "CALLING_DEVICE",
      "name": "Cisco 9851",
      "isPreferredAnswerEndpoint": false
    }
  ]
}
```

### Using Endpoint When Dialing:

**Without Endpoint (None selected):**
```http
POST https://webexapis.com/v1/telephony/calls/dial
Body:
{
  "destination": "2341"
}
```

**With Endpoint Selected:**
```http
POST https://webexapis.com/v1/telephony/calls/dial
Body:
{
  "destination": "2341",
  "endpointId": "Y2lzY29zcGFyazovL3VybjpURUFNOnVzLXdlc3QtMl9yL0NBTExJTkc..."
}
```

---

## 🔄 Validation Flow

On every page load:

```
1. Fetch current available endpoints from Webex API
   ↓
2. Check if user has previously selected an endpoint
   ├─ No selection? → Prompt user to select
   └─ Has selection? → Continue to step 3
      ↓
3. Validate stored endpoint is still in available list
   ├─ Valid? → Use it, show "Dialing from: X"
   └─ Invalid? → Prompt user to select again
```

This ensures:
- ✅ User always has a valid endpoint
- ✅ Changes to available devices are detected
- ✅ Removed/unavailable devices don't cause errors

---

## 🎨 UI States

### State 1: No Endpoints Available
```
(Nothing shown - "None" is automatically set)
```

### State 2: Need to Select
```
┌─────────────────────────────────────────┐
│ 📞 Select Your Dial Endpoint:           │
│ [Dropdown with options]                 │
│ [Save Selection]                        │
└─────────────────────────────────────────┘
```

### State 3: Endpoint Selected
```
┌─────────────────────────────────────────┐
│ 📞 Dialing from: Cisco 9851  [Change]   │
└─────────────────────────────────────────┘
```

---

## 💡 Use Cases

### Use Case 1: Desk Phone User
**Scenario:** User has both Webex app and desk phone  
**Selection:** Cisco 9851  
**Result:** When Park & Dial is used, call originates from desk phone

### Use Case 2: Remote Worker
**Scenario:** User only has Webex Desktop app  
**Selection:** Webex Desktop Application  
**Result:** Calls originate from computer

### Use Case 3: Mobile User
**Scenario:** User is on the go with mobile app  
**Selection:** Webex Mobile App  
**Result:** Calls originate from mobile device

### Use Case 4: Let Webex Decide
**Scenario:** User wants default behavior  
**Selection:** None  
**Result:** Webex uses default ringing behavior

---

## 🔧 Configuration

### Changing Your Endpoint:

1. Click **"Change"** button in the endpoint info bar
2. Select new endpoint from dropdown
3. Click **"Save Selection"**

### Resetting to None:

1. Click **"Change"**
2. Select **"None"** from dropdown
3. Click **"Save Selection"**

### Manual Reset (Browser Console):
```javascript
localStorage.removeItem('selected_endpoint');
location.reload();
```

---

## 🐛 Troubleshooting

### Endpoint selector keeps appearing on every page load
**Cause:** Selected endpoint is no longer in available endpoints list  
**Solution:** Device may have been removed/deregistered. Select a different endpoint.

### "None" is the only option
**Cause:** No calling devices/apps registered to your account  
**Solution:** 
- Install and sign into Webex app
- Or register a desk phone
- Contact IT to verify Webex Calling is properly provisioned

### Dial fails with selected endpoint
**Cause:** Endpoint may be offline or unreachable  
**Solution:** 
- Try selecting "None"
- Verify the selected device is online
- Check device registration status

### Can't see my desk phone in the list
**Cause:** Phone may not be registered or associated with your account  
**Solution:**
- Verify phone is powered on and connected
- Check phone registration status
- Contact IT admin to verify phone assignment

---

## 🔐 Privacy & Security

- ✅ Endpoint selection stored **locally in browser**
- ✅ No endpoint data sent to external servers
- ✅ Endpoint list fetched fresh on each page load
- ✅ Uses OAuth token for API authentication
- ✅ Clearing browser data removes endpoint selection

---

## 📊 Technical Details

### localStorage Key:
```
selected_endpoint
```

### Storage Format:
```json
{
  "id": "endpoint-id-here",
  "name": "Device Name",
  "type": "CALLING_DEVICE | APPLICATION"
}
```

### Endpoint Types:
- `APPLICATION` - Webex apps (desktop, mobile)
- `CALLING_DEVICE` - Physical IP phones
- `MPP_DEVICE` - Multiplatform phones

---

## ✅ Feature Summary

✅ **Automatic Detection** - Fetches available devices on login  
✅ **Persistent Selection** - Remembers choice in browser  
✅ **Validation** - Checks endpoint is still valid on each load  
✅ **User Control** - Easy to change selection  
✅ **Graceful Fallback** - "None" option always available  
✅ **Real-time Updates** - Detects when devices are added/removed  
✅ **No Configuration** - Works automatically with Webex Calling  

---

## 🚀 Ready to Use!

The endpoint selection feature works automatically:
1. Login to the app
2. If you have multiple devices, you'll be prompted to select one
3. Make your selection and start using Park & Dial
4. Your choice is remembered for next time

**The endpoint you select determines which device makes outbound calls when you use Park & Dial!**

