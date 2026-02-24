# Firestore Collection Exporter

Export Firestore collections to JSON files with configurable options.

## Quick Start

```bash
cd firebase/export-collection
node index.js
```

When prompted, enter the collection name or select from the available list.

## Configuration

Edit `config.json` to customize the export behavior:

```json
{
  "collections": [
    {
      "name": "users",
      "enabled": true,
      "description": "User profiles and account data"
    }
  ],
  "exportPath": "./exports",
  "prettyPrint": true,
  "includeDocumentIds": true
}
```

### Configuration Options

- **collections**: Array of collection definitions
  - `name`: The Firestore collection name
  - `enabled`: Whether this collection is active (for reference)
  - `description`: Description of the collection
  
- **exportPath**: Directory where exported files are saved (relative to this folder)
  
- **prettyPrint**: Format JSON with indentation for readability
  
- **includeDocumentIds**: Include the document ID in exported data

## Usage

### Interactive Mode

```bash
node index.js

📦 Firestore Collection Exporter
================================

📋 Available Collections:
   1. [✓] users - User profiles and account data
   2. [✓] appointments - Booking and appointment records
   3. [✗] barbers - Barber professional profiles
   4. [✗] services - Haircut and service offerings

Enter collection name (or number from list): 1
✓ Selected: users

⏳ Fetching data from collection: "users"...

✅ Success! Exported 42 documents
📄 File saved: /path/to/firebase/export-collection/exports/users-export-2026-02-19T10-30-45.json
```

## Output Format

Exported JSON file contains an array of documents:

```json
[
  {
    "id": "user123",
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890"
  },
  {
    "id": "user456",
    "name": "Jane Smith",
    "email": "jane@example.com",
    "phone": "+0987654321"
  }
]
```

## Features

- ✅ Interactive collection selection
- ✅ Configurable export settings
- ✅ Automatic directory creation
- ✅ Timestamped exports (no overwrites)
- ✅ Progress feedback
- ✅ Error handling

## Requirements

- Valid `serviceAccountKey.json` in the parent `firebase/` directory
- Node.js and npm
- Firebase Admin SDK (installed via parent package.json)

## File Output

Exported files are saved with timestamps:
- Format: `{collectionName}-export-{ISO-TIMESTAMP}.json`
- Example: `users-export-2026-02-19T10-30-45-123.json`
- Location: `exports/` subdirectory

## Troubleshooting

**Error: serviceAccountKey.json not found**
- Ensure `serviceAccountKey.json` exists in the parent `firebase/` directory
- Get it from Firebase Console → Project Settings → Service Accounts

**Error: Collection not found**
- Verify the collection name matches exactly (case-sensitive)
- Check that the collection has data in Firestore

**Error: Permission denied**
- Check your Firestore security rules
- Ensure your service account has read permissions
