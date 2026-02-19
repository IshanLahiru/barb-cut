/**
 * Prompt Manager
 * 
 * Manages prompts, instructions, and variations for image generation.
 * Stores everything in JSON for easy tracking and modification.
 */

const fs = require('fs').promises;
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const { readJSON, writeJSON, generateId } = require('./utils');

class PromptManager {
  constructor(config = {}) {
    this.dataDir = config.dataDir || path.join(__dirname, 'data');
    this.promptsDir = path.join(this.dataDir, 'prompts');
    this.templatesDir = path.join(this.dataDir, 'prompt-templates');
    this.resultsDir = path.join(this.dataDir, 'results');
    
    this.ensureDirectories();
  }

  /**
   * Ensure all required directories exist
   */
  async ensureDirectories() {
    try {
      await fs.mkdir(this.promptsDir, { recursive: true });
      await fs.mkdir(this.templatesDir, { recursive: true });
      await fs.mkdir(this.resultsDir, { recursive: true });
    } catch (error) {
      console.error('Error creating directories:', error);
    }
  }

  /**
   * Create a new prompt with instructions
   */
  async createPrompt(options = {}) {
    const {
      name,
      description = '',
      mainPrompt, // The main text-to-image prompt
      negativePrompt = 'blurry, low quality, distorted',
      instructions = {}, // Additional instructions for nodes
      style = 'portrait',
      category = 'haircut',
      tags = [],
    } = options;

    if (!name) throw new Error('Prompt name is required');
    if (!mainPrompt) throw new Error('Main prompt is required');

    const promptId = generateId('prompt');
    const timestamp = new Date().toISOString();

    const promptData = {
      id: promptId,
      name,
      description,
      mainPrompt,
      negativePrompt,
      instructions,
      style,
      category,
      tags,
      createdAt: timestamp,
      updatedAt: timestamp,
      versions: [
        {
          version: 1,
          mainPrompt,
          negativePrompt,
          instructions,
          createdAt: timestamp,
        },
      ],
    };

    const filepath = path.join(this.promptsDir, `${promptId}.json`);
    await writeJSON(filepath, promptData);

    console.log(`✅ Created prompt: ${name} (ID: ${promptId})`);
    return promptData;
  }

  /**
   * Update an existing prompt (creates new version)
   */
  async updatePrompt(promptId, updates = {}) {
    const filepath = path.join(this.promptsDir, `${promptId}.json`);
    const promptData = await readJSON(filepath);

    const timestamp = new Date().toISOString();

    // Update main fields
    if (updates.name) promptData.name = updates.name;
    if (updates.description !== undefined) promptData.description = updates.description;
    if (updates.style) promptData.style = updates.style;
    if (updates.tags) promptData.tags = updates.tags;

    // Check if prompt content changed
    const hasPromptChanges = 
      updates.mainPrompt || 
      updates.negativePrompt || 
      updates.instructions;

    if (hasPromptChanges) {
      // Create new version
      const newVersion = {
        version: (promptData.versions[promptData.versions.length - 1]?.version || 0) + 1,
        mainPrompt: updates.mainPrompt || promptData.mainPrompt,
        negativePrompt: updates.negativePrompt || promptData.negativePrompt,
        instructions: { 
          ...promptData.versions[promptData.versions.length - 1]?.instructions,
          ...updates.instructions 
        },
        createdAt: timestamp,
      };

      promptData.versions.push(newVersion);
      promptData.mainPrompt = newVersion.mainPrompt;
      promptData.negativePrompt = newVersion.negativePrompt;
      promptData.instructions = newVersion.instructions;
    }

    promptData.updatedAt = timestamp;
    await writeJSON(filepath, promptData);

    console.log(`✅ Updated prompt: ${promptData.name}`);
    return promptData;
  }

  /**
   * Get a prompt by ID
   */
  async getPrompt(promptId) {
    const filepath = path.join(this.promptsDir, `${promptId}.json`);
    return await readJSON(filepath);
  }

  /**
   * List all prompts
   */
  async listPrompts(filter = {}) {
    try {
      const files = await fs.readdir(this.promptsDir);
      const prompts = [];

      for (const file of files) {
        if (!file.endsWith('.json')) continue;
        
        const promptId = file.replace('.json', '');
        const prompt = await this.getPrompt(promptId);

        if (filter.category && prompt.category !== filter.category) continue;
        if (filter.style && prompt.style !== filter.style) continue;
        if (filter.tags && !filter.tags.some(tag => prompt.tags.includes(tag))) continue;

        prompts.push(prompt);
      }

      return prompts.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    } catch (error) {
      console.error('Error listing prompts:', error);
      return [];
    }
  }

  /**
   * Get prompt versions
   */
  async getPromptVersions(promptId) {
    const prompt = await this.getPrompt(promptId);
    return prompt.versions || [];
  }

  /**
   * Get specific version of a prompt
   */
  async getPromptVersion(promptId, version) {
    const prompt = await this.getPrompt(promptId);
    const versionData = prompt.versions.find(v => v.version === version);
    
    if (!versionData) {
      throw new Error(`Version ${version} not found for prompt ${promptId}`);
    }

    return versionData;
  }

  /**
   * Create a prompt template for reuse
   */
  async createTemplate(options = {}) {
    const {
      name,
      description = '',
      basePrompt,
      placeholders = {}, // e.g. { {{HAIRSTYLE}}: 'description of placeholder' }
      defaultInstructions = {},
      category = 'portrait',
    } = options;

    if (!name) throw new Error('Template name is required');
    if (!basePrompt) throw new Error('Base prompt is required');

    const templateId = generateId('template');
    const timestamp = new Date().toISOString();

    const templateData = {
      id: templateId,
      name,
      description,
      basePrompt,
      placeholders,
      defaultInstructions,
      category,
      createdAt: timestamp,
      examples: [],
    };

    const filepath = path.join(this.templatesDir, `${templateId}.json`);
    await writeJSON(filepath, templateData);

    console.log(`✅ Created template: ${name} (ID: ${templateId})`);
    return templateData;
  }

  /**
   * Generate prompt from template by filling placeholders
   */
  async generateFromTemplate(templateId, placeholderValues = {}) {
    const filepath = path.join(this.templatesDir, `${templateId}.json`);
    const template = await readJSON(filepath);

    let prompt = template.basePrompt;

    // Replace placeholders
    for (const [placeholder, value] of Object.entries(placeholderValues)) {
      const pattern = new RegExp(`{{${placeholder}}}`, 'g');
      prompt = prompt.replace(pattern, value);
    }

    return {
      prompt,
      instructions: template.defaultInstructions,
      templateId,
      values: placeholderValues,
    };
  }

  /**
   * Delete a prompt
   */
  async deletePrompt(promptId) {
    const filepath = path.join(this.promptsDir, `${promptId}.json`);
    const prompt = await readJSON(filepath);
    
    try {
      await fs.unlink(filepath);
      console.log(`✅ Deleted prompt: ${prompt.name}`);
      return true;
    } catch (error) {
      console.error('Error deleting prompt:', error);
      return false;
    }
  }

  /**
   * Export prompt to JSON
   */
  async exportPrompt(promptId) {
    return await this.getPrompt(promptId);
  }

  /**
   * Import prompt from JSON
   */
  async importPrompt(promptData) {
    if (!promptData.id || !promptData.name) {
      throw new Error('Invalid prompt data: missing id or name');
    }

    const filepath = path.join(this.promptsDir, `${promptData.id}.json`);
    await writeJSON(filepath, promptData);

    console.log(`✅ Imported prompt: ${promptData.name}`);
    return promptData;
  }
}

module.exports = PromptManager;
