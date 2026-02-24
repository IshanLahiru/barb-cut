/**
 * Basic Example: Connect and Submit a Simple Workflow
 * 
 * This example demonstrates:
 * 1. Connecting to a ComfyUI server
 * 2. Submitting a simple text-to-image workflow
 * 3. Monitoring progress in real-time
 * 4. Retrieving and saving generated images
 */

const ComfyUIGenerator = require('../comfyui-generator');
const config = require('../config');

async function main() {
  const generator = new ComfyUIGenerator({
    serverUrl: config.server.url,
    outputDir: config.storage.outputDir,
    backupDir: config.storage.backupDir,
    timeout: config.server.timeout,
  });

  try {
    console.log('🚀 Starting ComfyUI Image Generation Example');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Simple text-to-image workflow
    // NOTE: You need to adjust node IDs and model names based on your ComfyUI setup
    const workflow = {
      "1": {
        "class_type": "CheckpointLoader",
        "inputs": {
          "ckpt_name": "model.safetensors" // Change to your model name
        }
      },
      "2": {
        "class_type": "CLIPTextEncode",
        "inputs": {
          "text": "A professional portrait photo of a man with a stylish haircut, studio lighting, high quality, detailed",
          "clip": ["1", 1]
        }
      },
      "3": {
        "class_type": "CLIPTextEncode",
        "inputs": {
          "text": "blurry, low quality, distorted",
          "clip": ["1", 1]
        }
      },
      "4": {
        "class_type": "KSampler",
        "inputs": {
          "seed": Math.floor(Math.random() * 1000000),
          "steps": 20,
          "cfg": 7.0,
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
        "inputs": {
          "width": 512,
          "height": 768,
          "batch_size": 1
        }
      },
      "6": {
        "class_type": "VAEDecode",
        "inputs": {
          "samples": ["4", 0],
          "vae": ["1", 2]
        }
      },
      "7": {
        "class_type": "SaveImage",
        "inputs": {
          "filename_prefix": "barb_cut_portrait",
          "images": ["6", 0]
        }
      }
    };

    console.log('\n📋 Workflow Configuration:');
    console.log('  - Model: model.safetensors');
    console.log('  - Prompt: Professional portrait with haircut');
    console.log('  - Size: 512x768');
    console.log('  - Steps: 20');
    console.log('  - CFG: 7.0');

    // Generate with callbacks
    const result = await generator.generateImages({
      workflow,
      workflowId: 'portrait_example',
      metadata: {
        userInitials: 'BC',
        style: 'portrait',
        description: 'Professional portrait generation',
      },
      backupWorkflow: true,

      callbacks: {
        onSubmit: ({ promptId }) => {
          console.log(`\n✅ Workflow submitted with ID: ${promptId}`);
        },

        onStart: () => {
          console.log('\n🔄 Execution started...');
        },

        onNodeExecute: ({ node }) => {
          console.log(`  → Processing node: ${node}`);
        },

        onProgress: ({ node, value, max, percent }) => {
          const bar = '█'.repeat(Math.floor(percent / 5)) + '░'.repeat(20 - Math.floor(percent / 5));
          console.log(`  ⚙️  Node ${node}: [${bar}] ${percent}%`);
        },

        onExecuted: ({ node, output }) => {
          console.log(`  ✓ Node ${node} completed`);
        },

        onComplete: (result) => {
          console.log('\n✨ Generation completed!');
          console.log(`\n📊 Results:`);
          console.log(`  - Prompt ID: ${result.promptId}`);
          console.log(`  - Images generated: ${result.images.length}`);
          console.log(`  - Execution time: ${(result.metadata.executionTime / 1000).toFixed(2)}s`);
          
          if (result.images.length > 0) {
            console.log(`\n🖼️  Generated Images:`);
            result.images.forEach((img, idx) => {
              console.log(`  ${idx + 1}. ${img.filename}`);
              console.log(`     Path: ${img.path}`);
            });
          }
        },

        onError: (error) => {
          console.error('\n❌ Error:', error.message);
        },
      },

      waitForCompletion: true,
    });

    console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('✅ Example completed successfully!');

  } catch (error) {
    console.error('\n❌ Example failed:');
    console.error(error.message);
    process.exit(1);
  } finally {
    await generator.disconnect();
    console.log('\n👋 Disconnected from ComfyUI');
  }
}

main();
