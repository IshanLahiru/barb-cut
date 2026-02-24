# ComfyUI Integration Plan

## Overview
This document outlines the integration strategy for connecting the Barb Cut application with ComfyUI for image generation. ComfyUI is a powerful, node-based interface for generative AI that runs as a local/remote server with REST API and WebSocket support.

## Architecture

### ComfyUI Server Communication Flow
```
Client Application
    ↓
HTTP POST /prompt (Submit Workflow)
    ↓
ComfyUI Server (Validates & Queues)
    ↓
WebSocket /ws (Real-time Updates)
    ↓
execution_start → executing → progress → executed → execution_success
    ↓
Image Retrieval via /view endpoint
    ↓
Client Application
```

## Key Endpoints

### REST API Endpoints

| Endpoint | Method | Purpose | Returns |
|----------|--------|---------|---------|
| `/prompt` | POST | Submit workflow to queue | `{ prompt_id, number }` or error |
| `/queue` | GET | Get current queue status | Queue state |
| `/history` | GET | Get execution history | All completed prompts |
| `/history/{prompt_id}` | GET | Get specific execution result | Execution details |
| `/upload/image` | POST | Upload image to server | Image metadata |
| `/view` | GET | Retrieve generated image | Image file |
| `/system_stats` | GET | Get system info | GPU, memory, Python version |
| `/interrupt` | POST | Stop execution | Acknowledgment |

### WebSocket Endpoint

| Path | Purpose |
|------|---------|
| `/ws` | Real-time bidirectional communication |

## WebSocket Message Types

### Server → Client Messages
- **execution_start**: Workflow execution begins
- **executing**: Node is about to execute (node_id, prompt_id)
- **progress**: Progress update during long operations (node_id, prompt_id, value, max)
- **executed**: Node completes with UI output (node_id, prompt_id, output)
- **execution_cached**: Cached nodes being skipped
- **execution_success**: All nodes completed (prompt_id, timestamp)
- **execution_error**: Execution failed
- **execution_interrupted**: Execution stopped
- **status**: Queue state changed

## Workflow Structure

A ComfyUI workflow is a JSON object where:
- **Keys** are node IDs (typically numbers as strings like "1", "2")
- **Values** contain:
  - `class_type`: Node type name
  - `inputs`: Node parameters (can reference other nodes)
  - Node references use format: `[previous_node_id, output_index]`

Example:
```json
{
  "1": {
    "class_type": "LoadModel",
    "inputs": {"ckpt_name": "model.safetensors"}
  },
  "2": {
    "class_type": "CLIPTextEncode",
    "inputs": {
      "text": "a beautiful landscape",
      "clip": ["1", 1]
    }
  },
  "3": {
    "class_type": "KSampler",
    "inputs": {
      "model": ["1", 0],
      "positive": ["2", 0],
      "steps": 20,
      "cfg": 7.0
    }
  }
}
```

## Implementation Details

### Phase 1: Basic Integration
1. **Server Connection**: Establish connection to ComfyUI instance
2. **Workflow Submission**: Accept workflows and submit to `/prompt` endpoint
3. **Status Tracking**: Monitor execution via WebSocket messages
4. **Image Retrieval**: Save generated images to local storage

### Phase 2: Advanced Features
1. **Workflow Templates**: Store reusable workflow templates
2. **Progress Tracking**: Real-time progress on UI
3. **Error Handling**: Comprehensive error management
4. **Batch Processing**: Queue multiple generations
5. **Model Management**: List available models, switch models

### Phase 3: Optimization
1. **Caching**: Cache generated images by prompt hash
2. **Performance**: Optimize WebSocket usage
3. **Queue Management**: Prioritize/manage generation queue
4. **Resource Monitoring**: Track GPU/memory usage

## Data Schema

### Generation Request
```typescript
{
  workflowId: string;
  workflow: ComfyUIWorkflow;
  metadata: {
    userInitials?: string;
    style?: string;
    timestamp: number;
  };
  callbacks: {
    onProgress?: (progress: ProgressUpdate) => void;
    onComplete?: (result: GenerationResult) => void;
    onError?: (error: Error) => void;
  };
}
```

### Generation Result
```typescript
{
  promptId: string;
  workflowId: string;
  images: {
    filename: string;
    path: string;
    size: { width: number; height: number };
  }[];
  metadata: {
    executionTime: number;
    timestamp: number;
    nodeCount: number;
  };
}
```

## Configuration

### Required Environment Variables
```
COMFYUI_SERVER_URL=http://localhost:8188  # ComfyUI server address
COMFYUI_OUTPUT_DIR=./data/results          # Output directory for generated images
COMFYUI_BACKUP_DIR=./data/backups          # Backup directory for original workflows
COMFYUI_LOG_LEVEL=info                     # Logging level
```

## Error Handling Strategy

1. **Connection Errors**: Retry with exponential backoff
2. **Validation Errors**: Log node errors and invalid parameters
3. **Execution Errors**: Capture and report node-specific failures
4. **Timeout Handling**: Set timeout for long-running generations
5. **Queue Management**: Handle queue overflow scenarios

## Security Considerations

1. **Input Validation**: Validate all workflow inputs
2. **File Access**: Restrict output directory access
3. **CORS**: Configure CORS for frontend requests if needed
4. **Rate Limiting**: Implement rate limits for API endpoints
5. **File Uploads**: Validate uploaded files before processing

## Testing Strategy

1. **Unit Tests**: Test workflow building, validation
2. **Integration Tests**: Test server communication
3. **E2E Tests**: Test complete generation pipeline
4. **Performance Tests**: Measure generation times
5. **Error Scenario Tests**: Test error handling

## File Structure

```
image-generation/
├── COMFYUI_INTEGRATION_PLAN.md (this file)
├── comfyui-generator.js          # Main generation script
├── workflow-manager.js           # Workflow template management
├── server-client.js              # Server communication layer
├── config.js                     # Configuration management
├── utils.js                      # Utility functions
├── .env.example                  # Example environment variables
├── package.json                  # Dependencies
├── data/
│   ├── results/                  # Generated images
│   ├── backups/                  # Workflow backups
│   └── workflows/                # Workflow templates
└── logs/                         # Application logs
```

## Usage Example

```javascript
const generator = require('./comfyui-generator');

const workflow = {
  "1": {
    "class_type": "CheckpointLoader",
    "inputs": { "ckpt_name": "model.safetensors" }
  }
};

await generator.generateImage({
  workflow,
  metadata: { userInitials: "JD", style: "portrait" },
  onProgress: (progress) => console.log(`Progress: ${progress.percent}%`),
  onComplete: (result) => console.log(`Generated: ${result.images[0].path}`)
});
```

## Next Steps

1. ✅ Create comprehensive plan
2. ⏳ Create generation script (`comfyui-generator.js`)
3. ⏳ Create workflow manager (`workflow-manager.js`)
4. ⏳ Create server client (`server-client.js`)
5. ⏳ Setup configuration and environment
6. ⏳ Implement error handling
7. ⏳ Add image retrieval and storage
8. ⏳ Create test suite
9. ⏳ Document API endpoints
10. ⏳ Setup logging

## References

- ComfyUI Documentation: https://docs.comfy.org/
- Server Routes: https://docs.comfy.org/development/comfyui-server/comms_routes
- WebSocket Messages: https://docs.comfy.org/development/comfyui-server/comms_messages
- API Overview: https://docs.comfy.org/development/comfyui-server/comms_overview
