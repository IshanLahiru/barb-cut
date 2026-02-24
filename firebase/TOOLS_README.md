# Firebase Tools

This directory contains organized Firebase tools with self-contained configurations and documentation.

## Directory Structure

```
firebase/
├── export-collection/          # Export Firestore collections to JSON
│   ├── index.js               # Main export script
│   ├── config.json            # Configuration for collections to export
│   └── README.md              # Documentation
│
├── upload-data/               # Upload data to Firestore and Storage
│   ├── index.js               # Main upload script
│   ├── config.json            # Configuration for uploads
│   └── README.md              # Documentation
│
├── functions/                 # Firebase Cloud Functions
├── serviceAccountKey.json     # Firebase credentials (git-ignored)
└── package.json              # Root package.json with npm scripts
```

## Quick Start

### Export Collections

Export a Firestore collection to JSON:

```bash
# Navigate to firebase directory
cd firebase

# Run the export tool
npm run export:collection

# Or directly:
cd export-collection
node index.js
```

Then select the collection you want to export.

### Upload Data

Upload data to Firebase from your config:

```bash
# Navigate to firebase directory
cd firebase

# Run the upload tool
npm run upload:data

# Or directly:
cd upload-data
node index.js
```

Then select what you want to upload.

## Available npm Scripts

From the `firebase/` directory:

```bash
npm run export:collection    # Export Firestore collections to JSON
npm run upload:data         # Upload data from config
npm run build              # Build TypeScript functions
npm run serve              # Start Firebase emulators
npm run deploy             # Deploy to Firebase
npm run deploy:functions   # Deploy only functions
npm run deploy:rules       # Deploy Firestore and Storage rules
```

## Configuration

Each tool has its own `config.json`:

### Export Collections Config

File: `export-collection/config.json`

```json
{
  "collections": [
    {
      "name": "users",
      "enabled": true,
      "description": "User profiles"
    }
  ],
  "exportPath": "./exports"
}
```

### Upload Data Config

File: `upload-data/config.json`

```json
{
  "storage": {
    "enabled": true,
    "uploads": [...]
  },
  "firestore": {
    "enabled": true,
    "collections": [...]
  }
}
```

## Documentation

- [Export Collections Guide](export-collection/README.md) - Detailed export instructions
- [Upload Data Guide](upload-data/README.md) - Detailed upload instructions

## Setup Requirements

1. **Service Account Key**
   - Get it from Firebase Console → Project Settings → Service Accounts
   - Save as `serviceAccountKey.json` in this directory
   - Add to `.gitignore` to keep it secure

2. **Dependencies**
   ```bash
   npm install
   ```

3. **Firebase CLI** (for emulators and deployment)
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

## Features

### Export Tool
- ✅ Interactive collection selection
- ✅ Configurable export settings
- ✅ Timestamped exports (no overwrites)
- ✅ Pretty-printed JSON output
- ✅ Document ID preservation

### Upload Tool
- ✅ Upload to Firebase Storage
- ✅ Upload to Firestore collections
- ✅ Configurable batch uploads
- ✅ Image URL processing
- ✅ MIME type detection
- ✅ Optional collection cleanup

## Security

- `serviceAccountKey.json` is git-ignored
- Never commit credentials to version control
- Use environment-specific configurations
- Review Firestore security rules before uploading

## Troubleshooting

### serviceAccountKey.json not found
1. Go to Firebase Console
2. Project Settings → Service Accounts
3. Click "Generate New Private Key"
4. Save as `serviceAccountKey.json` in the `firebase/` directory

### Collection not found
- Verify the collection name in Firestore (case-sensitive)
- Ensure the collection has data
- Check Firestore security rules

### Upload fails
- Verify source files exist at the configured paths
- Check Firestore write permissions
- Ensure bucket name is correct
- Review Firestore security rules

## Next Steps

1. Configure `export-collection/config.json` with your collections
2. Configure `upload-data/config.json` with your data sources
3. Run the tools as needed

For detailed instructions, see the individual tool README files.
