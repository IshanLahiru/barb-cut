# Firebase Data Uploader

Upload images to Firebase Storage and data to Firestore with configurable options.

## Quick Start

```bash
cd firebase/upload-data
node index.js
```

Then select what you want to upload from the interactive menu.

## Configuration

Edit `config.json` to customize what data gets uploaded and where it comes from.

### Structure

The configuration has three main sections:

#### 1. Storage Configuration

```json
"storage": {
  "enabled": true,
  "bucketName": "barb-cut.firebasestorage.app",
  "uploads": [
    {
      "name": "Haircut Images",
      "enabled": true,
      "sourceDir": "../../apps/barbcut/assets/data/images",
      "destinationPath": "haircut-images/",
      "fileTypes": [".png", ".jpg", ".jpeg"],
      "metadata": {
        "cacheControl": "public, max-age=31536000"
      },
      "makePublic": true
    }
  ]
}
```

**Upload Options:**
- `name`: Display name for this upload
- `enabled`: Whether this upload is available
- `sourceDir`: Local directory to upload from (relative path)
- `destinationPath`: Path in Firebase Storage
- `fileTypes`: Array of file extensions to upload
- `metadata`: Additional metadata (cache control, etc.)
- `makePublic`: Make uploaded files publicly accessible

#### 2. Firestore Configuration

```json
"firestore": {
  "enabled": true,
  "collections": [
    {
      "name": "haircuts",
      "enabled": true,
      "sourceFile": "../../apps/barbcut/assets/data/haircuts.json",
      "description": "Haircut styles and designs",
      "idField": "id",
      "imageUrlPrefix": "https://storage.googleapis.com/barb-cut.firebasestorage.app/haircut-images/"
    }
  ]
}
```

**Collection Options:**
- `name`: Firestore collection name
- `enabled`: Whether this collection is available
- `sourceFile`: JSON file with data to upload (relative path)
- `description`: Description of the collection
- `idField`: Field to use as document ID
- `imageUrlPrefix`: Optional prefix to add to image URLs

#### 3. Upload Options

```json
"options": {
  "overwrite": true,
  "deletePreviousDocs": false,
  "verbose": true
}
```

**Options:**
- `overwrite`: Overwrite existing documents
- `deletePreviousDocs`: Clear collection before uploading
- `verbose`: Show detailed logging

## Usage

### Interactive Mode

```bash
node index.js

🚀 Barbcut Firebase Data Uploader
==================================

📋 Available Upload Options:

Storage Uploads:
   [✓] 1. Haircut Images

Firestore Collections:
   [✓] 11. haircuts - Haircut styles and designs
   [✓] 12. beard_styles - Beard styling options
   [✗] 13. services - Barber services offered

What would you like to upload? (number, "all", or "cancel"): 1
```

### Upload All Enabled Items

```bash
node index.js
# Then enter "all" when prompted
```

### Upload Specific Collection

```bash
node index.js
# Then enter the number (e.g., "11" for haircuts)
```

## Features

- ✅ Interactive menu with available options
- ✅ Configurable storage uploads
- ✅ Configurable Firestore collections
- ✅ Batch uploads for efficiency
- ✅ Automatic image URL processing
- ✅ Optional collection cleanup before upload
- ✅ MIME type detection for storage
- ✅ Progress feedback
- ✅ Error handling

## JSON Format Requirements

### Firestore Collections

Data should be a JSON array of objects:

```json
[
  {
    "id": "haircut-001",
    "name": "Fade Cut",
    "description": "Classic fade with texture",
    "images": {
      "front": "front.png",
      "side": "side.png"
    }
  },
  {
    "id": "haircut-002",
    "name": "Undercut",
    "description": "Long on top, short on sides",
    "images": {
      "front": "undercut-front.png",
      "side": "undercut-side.png"
    }
  }
]
```

Or a single object:

```json
{
  "key": "value",
  "nested": {
    "data": "here"
  }
}
```

## Requirements

- Valid `serviceAccountKey.json` in the parent `firebase/` directory
- Node.js and npm
- Firebase Admin SDK (installed via parent package.json)
- JSON data files in the locations specified in config.json

## Requirements Met

- Valid `serviceAccountKey.json` in the parent `firebase/` directory
- Node.js and npm
- Firebase Admin SDK (installed via parent package.json)
- Image files in the sourceDir specified in config
- JSON data files matching the sourceFile paths in config

## Tips

### Adding a New Collection

1. Prepare your JSON file (array of objects)
2. Add to `config.json` in the `collections` array:
   ```json
   {
     "name": "my-collection",
     "enabled": true,
     "sourceFile": "path/to/data.json",
     "description": "My custom collection",
     "idField": "id"
   }
   ```
3. Run `node index.js` and select the new option

### Adding a New Storage Upload

1. Ensure you have files in a directory
2. Add to `config.json` in the `uploads` array:
   ```json
   {
     "name": "My Files",
     "enabled": true,
     "sourceDir": "path/to/files",
     "destinationPath": "my-files/",
     "fileTypes": [".png", ".jpg"],
     "makePublic": true
   }
   ```
3. Run `node index.js` and select the new option

## Troubleshooting

**Error: serviceAccountKey.json not found**
- Ensure `serviceAccountKey.json` exists in the parent `firebase/` directory

**Error: Source file not found**
- Check the `sourceFile` or `sourceDir` path in config.json
- Use absolute paths if relative paths don't work

**Error: Permission denied**
- Check your Firestore security rules
- Ensure your service account has write permissions

**Images not uploading**
- Verify files exist in the sourceDir
- Check that fileTypes match your files
- Ensure bucket name is correct in config
