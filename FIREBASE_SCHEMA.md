# Firebase Data Schema

## Collections

### 1. **users** (Collection)
User profile and preferences data

**Document ID**: Firebase Auth UID

**Fields**:
```
{
  "id": string (auth UID),
  "name": string,
  "email": string,
  "phoneNumber": string?,
  "avatarUrl": string?,
  "preferences": {
    "faceShape": string,
    "hairType": string,
    "stylePreferences": array<string>
  },
  "createdAt": timestamp,
  "updatedAt": timestamp
}
```

### 2. **haircuts** (Collection)
Haircut styles catalog

**Document ID**: Auto-generated or custom ID

**Fields**:
```
{
  "id": string,
  "name": string,
  "price": string,
  "duration": string,
  "description": string,
  "images": {
    "front": string (URL),
    "left_side": string (URL),
    "right_side": string (URL),
    "back": string (URL)
  },
  "suitableFaceShapes": array<string>,
  "maintenanceTips": array<string>,
  "createdAt": timestamp,
  "updatedAt": timestamp
}
```

### 3. **beard_styles** (Collection)
Beard styles catalog

**Document ID**: Auto-generated or custom ID

**Fields**:
```
{
  "id": string,
  "name": string,
  "price": string,
  "duration": string,
  "description": string,
  "images": {
    "front": string (URL),
    "left_side": string (URL),
    "right_side": string (URL),
    "back": string (URL)
  },
  "suitableFaceShapes": array<string>,
  "maintenanceTips": array<string>,
  "createdAt": timestamp,
  "updatedAt": timestamp
}
```

### 4. **products** (Collection)
Hair care products catalog

**Document ID**: Auto-generated or custom ID

**Fields**:
```
{
  "id": string,
  "name": string,
  "price": string,
  "description": string,
  "imageUrl": string (URL),
  "category": string,
  "brand": string?,
  "rating": number?,
  "createdAt": timestamp,
  "updatedAt": timestamp
}
```

### 5. **history** (Collection)
User's style history

**Document Path**: `users/{userId}/history/{historyId}`

**Fields**:
```
{
  "id": string,
  "userId": string,
  "styleType": string ("haircut" | "beard"),
  "styleId": string (reference to haircut or beard_style),
  "styleName": string,
  "date": timestamp,
  "images": {
    "before": string (URL)?,
    "after": string (URL)?
  },
  "notes": string?,
  "rating": number?,
  "createdAt": timestamp
}
```

## Storage Structure

### Firebase Storage Paths

```
/styles/
  /haircuts/
    /{haircutId}/
      /front.jpg
      /left_side.jpg
      /right_side.jpg
      /back.jpg
      
  /beards/
    /{beardId}/
      /front.jpg
      /left_side.jpg
      /right_side.jpg
      /back.jpg

/products/
  /{productId}.jpg

/users/
  /{userId}/
    /avatar.jpg
    /history/
      /{historyId}/
        /before.jpg
        /after.jpg
```

## Security Rules

### Firestore Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Public read for catalogs
    match /haircuts/{document=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    match /beard_styles/{document=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    match /products/{document=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // User-specific data
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
      
      match /history/{historyId} {
        allow read: if request.auth != null && request.auth.uid == userId;
        allow write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### Storage Rules
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Style images - public read, admin write
    match /styles/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Product images - public read, admin write
    match /products/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // User data - user-specific access
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Migration Notes

1. **Initial Data**: Use the migration script to populate haircuts, beard_styles, and products collections with data from JSON files
2. **User Data**: History will be empty initially; populated as users use the app
3. **Images**: Existing image URLs from unsplash.com will be maintained initially
4. **Indexes**: May need composite indexes for queries with multiple filters
