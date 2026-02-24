/**
 * Unified Generation System
 * 
 * Single interface for managing the complete image generation pipeline:
 * Prompt → Workflow → ComfyUI → Results → Gallery → Master Image
 */

const ComfyUIGenerator = require('./comfyui-generator');
const PromptManager = require('./prompt-manager');
const WorkflowManager = require('./workflow-manager');
const ResultsManager = require('./results-manager');
const config = require('./config');
const { generateId } = require('./utils');

class GenerationSystem {
  constructor(customConfig = {}) {
    const mergedConfig = { ...config, ...customConfig };

    this.generator = new ComfyUIGenerator({
      serverUrl: mergedConfig.server.url,
      outputDir: mergedConfig.storage.outputDir,
      backupDir: mergedConfig.storage.backupDir,
    });

    this.prompts = new PromptManager({
      dataDir: mergedConfig.storage.outputDir,
    });

    this.workflows = new WorkflowManager({
      dataDir: mergedConfig.storage.outputDir,
    });

    this.results = new ResultsManager({
      dataDir: mergedConfig.storage.outputDir,
    });

    this.config = mergedConfig;
  }

  /**
   * Complete pipeline: Create prompt → Generate → Track result
   */
  async generateFromPrompt(options = {}) {
    const {
      promptName,
      mainPrompt,
      negativePrompt = '',
      style = 'portrait',
      category = 'haircut',
      tags = [],
      parameters = {},
      instructions = {},
      waitForCompletion = true,
      onProgress = null,
    } = options;

    if (!promptName || !mainPrompt) {
      throw new Error('promptName and mainPrompt are required');
    }

    console.log('\n🚀 Starting Generation Pipeline\n');

    try {
      // Step 1: Create/Update Prompt
      console.log('1️⃣  Creating Prompt...');
      const prompt = await this.prompts.createPrompt({
        name: promptName,
        mainPrompt,
        negativePrompt,
        style,
        category,
        tags,
        instructions,
      });
      console.log(`   ✅ Prompt: ${prompt.id}`);

      // Step 2: Generate Workflow
      console.log('\n2️⃣  Generating Workflow...');
      const workflowRecord = await this.workflows.generateWorkflow(
        'default_portrait',
        parameters,
        prompt
      );
      console.log(`   ✅ Workflow: ${workflowRecord.id}`);

      // Step 3: Submit to ComfyUI
      console.log('\n3️⃣  Submitting to ComfyUI...');
      const promptId = await this.generator.submitWorkflow(workflowRecord.workflow);
      console.log(`   ✅ Prompt ID: ${promptId}`);

      // Update workflow
      await this.workflows.updateWorkflowStatus(workflowRecord.id, 'submitted', {
        promptId,
      });

      // Step 4: Wait for Completion (optional)
      if (waitForCompletion) {
        console.log('\n4️⃣  Monitoring Execution...');
        
        const result = await this.generator.generateImages({
          workflow: workflowRecord.workflow,
          workflowId: workflowRecord.id,
          metadata: {
            promptId: prompt.id,
            style,
          },
          callbacks: {
            onProgress: (prog) => {
              if (onProgress) onProgress(prog);
            },
          },
          waitForCompletion: true,
        });

        console.log(`   ✅ Generation Complete`);
        console.log(`   ⏱️  Time: ${(result.metadata.executionTime / 1000).toFixed(2)}s`);
        console.log(`   🖼️  Images: ${result.images.length}`);

        // Step 5: Save Result
        console.log('\n5️⃣  Saving Results...');
        const savedResult = await this.results.saveResult({
          promptId: prompt.id,
          workflowId: workflowRecord.id,
          images: result.images.map(img => ({
            filename: img.filename,
            path: img.path,
            bytes: 0,
          })),
          executionTime: result.metadata.executionTime,
          nodeCount: result.metadata.nodeCount,
          metadata: {
            style,
            category,
            tags,
            parameters,
          },
        });
        console.log(`   ✅ Result: ${savedResult.id}`);

        return {
          success: true,
          prompt,
          workflow: workflowRecord,
          result: savedResult,
          images: result.images,
        };
      }

      return {
        success: true,
        prompt,
        workflow: workflowRecord,
        promptId,
        status: 'submitted',
      };

    } catch (error) {
      console.error('\n❌ Generation Pipeline Error:');
      console.error(error.message);
      throw error;
    }
  }

  /**
   * Generate HTML gallery for a prompt
   */
  async viewGallery(promptId) {
    return await this.results.generateGalleryHTML(promptId);
  }

  /**
   * Get comparison of all results for a prompt
   */
  async compareResults(promptId, limit = 20) {
    return await this.results.getComparison(promptId, limit);
  }

  /**
   * Set best result as master image
   */
  async setMaster(promptId, resultId, imageIndex = 0) {
    return await this.results.setMasterImage(promptId, resultId, imageIndex);
  }

  /**
   * Get master image for a prompt
   */
  async getMaster(promptId) {
    return await this.results.getMasterImage(promptId);
  }

  /**
   * List all prompts
   */
  async listPrompts(filter = {}) {
    return await this.prompts.listPrompts(filter);
  }

  /**
   * Get prompt details including all versions
   */
  async getPrompt(promptId) {
    return await this.prompts.getPrompt(promptId);
  }

  /**
   * Update prompt and create new version
   */
  async updatePrompt(promptId, updates) {
    return await this.prompts.updatePrompt(promptId, updates);
  }

  /**
   * Export complete dataset for archival
   */
  async exportAll(promptId) {
    const prompt = await this.prompts.getPrompt(promptId);
    const results = await this.results.exportResults(promptId, 100);
    const comparison = await this.results.getComparison(promptId, 100);

    return {
      prompt,
      results,
      comparison,
      exportedAt: new Date().toISOString(),
    };
  }

  /**
   * Disconnect from ComfyUI
   */
  async disconnect() {
    await this.generator.disconnect();
  }
}

module.exports = GenerationSystem;
