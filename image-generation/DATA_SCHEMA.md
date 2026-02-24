# Data Schema & JSON Structure

## Complete Data Flow Architecture

```
Prompt Data
   ↓
Workflow Template + Prompt Data
   ↓
ComfyUI Workflow JSON
   ↓
ComfyUI Server Execution
   ↓
Generated Images
   ↓
Results JSON + Image Files
   ↓
Gallery View + Master Image Selection
```

## 1. Prompt Schema

### Prompt JSON Structure
```json
{
  "id": "prompt_abc123_xyz",
  "name": "Modern Undercut Portrait",
  "description": "Professional portrait with modern undercut",
  "mainPrompt": "A professional portrait photo of a man with a modern undercut haircut...",
  "negativePrompt": "blurry, low quality, distorted...",
  "style": "portrait",
  "category": "haircut",
  "tags": ["portrait", "professional", "haircut", "male"],
  "createdAt": "2026-02-19T10:30:00Z",
  "updatedAt": "2026-02-19T11:00:00Z",
  "instructions": {
    "4": {
      "seed": 567890,
      "steps": 25,
      "cfg": 8.0
    }
  },
  "versions": [
    {
      "version": 1,
      "mainPrompt": "A professional portrait photo...",
      "negativePrompt": "blurry, low quality...",
      "instructions": { "4": { "seed": 567890, "steps": 20, "cfg": 7.0 } },
      "createdAt": "2026-02-19T10:30:00Z"
    },
    {
      "version": 2,
      "mainPrompt": "A professional portrait photo of a man with a modern undercut...",
      "negativePrompt": "blurry, low quality, distorted...",
      "instructions": { "4": { "seed": 567890, "steps": 25, "cfg": 8.0 } },
      "createdAt": "2026-02-19T11:00:00Z"
    }
  ]
}
```

**File Location:** `data/prompts/{promptId}.json`

**Key Fields:**
- `id`: Unique identifier for the prompt
- `versions`: Array of all changes to the prompt
- `instructions`: Node-specific overrides for workflow parameters
- `tags`: For filtering and searching

---

## 2. Workflow Schema

### Workflow Record JSON
```json
{
  "id": "workflow_def456_uvw",
  "templateId": "default_portrait",
  "promptId": "prompt_abc123_xyz",
  "workflow": {
    "1": {
      "class_type": "CheckpointLoader",
      "inputs": { "ckpt_name": "model.safetensors" }
    },
    "2": {
      "class_type": "CLIPTextEncode",
      "inputs": {
        "text": "A professional portrait photo...",
        "clip": ["1", 1]
      }
    },
    "3": {
      "class_type": "CLIPTextEncode",
      "inputs": {
        "text": "blurry, low quality...",
        "clip": ["1", 1]
      }
    },
    "4": {
      "class_type": "KSampler",
      "inputs": {
        "seed": 567890,
        "steps": 25,
        "cfg": 8.0,
        "sampler_name": "euler",
        "scheduler": "normal",
        "denoise": 1.0,
        "model": ["1", 0],
        "positive": ["2", 0],
        "negative": ["3", 0],
        "latent_image": ["5", 0]
      }
    },
    "5": {
      "class_type": "EmptyLatentImage",
      "inputs": { "width": 512, "height": 768, "batch_size": 1 }
    },
    "6": {
      "class_type": "VAEDecode",
      "inputs": { "samples": ["4", 0], "vae": ["1", 2] }
    },
    "7": {
      "class_type": "SaveImage",
      "inputs": { "filename_prefix": "barb_cut_portrait", "images": ["6", 0] }
    }
  },
  "parameters": {
    "seed": 567890,
    "steps": 25,
    "cfg": 8.0,
    "sampler": "euler",
    "width": 512,
    "height": 768
  },
  "promptData": {
    "id": "prompt_abc123_xyz",
    "name": "Modern Undercut Portrait",
    "mainPrompt": "A professional portrait photo...",
    "negativePrompt": "blurry, low quality...",
    "instructions": { "4": { "seed": 567890, "steps": 25, "cfg": 8.0 } },
    "style": "portrait",
    "category": "haircut",
    "tags": ["portrait", "professional", "haircut", "male"]
  },
  "createdAt": "2026-02-19T10:35:00Z",
  "status": "submitted",
  "statusMeta": {
    "promptId": "abc123xyz789",
    "submittedAt": "2026-02-19T10:35:30Z"
  }
}
```

**File Location:** `data/workflows/generated/{workflowId}.json`

**Key Fields:**
- `workflow`: Complete ComfyUI workflow JSON
- `parameters`: Extracted parameter values for easier reference
- `promptData`: Reference to the source prompt
- `status`: submitted, running, completed, error, etc.

---

## 3. Result Schema

### Result/Generation JSON
```json
{
  "id": "result_ghi789_jkl",
  "promptId": "prompt_abc123_xyz",
  "workflowId": "workflow_def456_uvw",
  "images": [
    {
      "filename": "barb_cut_portrait_001.png",
      "path": "/Users/user/path/data/results/barb_cut_portrait_001.png",
      "size": "2.38 MB",
      "bytes": 2500000
    },
    {
      "filename": "barb_cut_portrait_002.png",
      "path": "/Users/user/path/data/results/barb_cut_portrait_002.png",
      "size": "2.41 MB",
      "bytes": 2527000
    }
  ],
  "executionTime": 45000,
  "nodeCount": 7,
  "metadata": {
    "model": "model.safetensors",
    "sampler": "euler",
    "steps": 25,
    "cfg": 8.0,
    "seed": 567890,
    "style": "portrait",
    "category": "haircut",
    "tags": ["portrait", "professional", "haircut", "male"],
    "generatedAt": "2026-02-19T10:35:45Z"
  },
  "status": "completed",
  "isMaster": false
}
```

**File Location:** `data/results/{resultId}.json`

**Key Fields:**
- `images`: Array of generated image files with paths
- `executionTime`: Time taken in milliseconds
- `metadata`: All parameters and context for reproducibility
- `isMaster`: Whether this is the selected master image
- `status`: Current state of the result

---

## 4. Master Image Schema

### Master Image Reference JSON
```json
{
  "id": "master_mno012_pqr",
  "promptId": "prompt_abc123_xyz",
  "resultId": "result_ghi789_jkl",
  "imageIndex": 0,
  "image": {
    "filename": "barb_cut_portrait_001.png",
    "path": "/Users/user/path/data/results/barb_cut_portrait_001.png",
    "size": "2.38 MB",
    "bytes": 2500000
  },
  "metadata": {
    "model": "model.safetensors",
    "sampler": "euler",
    "steps": 25,
    "cfg": 8.0,
    "seed": 567890,
    "generatedAt": "2026-02-19T10:35:45Z",
    "selectedAsMaster": "2026-02-19T10:45:00Z"
  }
}
```

**File Location:** `data/master-images/{promptId}_master.json`

**Key Fields:**
- `resultId`: Reference to the selected result
- `imageIndex`: Which image from that result
- `selectedAsMaster`: When it was chosen

---

## 5. Gallery Schema

### Gallery JSON
```json
{
  "id": "gallery_stu345_vwx",
  "promptId": "prompt_abc123_xyz",
  "name": "Modern Undercut Portraits - Gallery",
  "description": "Gallery of generated modern undercut portrait images",
  "results": [
    {
      "id": "result_ghi789_jkl",
      "timestamp": "2026-02-19T10:35:45Z",
      "executionTime": 45000,
      "images": [
        {
          "filename": "barb_cut_portrait_001.png",
          "path": "/Users/user/path/data/results/barb_cut_portrait_001.png",
          "size": "2.38 MB",
          "bytes": 2500000
        }
      ],
      "isMaster": true
    },
    {
      "id": "result_xyz123_abc",
      "timestamp": "2026-02-19T10:40:00Z",
      "executionTime": 42000,
      "images": [
        {
          "filename": "barb_cut_portrait_002.png",
          "path": "/Users/user/path/data/results/barb_cut_portrait_002.png",
          "size": "2.41 MB",
          "bytes": 2527000
        }
      ],
      "isMaster": false
    }
  ],
  "createdAt": "2026-02-19T10:50:00Z",
  "updatedAt": "2026-02-19T10:50:00Z",
  "totalImages": 2
}
```

**File Location:** `data/results/galleries/{galleryId}.json`

**Key Fields:**
- `results`: Array of generation results in chronological order
- `totalImages`: Total count of all images in gallery
- `isMaster`: Indicates which result has the master image

---

## 6. Directory Structure

```
data/
├── prompts/
│   ├── prompt_abc123_xyz.json         # Prompt with versions
│   ├── prompt_def456_uvw.json
│   └── ...
│
├── workflows/
│   ├── templates/
│   │   ├── default_portrait.json      # Workflow template
│   │   └── ...
│   └── generated/
│       ├── workflow_def456_uvw.json   # Generated workflow record
│       └── ...
│
├── results/
│   ├── result_ghi789_jkl.json         # Result metadata
│   ├── result_xyz123_abc.json
│   ├── galleries/
│   │   ├── gallery_stu345_vwx.json   # Gallery index
│   │   └── ...
│   └── master-images/
│       ├── prompt_abc123_xyz_master.json  # Master image reference
│       └── ...
│
└── backups/
    ├── workflow_timestamp_hash.json   # Workflow backups
    └── ...
```

---

## 7. Workflow Templates

### Custom Workflow Template
```json
{
  "id": "custom_template_xyz",
  "name": "Custom Hairstyle Generator",
  "description": "Custom workflow for specific hairstyles",
  "baseWorkflow": {
    "1": { "class_type": "CheckpointLoader", "inputs": {...} },
    "2": { "class_type": "CLIPTextEncode", "inputs": {...} },
    ...
  },
  "parameterSchema": {
    "seed": { "type": "number", "min": 0, "max": 9999999 },
    "steps": { "type": "number", "min": 1, "max": 100 },
    "cfg": { "type": "number", "min": 1, "max": 20 },
    "sampler": { "type": "string", "enum": ["euler", "dpmpp", "lms"] },
    "width": { "type": "number", "enum": [512, 768, 1024] },
    "height": { "type": "number", "enum": [512, 768, 1024] }
  },
  "category": "portrait",
  "createdAt": "2026-02-19T10:00:00Z",
  "version": 1
}
```

---

## 8. Data Modification & Versioning

### When You Modify a Prompt:

1. **Original Prompt Preserved:**
   - Old versions stay in `versions` array
   - Can revert to any previous version

2. **New Version Created:**
   - New version object added to `versions`
   - `mainPrompt` and `negativePrompt` updated
   - `updatedAt` timestamp set

3. **Results Tracked:**
   - Old results still reference old prompt version
   - New generations use new prompt version
   - Gallery shows all results with versioning

### Example Modification:
```
Initial: version 1 (steps: 20, cfg: 7.0)
   ↓
Update prompt (increase quality)
   ↓
Create: version 2 (steps: 25, cfg: 8.0)
   ↓
Both versions available in `prompt.versions`
   ↓
New generations use version 2
   ↓
Can compare results from both versions in gallery
```

---

## 9. Comparison & Selection

### Get Comparison Data:
```json
{
  "promptId": "prompt_abc123_xyz",
  "masterImage": {
    "id": "master_mno012_pqr",
    "resultId": "result_ghi789_jkl",
    "imageIndex": 0,
    "image": {...}
  },
  "results": [
    {
      "id": "result_ghi789_jkl",
      "timestamp": "2026-02-19T10:35:45Z",
      "executionTime": 45000,
      "isMaster": true,
      "images": [...]
    },
    {
      "id": "result_xyz123_abc",
      "timestamp": "2026-02-19T10:40:00Z",
      "executionTime": 42000,
      "isMaster": false,
      "images": [...]
    }
  ],
  "totalResults": 2
}
```

---

## 10. Export Format

### Complete Export (for archival):
```json
{
  "prompt": { /* Full prompt with versions */ },
  "results": [
    { /* All results for this prompt */ }
  ],
  "comparison": {
    "masterImage": { /* Selected master */ },
    "results": [ /* All results */ ]
  },
  "exportedAt": "2026-02-19T12:00:00Z"
}
```

---

## Summary

| Entity | Purpose | Location | Key Content |
|--------|---------|----------|-------------|
| **Prompt** | Store text & instructions | `prompts/` | mainPrompt, versions, instructions |
| **Workflow** | Generated execution plan | `workflows/` | ComfyUI JSON, parameters, status |
| **Result** | Generated images metadata | `results/` | Images, execution time, metadata |
| **Master** | Selected best image | `master-images/` | Reference to best result |
| **Gallery** | Collection of results | `galleries/` | Results, totals, organization |

All data is **JSON-based** for easy:
- Version control
- Human readability
- Integration with databases
- Archival and export
- Programmatic access
