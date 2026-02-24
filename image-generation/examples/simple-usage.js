/**
 * Simple Usage Example
 * 
 * The simplest way to generate images with proper prompt tracking,
 * results management, and master image selection.
 */

const GenerationSystem = require('./generation-system');

async function main() {
  console.log('\n═══════════════════════════════════════════════════════════════');
  console.log('           Simple Image Generation with Tracking');
  console.log('═══════════════════════════════════════════════════════════════\n');

  // Initialize the system
  const system = new GenerationSystem();

  try {
    // 🎨 EXAMPLE 1: Generate a single image
    console.log('📝 EXAMPLE 1: Generate and Track a Single Image\n');

    const result1 = await system.generateFromPrompt({
      promptName: 'Professional Portrait',
      mainPrompt: 'A professional studio portrait of a man with a modern undercut haircut, perfect lighting, sharp focus, high quality photography',
      negativePrompt: 'blurry, distorted, bad lighting, low quality',
      style: 'portrait',
      category: 'haircut',
      tags: ['portrait', 'professional', 'modern'],
      parameters: {
        seed: Math.random() * 1000000,
        steps: 25,
        cfg: 8.0,
      },
      waitForCompletion: false, // Don't wait - just submit
    });

    console.log(`✅ Generation submitted`);
    console.log(`   Prompt ID: ${result1.prompt.id}`);
    console.log(`   Workflow ID: ${result1.workflow.id}`);
    console.log(`   ComfyUI Prompt: ${result1.promptId}\n`);

    // 🎨 EXAMPLE 2: Create variations with different styles
    console.log('📝 EXAMPLE 2: Create Multiple Variations\n');

    const styles = [
      {
        name: 'Fade Haircut',
        prompt: 'Professional portrait with a clean fade haircut, sharp lines, perfect grooming',
      },
      {
        name: 'Modern Slicked Back',
        prompt: 'Professional portrait with modern slicked back hairstyle, polished look',
      },
      {
        name: 'Textured Top',
        prompt: 'Professional portrait with textured top haircut, casual yet professional',
      },
    ];

    console.log('Creating 3 variations of the same style:\n');

    for (const style of styles) {
      const result = await system.generateFromPrompt({
        promptName: `Portrait - ${style.name}`,
        mainPrompt: `A professional portrait of a man with ${style.prompt}`,
        negativePrompt: 'blurry, bad lighting, distorted proportions',
        style: 'portrait',
        category: 'haircut',
        tags: ['variation', style.name.toLowerCase()],
        parameters: {
          seed: Math.random() * 1000000,
          steps: 25,
          cfg: 7.5,
        },
        waitForCompletion: false,
      });

      console.log(`  ✅ ${style.name} - Submitted`);
      console.log(`     Prompt: ${result.prompt.id}`);
    }

    console.log('\n');

    // 📊 EXAMPLE 3: List all prompts
    console.log('📝 EXAMPLE 3: List All Prompts\n');

    const allPrompts = await system.listPrompts({
      category: 'haircut',
    });

    console.log(`Found ${allPrompts.length} haircut prompts:\n`);
    allPrompts.forEach((prompt, idx) => {
      console.log(`${idx + 1}. ${prompt.name}`);
      console.log(`   ID: ${prompt.id}`);
      console.log(`   Versions: ${prompt.versions.length}`);
      console.log(`   Tags: ${prompt.tags.join(', ')}\n`);
    });

    // ✏️ EXAMPLE 4: Update a prompt and create new version
    console.log('📝 EXAMPLE 4: Update Prompt (Create New Version)\n');

    if (allPrompts.length > 0) {
      const promptToUpdate = allPrompts[0];
      console.log(`Original Prompt: "${promptToUpdate.mainPrompt.substring(0, 60)}..."`);

      const updated = await system.updatePrompt(promptToUpdate.id, {
        mainPrompt: promptToUpdate.mainPrompt + ', with visible beard, well-groomed ',
        negativePrompt: promptToUpdate.negativePrompt,
      });

      console.log(`\nUpdated Prompt: "${updated.mainPrompt.substring(0, 60)}..."`);
      console.log(`New Version: ${updated.versions.length}`);
      console.log(`\nVersion History:`);

      updated.versions.forEach(v => {
        console.log(`  Version ${v.version}: Created ${v.createdAt}`);
      });
    }

    console.log('\n');

    // 🖼️ EXAMPLE 5: View gallery for a prompt
    console.log('📝 EXAMPLE 5: View Gallery & Comparison\n');

    if (allPrompts.length > 0) {
      const promptId = allPrompts[0].id;

      const comparison = await system.compareResults(promptId);

      console.log(`Prompt: ${allPrompts[0].name}`);
      console.log(`Total Results: ${comparison.totalResults}`);
      console.log(`Master Image: ${comparison.masterImage ? '⭐ SET' : 'Not set'}`);

      console.log(`\nResults:`);
      comparison.results.forEach((result, idx) => {
        const master = result.isMaster ? ' ⭐ MASTER' : '';
        console.log(`  ${idx + 1}. ${result.id}${master}`);
        console.log(`     Time: ${result.executionTime}ms`);
        console.log(`     Images: ${result.images.length}`);
      });

      // 🏆 EXAMPLE 6: Set a result as master image
      console.log('\n📝 EXAMPLE 6: Set Master Image\n');

      if (comparison.results.length > 0) {
        const firstResult = comparison.results[0];
        const master = await system.setMaster(promptId, firstResult.id, 0);

        console.log(`✅ Set master image`);
        console.log(`   File: ${master.image.filename}`);
        console.log(`   Size: ${master.image.size}`);
        console.log(`   Selected: ${master.metadata.selectedAsMaster}`);
      }
    }

    // 💾 EXAMPLE 7: Export data
    console.log('\n📝 EXAMPLE 7: Export Complete Dataset\n');

    if (allPrompts.length > 0) {
      const exported = await system.exportAll(allPrompts[0].id);

      console.log(`✅ Exported data for: ${exported.prompt.name}`);
      console.log(`   Prompt versions: ${exported.prompt.versions.length}`);
      console.log(`   Results: ${exported.results.results.length}`);
      console.log(`   Master image: ${exported.comparison.masterImage ? 'Included' : 'Not set'}`);
    }

    console.log('\n═══════════════════════════════════════════════════════════════');
    console.log('✨ Examples Completed!');
    console.log('═══════════════════════════════════════════════════════════════\n');

    console.log('Key Features Used:');
    console.log('  ✅ Create prompts with full text');
    console.log('  ✅ Generate variations\n');
    console.log('  ✅ Track all generations\n');
    console.log('  ✅ Version prompt updates\n');
    console.log('  ✅ View galleries\n');
    console.log('  ✅ Set master images\n');
    console.log('  ✅ Export data\n');

    console.log('JSON Files Created:');
    console.log('  📄 data/prompts/*.json');
    console.log('  📄 data/workflows/generated/*.json');
    console.log('  📄 data/results/*.json');
    console.log('  📄 data/results/galleries/*.json');
    console.log('  📄 data/results/master-images/*.json\n');

    console.log('Next Steps:');
    console.log('  1. Modify prompts and watch new versions');
    console.log('  2. Wait for actual ComfyUI completions');
    console.log('  3. Select best images as master');
    console.log('  4. Compare all results\n');

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    process.exit(1);
  } finally {
    await system.disconnect();
    console.log('Disconnected from ComfyUI');
  }
}

main();
