/**
 * Prompt and Gallery Management Example
 * 
 * This example shows how to:
 * - Create and manage prompts
 * - Track different prompt versions
 * - Create galleries
 * - Compare results
 * - Set master images
 */

const PromptManager = require('../prompt-manager');
const ResultsManager = require('../results-manager');
const config = require('../config');

async function main() {
  console.log('\n═══════════════════════════════════════════════════════════════');
  console.log('      Prompt & Gallery Management Example');
  console.log('═══════════════════════════════════════════════════════════════\n');

  const promptMgr = new PromptManager({
    dataDir: config.storage.outputDir,
  });

  const resultsMgr = new ResultsManager({
    dataDir: config.storage.outputDir,
  });

  try {
    // Create multiple prompts
    console.log('📝 Creating Prompts\n');

    const haircuts = [
      {
        name: 'Modern Undercut',
        prompt: 'A professional portrait of a man with a modern undercut haircut, cleanly faded sides, well-styled top, perfect skin texture, studio lighting, sharp focus, high quality photography',
        negative: 'blurry, distorted, bad proportions, uneven haircut',
      },
      {
        name: 'Fade Haircut',
        prompt: 'Professional portrait of a man with a clean fade haircut, perfect gradient on sides, sharp lines, professional grooming, studio lighting, high quality, 8k resolution',
        negative: 'blurry, low quality, patchy, uneven fade',
      },
      {
        name: 'Textured Top',
        prompt: 'Portrait of a man with a textured top haircut, messy yet styled, medium-length on top, faded sides, modern style, professional photography, warm lighting, high detail',
        negative: 'too long, unkempt, sparse, bald spots',
      },
      {
        name: 'Classic Slicked Back',
        prompt: 'Professional portrait of a man with classic slicked back hairstyle, long on top, shaved sides, perfect grooming, vintage style, professional lighting, sharp focus, detailed',
        negative: 'messy, greasy, unclean, bad lighting',
      },
      {
        name: 'Pompadour Style',
        prompt: 'Portrait of a man with a high pompadour hairstyle, voluminous top, defined sides, well-groomed beard, retro-modern style, professional lighting, high quality, detailed',
        negative: 'flat hair, low volume, unclear style, messy',
      },
    ];

    const prompts = [];
    for (const haircut of haircuts) {
      const prompt = await promptMgr.createPrompt({
        name: haircut.name,
        description: `Portrait with ${haircut.name}`,
        mainPrompt: haircut.prompt,
        negativePrompt: haircut.negative,
        style: 'portrait',
        category: 'haircut',
        tags: ['portrait', 'haircut', 'professional'],
        instructions: {
          '4': {
            seed: Math.floor(Math.random() * 1000000),
            steps: 25,
            cfg: 8.0,
          }
        },
      });
      prompts.push(prompt);
      console.log(`  ✅ ${prompt.name}`);
    }

    // List all prompts
    console.log('\n📋 Listing All Prompts\n');

    const allPrompts = await promptMgr.listPrompts({ category: 'haircut' });
    console.log(`Found ${allPrompts.length} haircut prompts:`);
    allPrompts.forEach(p => {
      console.log(`  - ${p.name} (${p.id})`);
      console.log(`    Versions: ${p.versions.length}`);
      console.log(`    Tags: ${p.tags.join(', ')}`);
    });

    // Update a prompt (create new version)
    console.log('\n📝 Updating Prompt (Creating New Version)\n');

    const firstPrompt = prompts[0];
    console.log(`Original: "${firstPrompt.mainPrompt.substring(0, 60)}..."`);

    const updatedPrompt = await promptMgr.updatePrompt(firstPrompt.id, {
      mainPrompt: firstPrompt.mainPrompt + ', with visible beard',
      negativePrompt: 'clean shaven, no beard',
    });

    console.log(`Updated: "${updatedPrompt.mainPrompt.substring(0, 60)}..."`);
    console.log(`Total versions: ${updatedPrompt.versions.length}`);

    // Show version history
    console.log('\n📚 Version History\n');

    const versions = await promptMgr.getPromptVersions(firstPrompt.id);
    versions.forEach(v => {
      console.log(`  Version ${v.version}:`);
      console.log(`    Created: ${v.createdAt}`);
      console.log(`    Prompt: "${v.mainPrompt.substring(0, 50)}..."`);
    });

    // Create galleries for each prompt
    console.log('\n🎨 Creating Galleries\n');

    const galleries = [];
    for (const prompt of prompts.slice(0, 2)) { // Create galleries for first 2 prompts
      // Note: In real usage, you'd have results to add to gallery
      // Here we're just demonstrating gallery creation
      
      // Create mock results first (simplified)
      const mockResult = await resultsMgr.saveResult({
        promptId: prompt.id,
        workflowId: 'workflow_' + prompt.id,
        images: [
          {
            filename: `generated_${prompt.id}_001.png`,
            path: `/path/to/images/${prompt.id}_001.png`,
            bytes: 2500000,
          }
        ],
        executionTime: 45000,
        nodeCount: 7,
        metadata: {
          model: 'model.safetensors',
          steps: 25,
          cfg: 8.0,
          seed: Math.floor(Math.random() * 1000000),
        },
      });

      const gallery = await resultsMgr.createGallery(prompt.id, {
        name: `${prompt.name} - Gallery`,
        description: `Generated images for ${prompt.name}`,
      });

      galleries.push(gallery);
      
      console.log(`  ✅ Created gallery for "${prompt.name}"`);
      console.log(`     Gallery ID: ${gallery.id}`);
      console.log(`     Results: ${gallery.results.length}`);

      // Set master image
      const masterImage = await resultsMgr.setMasterImage(prompt.id, mockResult.id, 0);
      console.log(`     Master image set ⭐`);
    }

    // Compare results for a prompt
    console.log('\n📊 Comparison View for First Prompt\n');

    const comparisonPrompt = prompts[0];
    const comparison = await resultsMgr.getComparison(comparisonPrompt.id, 10);

    console.log(`Prompt: ${comparisonPrompt.name}`);
    console.log(`Master Image: ${comparison.masterImage ? 'Set ⭐' : 'Not set'}`);
    if (comparison.masterImage) {
      console.log(`  File: ${comparison.masterImage.image.filename}`);
      console.log(`  Size: ${comparison.masterImage.image.size}`);
    }

    console.log(`\nResults (${comparison.totalResults} total):`);
    comparison.results.forEach(result => {
      const master = result.isMaster ? ' ⭐ MASTER' : '';
      console.log(`  - ${result.id}${master}`);
      console.log(`    Execution time: ${result.executionTime}ms`);
      console.log(`    Images: ${result.images.length}`);
    });

    // Export results
    console.log('\n💾 Exporting Data\n');

    const exported = await resultsMgr.exportResults(prompts[0].id, 50);
    console.log(`✅ Exported results for ${prompts[0].name}`);
    console.log(`   Results exported: ${exported.results.length}`);
    console.log(`   Master image: ${exported.masterImage ? 'Included' : 'Not set'}`);

    // Summary
    console.log('\n═══════════════════════════════════════════════════════════════');
    console.log('✨ Summary');
    console.log('═══════════════════════════════════════════════════════════════\n');

    console.log(`📝 Prompts Created: ${prompts.length}`);
    prompts.forEach(p => {
      console.log(`   - ${p.name} (${p.versions.length} version${p.versions.length > 1 ? 's' : ''})`);
    });

    console.log(`\n🎨 Galleries Created: ${galleries.length}`);
    galleries.forEach(g => {
      console.log(`   - ${g.name}`);
    });

    console.log('\n💡 Key Features Demonstrated:');
    console.log('   ✅ Create multiple prompts');
    console.log('   ✅ Update prompts with version history');
    console.log('   ✅ List and filter prompts');
    console.log('   ✅ Create galleries from results');
    console.log('   ✅ Set master images for comparison');
    console.log('   ✅ Generate comparison views');
    console.log('   ✅ Export results as JSON');

    console.log('\n🚀 Next Steps:');
    console.log('   1. Modify prompt text and see new versions');
    console.log('   2. Generate images for each prompt');
    console.log('   3. Compare results across different styles');
    console.log('   4. Select and PIN best images as master');
    console.log('   5. View galleries in HTML format');

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    console.error(error);
    process.exit(1);
  }
}

main();
