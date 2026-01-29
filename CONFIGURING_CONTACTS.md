# Configuring Contacts

Your park-and-dial app now supports configurable contact lists! Perfect for demos with different scenarios.

## 🎯 Three Ways to Load Contacts

### Priority Order:
1. **URL Parameters** (highest priority)
2. **localStorage** (saved in browser)
3. **Default contacts** (fallback)

---

## 📝 Method 1: Using the Settings UI (Easiest)

### Step-by-Step:

1. **Login** to your app at https://wxsd-sales.github.io/park-and-dial/
2. Click the **⚙️ settings button** (bottom right corner)
3. **Edit the JSON** in the text area:
   ```json
   [
     { "name": "Alice Johnson", "ext": "1001" },
     { "name": "Bob Smith", "ext": "1002" },
     { "name": "Carol White", "ext": "1003" }
   ]
   ```
4. Click **"💾 Save"**
5. Your contacts are now saved in your browser!

### Features:
- ✅ Persists across sessions
- ✅ Easy JSON editing
- ✅ Validation before saving
- ✅ Reset to defaults button

---

## 🔗 Method 2: Shareable URLs (For Sharing)

Perfect for sending pre-configured demos to colleagues!

### Creating a Shareable URL:

1. Open **⚙️ Settings**
2. Edit your contacts
3. Click **"🔗 Copy Shareable URL"**
4. Share the URL!

### Example URL:
```
https://wxsd-sales.github.io/park-and-dial/?contacts=W3sibmFtZSI6IkFsaWNlIEpvaG5zb24iLCJleHQiOiIxMDAxIn0seyJuYW1lIjoiQm9iIFNtaXRoIiwiZXh0IjoiMTAwMiJ9XQ==
```

When someone opens this URL, they'll see **your** contact list automatically loaded!

### Use Cases:
- 📧 Email a demo link to a customer
- 💬 Share in Slack/Teams
- 📋 Bookmark different demo scenarios
- 🎓 Provide to colleagues for consistent demos

---

## 🛠️ Method 3: Manual URL Parameters (Advanced)

If you want to create URLs programmatically:

### Format:
```
https://wxsd-sales.github.io/park-and-dial/?contacts=BASE64_ENCODED_JSON
```

### JavaScript Example:
```javascript
const contacts = [
  { name: "Alice Johnson", ext: "1001" },
  { name: "Bob Smith", ext: "1002" }
];

const encoded = btoa(JSON.stringify(contacts));
const url = `https://wxsd-sales.github.io/park-and-dial/?contacts=${encoded}`;
console.log(url);
```

### Python Example:
```python
import json
import base64
import urllib.parse

contacts = [
    {"name": "Alice Johnson", "ext": "1001"},
    {"name": "Bob Smith", "ext": "1002"}
]

encoded = base64.b64encode(json.dumps(contacts).encode()).decode()
url = f"https://wxsd-sales.github.io/park-and-dial/?contacts={encoded}"
print(url)
```

---

## 📋 Contact JSON Format

Each contact must have:
- `name` (string): Display name
- `ext` (string): Extension number

### Valid Example:
```json
[
  { "name": "Support Team", "ext": "1000" },
  { "name": "John Doe", "ext": "2341" },
  { "name": "Jane Smith", "ext": "2342" }
]
```

### ❌ Invalid Examples:

Missing field:
```json
[
  { "name": "John Doe" }  // ❌ Missing "ext"
]
```

Wrong type:
```json
[
  { "name": "John Doe", "ext": 1234 }  // ❌ ext should be a string "1234"
]
```

Not an array:
```json
{ "name": "John Doe", "ext": "1234" }  // ❌ Must be an array [...]
```

---

## 💡 Demo Scenarios

### Scenario 1: Sales Demo
Create a URL with sales team contacts:
```json
[
  { "name": "Sales Director", "ext": "5001" },
  { "name": "Account Manager", "ext": "5002" },
  { "name": "Sales Engineer", "ext": "5003" }
]
```

### Scenario 2: Support Queues
```json
[
  { "name": "L1 Support", "ext": "8001" },
  { "name": "L2 Support", "ext": "8002" },
  { "name": "Escalation Manager", "ext": "8003" }
]
```

### Scenario 3: Executive Team
```json
[
  { "name": "CEO Office", "ext": "1000" },
  { "name": "CFO Office", "ext": "1001" },
  { "name": "CTO Office", "ext": "1002" }
]
```

---

## 🔄 How It Works

```
1. User opens URL
   ↓
2. Check URL for ?contacts=...
   ├─ Found? Use those contacts ✓
   └─ Not found? Continue...
      ↓
3. Check browser localStorage
   ├─ Found? Use saved contacts ✓
   └─ Not found? Use defaults
```

---

## 🧹 Clearing Saved Contacts

### Option 1: Reset Button
1. Open **⚙️ Settings**
2. Click **"↺ Reset to Defaults"**
3. Click **"💾 Save"**

### Option 2: Browser DevTools
```javascript
localStorage.removeItem('custom_contacts');
location.reload();
```

### Option 3: Use Default URL
Just visit the URL without parameters:
```
https://wxsd-sales.github.io/park-and-dial/
```
(Will use your saved contacts from localStorage or defaults)

---

## ⚡ Quick Tips

1. **Test your JSON** before saving - the editor will validate it
2. **Bookmark URLs** for different demo scenarios
3. **Extensions are strings** - use "1234" not 1234
4. **Share URLs** work even if recipient doesn't have localStorage set
5. **URL parameters override** localStorage (useful for demos)

---

## 🐛 Troubleshooting

### "Invalid JSON format" error
- Check for missing commas between objects
- Ensure all strings use double quotes `"`
- Validate your JSON at https://jsonlint.com

### Contacts not saving
- Check browser console for errors (F12)
- Ensure localStorage is enabled in your browser
- Try incognito mode to test

### Shareable URL not working
- Ensure the JSON is valid before copying
- URL might be truncated in email - use a link shortener
- Try opening in incognito to verify it works

---

## 📞 Example: Complete Working JSON

```json
[
  {
    "name": "Alice Johnson",
    "ext": "1001"
  },
  {
    "name": "Bob Smith", 
    "ext": "1002"
  },
  {
    "name": "Carol White",
    "ext": "1003"
  },
  {
    "name": "David Brown",
    "ext": "1004"
  },
  {
    "name": "Emma Davis",
    "ext": "1005"
  }
]
```

Copy this, paste into the settings editor, and click save!

