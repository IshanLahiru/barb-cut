/**
 * Workflow Manager
 * 
 * Manages ComfyUI workflow templates and variations.
 * Creates workflows from prompts and manages workflow parameters.
 */

const fs = require('fs').promises;
const path = require('path');
const { readJSON, writeJSON, generateId } = require('./utils');

class WorkflowManager {
  constructor(config = {}) {
    this.dataDir = config.dataDir || path.join(__dirname, 'data');
    this.workflowsDir = path.join(this.dataDir, 'workflows');
    this.templatesDir = path.join(this.workflowsDir, 'templates');
    this.generatedDir = path.join(this.workflowsDir, 'generated');
    
    this.ensureDirectories();
  }

  /**
   * Ensure all required directories exist
   */
  async ensureDirectories() {
    try {
      await fs.mkdir(this.templatesDir, { recursive: true });
      await fs.mkdir(this.generatedDir, { recursive: true });
    } catch (error) {
      console.error('Error creating directories:', error);
    }
  }

  /**
   * Create a workflow template
   */
  async createTemplate(options = {}) {
    const {
      name,
      description = '',
      baseWorkflow, // Base ComfyUI workflow JSON
      parameterSchema = {}, // Define which parameters can be customized
      category = 'portrait',
    } = options;

    if (!name) throw new Error('Template name is required');
    if (!baseWorkflow) throw new Error('Base workflow is required');

    const templateId = generateId('wf_template');
    const timestamp = new Date().toISOString();

    const templateData = {
      id: templateId,
      name,
      description,
      baseWorkflow,
      parameterSchema, // e.g. { seed: {type: 'number'}, steps: {type: 'number', min: 1, max: 100} }
      category,
      createdAt: timestamp,
      version: 1,
    };

    const filepath = path.join(this.templatesDir, `${templateId}.json`);
    await writeJSON(filepath, templateData);

    console.log(`✅ Created workflow template: ${name} (ID: ${templateId})`);
    return templateData;
  }

  /**
   * Generate workflow from template with custom parameters
   */
  async generateWorkflow(templateId, parameters = {}, promptData = {}) {
    const templatePath = path.join(this.templatesDir, `${templateId}.json`);
    const template = await readJSON(templatePath);

    // Deep clone the base workflow
    const workflow = JSON.parse(JSON.stringify(template.baseWorkflow));

    // Apply parameters to the workflow
    // This varies based on your ComfyUI setup
    // Here's a generic approach that maps parameters to node inputs
    for (const [paramName, paramValue] of Object.entries(parameters)) {
      this.applyParameterToWorkflow(workflow, paramName, paramValue);
    }

    // Apply prompt to text encode nodes
    if (promptData.mainPrompt) {
      this.applyPromptToWorkflow(workflow, promptData.mainPrompt, promptData.negativePrompt);
    }

    // Apply custom instructions
    if (promptData.instructions) {
      this.applyInstructionsToWorkflow(workflow, promptData.instructions);
    }

    // Create workflow record
    const generatedId = generateId('workflow');
    const timestamp = new Date().toISOString();

    const workflowRecord = {
      id: generatedId,
      templateId,
      promptId: promptData.id,
      workflow,
      parameters,
      promptData,
      createdAt: timestamp,
      status: 'created',
    };

    // Save generated workflow
    const filepath = path.join(this.generatedDir, `${generatedId}.json`);
    await writeJSON(filepath, workflowRecord);

    console.log(`✅ Generated workflow: ${generatedId}`);
    return workflowRecord;
  }

  /**
   * Apply parameter to workflow
   */
  applyParameterToWorkflow(workflow, paramName, paramValue) {
    // Map parameter names to node IDs and input keys
    const paramMappings = {
      'seed': { nodeId: '4', inputKey: 'seed' },
      'steps': { nodeId: '4', inputKey: 'steps' },
      'cfg': { nodeId: '4', inputKey: 'cfg' },
      'sampler': { nodeId: '4', inputKey: 'sampler_name' },
      'denoise': { nodeId: '4', inputKey: 'denoise' },
      'width': { nodeId: '5', inputKey: 'width' },
      'height': { nodeId: '5', inputKey: 'height' },
    };

    if (paramMappings[paramName]) {
      const { nodeId, inputKey } = paramMappings[paramName];
      if (workflow[nodeId] && workflow[nodeId].inputs) {
        workflow[nodeId].inputs[inputKey] = paramValue;
      }
    }
  }

  /**
   * Apply prompt to text encode nodes
   */
  applyPromptToWorkflow(workflow, mainPrompt, negativePrompt = '') {
    // Find CLIP text encode nodes
    // Node 2 is typically positive prompt, Node 3 is negative
    if (workflow['2'] && workflow['2'].inputs) {
      workflow['2'].inputs.text = mainPrompt;
    }
    if (workflow['3'] && workflow['3'].inputs && negativePrompt) {
      workflow['3'].inputs.text = negativePrompt;
    }
  }

  /**
   * Apply custom instructions to workflow
   */
  applyInstructionsToWorkflow(workflow, instructions) {
    // Apply instruction overrides to specific nodes
    for (const [nodeId, nodeInstructions] of Object.entries(instructions)) {
      if (workflow[nodeId]) {
        Object.assign(workflow[nodeId].inputs, nodeInstructions);
      }
    }
  }

  /**
   * Get a generated workflow
   */
  async getWorkflow(workflowId) {
    const filepath = path.join(this.generatedDir, `${workflowId}.json`);
    return await readJSON(filepath);
  }

  /**
   * Get a template
   */
  async getTemplate(templateId) {
    const filepath = path.join(this.templatesDir, `${templateId}.json`);
    return await readJSON(filepath);
  }

  /**
   * List all templates
   */
  async listTemplates(filter = {}) {
    try {
      const files = await fs.readdir(this.templatesDir);
      const templates = [];

      for (const file of files) {
        if (!file.endsWith('.json')) continue;
        
        const templateId = file.replace('.json', '');
        const template = await this.getTemplate(templateId);

        if (filter.category && template.category !== filter.category) continue;

        templates.push(template);
      }

      return templates;
    } catch (error) {
      console.error('Error listing templates:', error);
      return [];
    }
  }

  /**
   * List all generated workflows
   */
  async listWorkflows(filter = {}) {
    try {
      const files = await fs.readdir(this.generatedDir);
      const workflows = [];

      for (const file of files) {
        if (!file.endsWith('.json')) continue;
        
        const workflowId = file.replace('.json', '');
        const workflow = await this.getWorkflow(workflowId);

        if (filter.promptId && workflow.promptId !== filter.promptId) continue;
        if (filter.templateId && workflow.templateId !== filter.templateId) continue;
        if (filter.status && workflow.status !== filter.status) continue;

        workflows.push(workflow);
      }

      return workflows.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    } catch (error) {
      console.error('Error listing workflows:', error);
      return [];
    }
  }

  /**
   * Update workflow status
   */
  async updateWorkflowStatus(workflowId, status, metadata = {}) {
    const workflow = await this.getWorkflow(workflowId);
    workflow.status = status;
    workflow.statusMeta = metadata;
    workflow.updatedAt = new Date().toISOString();

    const filepath = path.join(this.generatedDir, `${workflowId}.json`);
    await writeJSON(filepath, workflow);

    return workflow;
  }

  /**
   * Get base portrait workflow (default template)
   */
  getDefaultPortraitWorkflow() {
    return {
      "1": {
        "class_type": "CheckpointLoader",
        "inputs": {
          "ckpt_name": "model.safetensors"
        }
      },
      "2": {
        "class_type": "CLIPTextEncode",
        "inputs": {
          "text": "professional portrait", // Will be overridden by prompt
          "clip": ["1", 1]
        }
      },
      "3": {
        "class_type": "CLIPTextEncode",
        "inputs": {
          "text": "blurry, low quality",
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
  }
}

module.exports = WorkflowManager;
