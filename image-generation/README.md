/**
 * README for ComfyUI Image Generation Integration
 * 
 * This directory contains scripts to integrate Barb Cut with ComfyUI
 * for professional image generation.
 */

# ComfyUI Image Generation for Barb Cut

## Overview

This integration enables Barb Cut to generate high-quality portrait images using ComfyUI, a powerful node-based interface for generative AI.

## Quick Start

### 1. Prerequisites

- **Node.js** >= 14.0.0
- **ComfyUI** installed and running locally (http://localhost:8188)
- Required npm packages

### 2. Setup

```bash
# Install dependencies
npm install

# Copy environment configuration
cp .env.example .env

# Create required directories
mkdir -p data/results data/backups data/workflows logs
```

### 3. Configure ComfyUI

Edit `.env` and set:
```
COMFYUI_SERVER_URL=http://localhost:8188
COMFYUI_OUTPUT_DIR=./data/results
COMFYUI_BACKUP_DIR=./data/backups
```

Ensure ComfyUI is running:
```bash
# In another terminal, run ComfyUI
python main.py  # From ComfyUI directory
```

### 4. Test Connection

```bash
npm run test
```

This will:
- Connect to ComfyUI server
- Display system information
- Check available GPU/VRAM
- Verify queue status

### 5. Run First Generation

```bash
npm run example:basic
```

This generates a sample portrait image and saves it locally.

## File Structure

```
image-generation/
├── comfyui-generator.js          # Main generation engine
├── config.js                     # Configuration management
├── utils.js                      # Utility functions
├── package.json                  # Dependencies
├── .env.example                  # Example configuration
├── COMFYUI_INTEGRATION_PLAN.md   # Architecture & design
│
├── examples/
│   ├── basic-generation.js       # Simple portrait generation
│   ├── test-connection.js        # Connection test
│   └── submit-workflow.js        # Submit custom workflow
│
└── data/
    ├── results/                  # Generated images
    ├── backups/                  # Workflow backups
    ├── workflows/                # Workflow templates
    └── cache/                    # Cached generations
```

## Key Modules

### ComfyUIGenerator (`comfyui-generator.js`)

Main class for image generation:

```javascript
const ComfyUIGenerator = require('./comfyui-generator');

const generator = new ComfyUIGenerator({
  serverUrl: 'http://localhost:8188',
  outputDir: './data/results',
  timeout: 600000,
});

// Generate images
await generator.generateImages({
  workflow: { /* ComfyUI workflow */ },
  metadata: { userInitials: 'BC', style: 'portrait' },
  callbacks: {
    onProgress: (progress) => console.log(progress),
    onComplete: (result) => console.log('Done!'),
  }
});
```

**Key Methods:**
- `generateImages(options)` - Submit workflow and wait for completion
- `submitWorkflow(workflow)` - Submit without waiting
- `downloadImage(filename)` - Download generated image
- `getQueueStatus()` - Check queue
- `getSystemStats()` - Get GPU/memory info
- `interrupt()` - Stop execution

### Configuration (`config.js`)

Centralized configuration from environment variables:

```javascript
const config = require('./config');

console.log(config.server.url);
console.log(config.storage.outputDir);
console.log(config.features.backupWorkflows);
```

### Utilities (`utils.js`)

Helper functions:

```javascript
const { generateId, formatDuration, parseWorkflow } = require('./utils');

const id = generateId('gen');  // gen_abc123_xyz
const duration = formatDuration(45000);  // "45s"
const meta = parseWorkflow(workflow);  // Parse workflow structure
```

## Workflows

ComfyUI workflows are JSON objects where nodes are connected:

```json
{
  "1": {
    "class_type": "CheckpointLoader",
    "inputs": { "ckpt_name": "model.safetensors" }
  },
  "2": {
    "class_type": "CLIPTextEncode",
    "inputs": {
      "text": "A professional portrait",
      "clip": ["1", 1]
    }
  }
}
```

**Node Reference Format:**
- `["node_id", output_index]` - References another node's output

## Real-time Monitoring

ComfyUI uses WebSocket for real-time updates:

- `execution_start` - Workflow starts
- `executing` - Node execution
- `progress` - Progress updates
- `executed` - Node completion with UI output
- `execution_success` - All nodes completed
- `execution_error` - Execution failed

The generator automatically handles these messages.

## Image Retrieval

Generated images are:
1. Retrieved from ComfyUI's output directory via `/view` endpoint
2. Saved locally to `data/results/`
3. Metadata saved as JSON alongside the image

```javascript
const result = await generator.generateImages({...});
// result.images[0].path = '/Users/user/path/barb_cut_portrait_001.png'
// result.images[0].path + '.json' contains metadata
```

## Error Handling

The generator includes comprehensive error handling:

```javascript
try {
  await generator.generateImages({
    workflow,
    callbacks: {
      onError: (error) => {
        console.error('Generation failed:', error.message);
      }
    }
  });
} catch (error) {
  // Workflow validation failed or other errors
  console.error('Error:', error.message);
}
```

**Common Errors:**
- `Workflow validation error` - Invalid workflow structure
- `Generation timeout` - Took too long
- `ECONNREFUSED` - ComfyUI not running
- Node-specific errors from ComfyUI

## Performance Tips

1. **Batch Generation**: Submit multiple workflows
2. **Caching**: Enable `COMFYUI_CACHE_GENERATIONS=true`
3. **Model Preloading**: Set `COMFYUI_PRELOAD_MODELS` to load models on startup
4. **Optimization**: Enable `COMFYUI_ENABLE_OPTIMIZATION=true` for faster inference

## Monitoring

Check execution logs:

```javascript
const logs = generator.getExecutionLog();
// Array of execution objects with status, timing, etc.

generator.clearCompletedExecutions();
// Clean up completed executions
```

## Troubleshooting

### "Cannot connect to ComfyUI"
- Ensure ComfyUI is running: `python main.py`
- Check `COMFYUI_SERVER_URL` in `.env`
- Verify ComfyUI is listening on port 8188

### "Workflow validation error"
- Check node IDs are correct
- Verify node connections: `["node_id", output_index]`
- Ensure all required inputs are provided

### "Generation timeout"
- Increase `COMFYUI_TIMEOUT` in `.env`
- Check GPU memory with `npm run test`
- Reduce image resolution or quality settings

### "No images in result"
- Ensure workflow includes `SaveImage` node
- Check output directory exists
- Verify image formats are supported

## Advanced Usage

### Custom Workflows

```javascript
const myWorkflow = {
  // Your custom nodes here
};

const result = await generator.generateImages({
  workflow: myWorkflow,
  workflowId: 'my_custom_workflow',
  metadata: {
    customField: 'value'
  }
});
```

### Batch Processing

```javascript
const workflows = [workflow1, workflow2, workflow3];

for (const workflow of workflows) {
  const result = await generator.generateImages({ workflow });
  console.log(`Generated: ${result.images[0].path}`);
}
```

### Progress Tracking

```javascript
await generator.generateImages({
  workflow,
  callbacks: {
    onProgress: (progress) => {
      console.log(`${progress.node}: ${progress.percent}%`);
    }
  }
});
```

## Integration with Barb Cut

To integrate with the Barb Cut Flutter app:

1. **API Endpoint**: Create Express/REST endpoint in backend
2. **Workflow Templates**: Store in `data/workflows/`
3. **Image Storage**: Save to Firebase Storage
4. **User Data**: Load styles from Barb Cut assets

See `COMFYUI_INTEGRATION_PLAN.md` for detailed architecture.

## API Reference

See [ComfyUI Documentation](https://docs.comfy.org/) for:
- Complete list of built-in nodes
- Custom node development
- API routes and parameters
- WebSocket message types

## Support

For issues or questions:
1. Check `logs/comfyui.log`
2. Review `COMFYUI_INTEGRATION_PLAN.md`
3. Test with `npm run test`
4. Check ComfyUI console for node errors

## License

MIT
