/**
 * Complete Workflow Example
 * 
 * This example demonstrates the full workflow:
 * 1. Create a prompt with instructions
 * 2. Generate a workflow from the prompt
 * 3. Submit it to ComfyUI
 * 4. Track the result
 * 5. Set a master image
 * 6. View the gallery
 */

const ComfyUIGenerator = require('./comfyui-generator');
const PromptManager = require('./prompt-manager');
const WorkflowManager = require('./workflow-manager');
const ResultsManager = require('./results-manager');
const config = require('./config');
const path = require('path');

async function main() {
  console.log('\n═══════════════════════════════════════════════════════════════');
  console.log('   Complete Workflow: Prompt → Workflow → Generation → Gallery');
  console.log('═══════════════════════════════════════════════════════════════\n');

  // Initialize managers
  const generator = new ComfyUIGenerator({
    serverUrl: config.server.url,
    outputDir: config.storage.outputDir,
  });

  const promptMgr = new PromptManager({
    dataDir: config.storage.outputDir,
  });

  const workflowMgr = new WorkflowManager({
    dataDir: config.storage.outputDir,
  });

  const resultsMgr = new ResultsManager({
    dataDir: config.storage.outputDir,
  });

  try {
    // Step 1: Create a prompt
    console.log('\n📝 Step 1: Creating a Prompt\n');
    
    const prompt = await promptMgr.createPrompt({
      name: 'Professional Haircut Portrait',
      description: 'High-quality portrait of a man with a professional haircut',
      mainPrompt: 'A professional portrait photo of a man, well-groomed with a modern stylish haircut, perfect skin, studio lighting, sharp focus, high quality, 8k, professional photography',
      negativePrompt: 'blurry, low quality, distorted face, asymmetrical, bad proportions, noise',
      style: 'portrait',
      category: 'haircut',
      tags: ['portrait', 'professional', 'haircut', 'male'],
      instructions: {
        '4': { // KSampler node
          'seed': Math.floor(Math.random() * 1000000),
          'steps': 25,
          'cfg': 8.0,
        }
      },
    });

    console.log(`✅ Created prompt: ${prompt.name}`);
    console.log(`   ID: ${prompt.id}`);
    console.log(`   Positive: "${prompt.mainPrompt.substring(0, 60)}..."`);
    console.log(`   Negative: "${prompt.negativePrompt.substring(0, 60)}..."`);

    // Step 2: Create workflow template
    console.log('\n⚙️ Step 2: Creating Workflow Template\n');

    const defaultWorkflow = workflowMgr.getDefaultPortraitWorkflow();
    
    // You would normally save this to disk first
    // const template = await workflowMgr.createTemplate({...})

    // For now, we'll use the default
    const templateData = {
      id: 'default_portrait',
      baseWorkflow: defaultWorkflow,
    };

    console.log(`✅ Using default portrait workflow template`);
    console.log(`   Base nodes: ${Object.keys(defaultWorkflow).length}`);

    // Step 3: Generate workflow from prompt
    console.log('\n🔧 Step 3: Generating Workflow from Prompt\n');

    const workflowRecord = await workflowMgr.generateWorkflow(
      'default_portrait',
      {
        seed: prompt.instructions['4']?.seed || Math.random() * 1000000,
        steps: prompt.instructions['4']?.steps || 20,
        cfg: prompt.instructions['4']?.cfg || 7.0,
      },
      prompt
    );

    console.log(`✅ Generated workflow: ${workflowRecord.id}`);
    console.log(`   Template: ${workflowRecord.templateId}`);
    console.log(`   Prompt: ${workflowRecord.promptId}`);
    console.log(`   Status: ${workflowRecord.status}`);

    // Step 4: Submit to ComfyUI
    console.log('\n🚀 Step 4: Submitting to ComfyUI\n');

    const promptId = await generator.submitWorkflow(workflowRecord.workflow);
    
    console.log(`✅ Submitted to ComfyUI`);
    console.log(`   Prompt ID: ${promptId}`);

    // Update workflow status
    await workflowMgr.updateWorkflowStatus(workflowRecord.id, 'submitted', {
      promptId,
      submittedAt: new Date().toISOString(),
    });

    // Step 5: Wait for completion (in real scenario)
    console.log('\n⏳ Step 5: Monitoring Execution\n');
    console.log(`   Connect WebSocket and wait for real-time updates...`);
    console.log(`   In production, this would:
     - Monitor execution_start
     - Track executing nodes
     - Show progress bars
     - Handle errors
     - Download images on completion`);

    // Simulate completion with mock result
    const mockResult = {
      promptId,
      workflowId: workflowRecord.id,
      images: [
        {
          filename: 'barb_cut_portrait_001.png',
          path: path.join(config.storage.outputDir, 'barb_cut_portrait_001.png'),
          bytes: 2500000,
        },
      ],
      executionTime: 45000,
      nodeCount: 7,
      metadata: {
        model: 'model.safetensors',
        sampler: 'euler',
        steps: 25,
        cfg: 8.0,
        seed: workflowRecord.parameters.seed,
      },
    };

    // Step 6: Save result
    console.log('\n💾 Step 6: Saving Results\n');

    const result = await resultsMgr.saveResult({
      promptId: prompt.id,
      workflowId: workflowRecord.id,
      images: mockResult.images,
      executionTime: mockResult.executionTime,
      nodeCount: mockResult.nodeCount,
      metadata: mockResult.metadata,
    });

    console.log(`✅ Saved result: ${result.id}`);
    console.log(`   Images: ${result.images.length}`);
    console.log(`   Execution time: ${result.executionTime}ms`);

    // Step 7: Set master image
    console.log('\n⭐ Step 7: Setting Master Image\n');

    const masterImage = await resultsMgr.setMasterImage(prompt.id, result.id, 0);

    console.log(`✅ Set master image`);
    console.log(`   File: ${masterImage.image.filename}`);
    console.log(`   Size: ${masterImage.image.size}`);

    // Step 8: Create gallery
    console.log('\n🎨 Step 8: Creating Gallery\n');

    const gallery = await resultsMgr.createGallery(prompt.id, {
      name: 'Professional Haircut Portraits',
      description: 'Gallery of generated portrait images',
      includeAllResults: true,
    });

    console.log(`✅ Created gallery: ${gallery.name}`);
    console.log(`   Gallery ID: ${gallery.id}`);
    console.log(`   Results: ${gallery.results.length}`);
    console.log(`   Total images: ${gallery.totalImages}`);

    // Step 9: Get comparison view
    console.log('\n📊 Step 9: Generating Comparison\n');

    const comparison = await resultsMgr.getComparison(prompt.id, 10);

    console.log(`✅ Comparison data:`);
    console.log(`   Master image: ${comparison.masterImage ? 'Set' : 'Not set'}`);
    console.log(`   Total results: ${comparison.totalResults}`);
    console.log(`   Results breakdown:`);
    
    for (const result of comparison.results) {
      const isMasterLabel = result.isMaster ? ' ⭐ MASTER' : '';
      console.log(`     - ${result.id}: ${result.images.length} image(s)${isMasterLabel}`);
    }

    // Step 10: Display summary
    console.log('\n📋 Step 10: Summary\n');

    console.log('Prompt Information:');
    console.log(`  Name: ${prompt.name}`);
    console.log(`  ID: ${prompt.id}`);
    console.log(`  Category: ${prompt.category}`);
    console.log(`  Tags: ${prompt.tags.join(', ')}`);
    console.log(`  Versions: ${prompt.versions.length}`);

    console.log('\nWorkflow Information:');
    console.log(`  ID: ${workflowRecord.id}`);
    console.log(`  Status: ${workflowRecord.status}`);
    console.log(`  Parameters: ${JSON.stringify(workflowRecord.parameters, null, 2)}`);

    console.log('\nResult Information:');
    console.log(`  ID: ${result.id}`);
    console.log(`  Status: ${result.status}`);
    console.log(`  Images: ${result.images.length}`);
    console.log(`  Execution Time: ${result.executionTime}ms`);

    console.log('\nGallery Information:');
    console.log(`  ID: ${gallery.id}`);
    console.log(`  Name: ${gallery.name}`);
    console.log(`  Results: ${gallery.results.length}`);

    // Step 11: Generate HTML gallery
    console.log('\n🌐 Step 11: Generating HTML Gallery\n');

    const galleryHTML = await resultsMgr.generateGalleryHTML(prompt.id);
    console.log(`✅ Generated HTML gallery (${galleryHTML.length} bytes)`);
    console.log(`   Open in browser to view all images and master image`);

    // Step 12: Show how to update prompt
    console.log('\n📝 Step 12: Updating Prompt (Demonstrates Versioning)\n');

    const updatedPrompt = await promptMgr.updatePrompt(prompt.id, {
      mainPrompt: 'A professional studio portrait of a man with a contemporary stylish haircut, perfect lighting, sharp focus, high resolution, professional photography',
      negativePrompt: 'blurry, distorted, bad quality, noise',
      instructions: {
        '4': {
          'seed': Math.floor(Math.random() * 1000000),
          'steps': 30,
          'cfg': 8.5,
        }
      },
    });

    console.log(`✅ Updated prompt`);
    console.log(`   New version: ${updatedPrompt.versions.length}`);
    console.log(`   Previous versions preserved for comparison`);

    console.log('\n═══════════════════════════════════════════════════════════════');
    console.log('✨ Complete Workflow Demonstration Finished!');
    console.log('═══════════════════════════════════════════════════════════════\n');

    console.log('Summary of what was created:');
    console.log(`  ✅ Prompt: ${prompt.id}`);
    console.log(`  ✅ Workflow: ${workflowRecord.id}`);
    console.log(`  ✅ Result: ${result.id}`);
    console.log(`  ✅ Gallery: ${gallery.id}`);
    console.log(`  ✅ Master Image: Set`);
    console.log(`\nNext Steps:`);
    console.log(`  1. Modify the prompt text to see new versions`);
    console.log(`  2. Generate more images to populate the gallery`);
    console.log(`  3. Compare results and select best ones`);
    console.log(`  4. View HTML gallery in browser`);
    console.log(`  5. Export results as JSON for archival`);

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    process.exit(1);
  } finally {
    await generator.disconnect();
  }
}

main();
