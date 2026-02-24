# AI Image Generation Testing Guide

## Pre-Flight Checklist

### 1. Verify Vertex AI API is Enabled
```bash
# Check in GCP Console or run:
gcloud services list --enabled --project=barb-cut | grep vertexai

# If not enabled, enable it:
gcloud services enable aiplatform.googleapis.com --project=barb-cut
```

### 2. Verify IAM Permissions
The default Cloud Functions service account must have Vertex AI permissions:

**Service Account:** `firebase-adminsdk-xxxxx@barb-cut.iam.gserviceaccount.com`

**Required Roles:**
- `roles/aiplatform.user` (Vertex AI User)
- `roles/storage.admin` (for uploading images to Firebase Storage)

To assign:
```bash
gcloud projects add-iam-policy-binding barb-cut \
  --member=serviceAccount:firebase-adminsdk-xxxxx@barb-cut.iam.gserviceaccount.com \
  --role=roles/aiplatform.user

gcloud projects add-iam-policy-binding barb-cut \
  --member=serviceAccount:firebase-adminsdk-xxxxx@barb-cut.iam.gserviceaccount.com \
  --role=roles/storage.admin
```

### 3. Verify Functions Configuration
Check that Vertex AI config is set:
```bash
firebase functions:config:get
```

Should show:
```json
{
  "vertexai": {
    "project": "barb-cut",
    "location": "us-central1"
  }
}
```

If missing, set it:
```bash
firebase functions:config:set vertexai.project="barb-cut" vertexai.location="us-central1"
firebase deploy --only functions
```

---

## End-to-End Testing Steps

### Step 1: Verify Backend Services Are Live

**Check 1A: Functions Deployed**
```bash
firebase functions:list
```

Look for:
✅ `createGenerationJob` (callable, us-central1)
✅ `scheduleJobProcessor` (scheduled, us-central1)

**Check 1B: Firestore Collections Exist**
Open Firebase Console > Firestore > Collections. Should see (or be empty and ready for):
- `aiJobs` (where jobs are queued)
- `history` (where completed jobs are stored)

**Check 1C: Storage Bucket Ready**
Open Firebase Console > Storage. Verify bucket exists (e.g., `barb-cut.appspot.com`).

---

### Step 2: Open the App & Authenticate

1. Run the Flutter app:
   ```bash
   cd apps/barbcut
   flutter run
   ```

2. Ensure you're logged in (anonymous or user auth)
   - Token should be visible in Firebase Console > Authentication if user auth is used

---

### Step 3: Trigger a Generation (Home Tab)

1. Navigate to **Home** tab
2. Scroll through haircut styles and **select one**
   - ✅ Expect: Dark overlay appears on the selected card, haircut name is highlighted
3. Scroll to beard styles and **select one**
   - ✅ Expect: Beard name shows as selected
4. Tap **"Try This"** button
   - ✅ Expect: No error toast, button returns control quickly (job enqueued in background)

**Behind the Scenes:**
- `home_view.dart` → `_startGeneration()` called
- Calls `AiGenerationService.createGenerationJob(haircutId, haircutName, beardId, beardName, referenceImageUrl)`
- Creates a job document in Firestore `aiJobs` collection with:
  - `userId`: current user ID
  - `status`: "queued"
  - `prompt`: Generated from haircut + beard names
  - `model`: "imagen-3-fast"
  - `timestamp`: now

---

### Step 4: Wait for Scheduler to Process (5 minutes)

The `scheduleJobProcessor` runs **every 5 minutes** via Pub/Sub trigger.

**Option A: Check Logs** (Real-time monitoring)
```bash
# Watch logs as they stream in
firebase functions:log --only scheduleJobProcessor
```

Look for:
- ✅ `"Processing job {jobId}..."`
- ✅ `"Generated image data URL received"`
- ✅ `"Uploaded to Storage: gs://barb-cut.appspot.com/generated/{userId}/{jobId}.png"`
- ✅ `"Wrote history document: {historyId}"`
- ✅ `"Updated job status to completed"`

**Option B: Firestore Manual Check** (Every 1-2 minutes)
Open Firebase Console > Firestore Collections:
1. Open `aiJobs` collection
2. Find your job (filter by `userId` = your user ID)
3. Watch the `status` field:
   - `"queued"` → `"processing"` → `"completed"` (success), or `"error"` (failed)
4. If `status: "completed"`, check `history` collection for the generated image doc

**Option C: Storage Bucket Check** (After ~5 min)
Firebase Console > Storage > Browse:
- Path: `generated/{userId}/{jobId}.png`
- ✅ Should contain the generated image

---

### Step 5: Verify History Update (History Tab)

1. Navigate to **History** tab
2. Within 5-15 minutes, a **new card should appear** with:
   - ✅ Generated image thumbnail
   - ✅ Haircut name + beard name
   - ✅ Timestamp of generation
   - ✅ If you pull-to-refresh, it should re-fetch from Firestore

**Realtime Behavior:**
- The app listens to Firestore `history` collection in real-time
- When the scheduler writes the history doc, the listener should **instantly update the UI** (no manual refresh needed)
- Card appears in the grid automatically

**Behind the Scenes:**
- `history_view.dart` → `_startHistoryListener(userId)`
- Listens to: `FirebaseFirestore.instance.collection('history').where('userId', isEqualTo: userId).snapshots()`
- When a new doc is added, the snapshot listener fires
- Resolves Firebase Storage URLs and updates the grid
- Pull-to-refresh integrated via `RefreshIndicator`

---

### Step 6: Advanced Verification

#### 6A: Check Firestore Security Rules
Firebase Console > Firestore > Rules:
- Ensure `history` collection only lets users read their own docs
- Ensure `aiJobs` collection only lets users read their own docs

Test: Try opening Firestore console as another user (incognito tab) — should not see other users' history.

#### 6B: Verify Per-User Isolation
- Generate an image as User A
- Switch to a different device/incognito as User B, log in
- User B's History tab should show **only their own history** (not User A's)

#### 6C: Check Image URLs
Open History > Right-click an image > "Open Image in New Tab"
- ✅ Should be a Firebase Storage download URL (https://firebasestorage.googleapis.com/...)
- ✅ Image should load and display correctly

---

## Troubleshooting

### Issue: No Image Appears After 15 Minutes

**Check 1: Function Logs**
```bash
firebase functions:log --only scheduleJobProcessor
```

Look for errors like:
- `"Vertex AI API not enabled"` → Run `gcloud services enable aiplatform.googleapis.com --project=barb-cut`
- `"Permission denied"` → Add IAM roles to service account (see Pre-Flight Checklist)
- `"Model not found"` → Check `imagen-3-fast` model exists in us-central1

**Check 2: Firestore aiJobs Collection**
Firebase Console > Firestore > aiJobs:
- Is job there with `status: "queued"` or `"error"`?
- If `"error"`, check `errorMessage` field for details

**Check 3: Pub/Sub Subscription**
```bash
gcloud pubsub subscriptions list --project=barb-cut
```

Look for a subscription bound to `scheduleJobProcessor`. If missing, Pub/Sub trigger may not be connected. Redeploy functions:
```bash
firebase deploy --only functions
```

### Issue: Image Appears in Storage but Not in History Tab

**Check 1: History Document in Firestore**
Firebase Console > Firestore > history:
- Is the history doc there?
- Does it have `userId` that matches the current user?
- Does it have `imageUrl` pointing to `gs://barb-cut.appspot.com/generated/...`?

**Check 2: Firestore Rules**
Ensure the user can read their own history:
```
allow read: if isAuthenticated() && isOwner(resource.data.userId);
```

**Check 3: Storage URL Resolution**
Check browser network tab (F12 > Network):
- History grid fetches images via `FirebaseStorageHelper.getDownloadUrl()`
- Should resolve `gs://` paths to https:// URLs
- If 404 or 403, check Storage permissions

**Check 4: Auth Context**
Ensure `FirebaseAuth.instance.currentUser` is not null:
```bash
# In app logs / Flutter debugger
debugPrint('Current user: ${FirebaseAuth.instance.currentUser?.uid}');
```

### Issue: History Tab Shows Nothing

**Check 1: User Authenticated**
Ensure `FirebaseAuth.instance.currentUser` is not null. If null, login first.

**Check 2: Snapshot Listener Active**
In `history_view.dart`, verify:
- `_startHistoryListener(userId)` is called in `initState()`
- Subscription is active (`_historySubscription != null`)
- No exceptions in `listen((snapshot) { ... })`

**Check 3: Firestore Query**
Run this in Firestore console as the user:
```
collection('history').where('userId', '==', <your-user-id>).orderBy('timestamp', descending: true)
```
- Should return existing docs or be empty
- If error (e.g., missing index), Firestore will tell you to create an index — do so and wait ~5 min

---

## Quick Debugging Commands

```bash
# Watch all function logs live
firebase functions:log

# Watch only the scheduler
firebase functions:log --only scheduleJobProcessor

# Watch only the job creation function
firebase functions:log --only createGenerationJob

# List all deployed functions
firebase functions:list

# Get Vertex AI config
firebase functions:config:get

# Redeploy only functions (after config changes)
firebase deploy --only functions

# Test Vertex AI API access (from local machine)
gcloud ai images generate \
  --prompt="A barber shop haircut" \
  --output-file=test.png \
  --project=barb-cut \
  --region=us-central1

# Check Pub/Sub subscription status
gcloud pubsub subscriptions describe firebase-schedule-scheduleJobProcessor-us-central1 --project=barb-cut
```

---

## Success Criteria Checklist

✅ Functions deployed and live
✅ Vertex AI API enabled + IAM roles assigned
✅ App triggers generation (no error on "Try This" click)
✅ Job queued in Firestore `aiJobs` within 5 seconds
✅ Job processes within 5-10 minutes (status → "processing" → "completed")
✅ Image file appears in Storage at `generated/{userId}/{jobId}.png`
✅ History doc appears in Firestore `history` with `imageUrl` + `userId`
✅ History tab updates automatically to show new image
✅ Other users don't see the generated history (per-user isolation works)
✅ Storage URLs resolve correctly (images display in History grid)

---

## Next Steps

Once testing passes:
1. **Optional:** Add error toast when job fails (monitor `status: "error"` in realtime listener)
2. **Optional:** Add job progress indicator (show "Generating..." while status is "processing")
3. **Production:** Monitor Vertex AI quota usage (may have rate limits or costs)
4. **Maintenance:** Before March 2026, migrate `functions.config()` to Firebase Params API (deprecation deadline)

