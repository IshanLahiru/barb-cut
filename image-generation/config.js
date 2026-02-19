/**
 * Configuration Management for ComfyUI Integration
 */

require('dotenv').config();

const config = {
  // Server Configuration
  server: {
    url: process.env.COMFYUI_SERVER_URL || 'http://localhost:8188',
    timeout: parseInt(process.env.COMFYUI_TIMEOUT || '600000', 10), // 10 minutes
    maxRetries: parseInt(process.env.COMFYUI_MAX_RETRIES || '3', 10),
    retryDelay: parseInt(process.env.COMFYUI_RETRY_DELAY || '1000', 10),
  },

  // Storage Configuration
  storage: {
    outputDir: process.env.COMFYUI_OUTPUT_DIR || './data/results',
    backupDir: process.env.COMFYUI_BACKUP_DIR || './data/backups',
    workflowDir: process.env.COMFYUI_WORKFLOW_DIR || './data/workflows',
    cacheDir: process.env.COMFYUI_CACHE_DIR || './data/cache',
  },

  // Logging Configuration
  logging: {
    level: process.env.COMFYUI_LOG_LEVEL || 'info', // debug, info, warn, error
    file: process.env.COMFYUI_LOG_FILE || './logs/comfyui.log',
    enableConsole: process.env.COMFYUI_LOG_CONSOLE !== 'false',
  },

  // Feature Flags
  features: {
    backupWorkflows: process.env.COMFYUI_BACKUP_WORKFLOWS !== 'false',
    cacheGenerations: process.env.COMFYUI_CACHE_GENERATIONS === 'true',
    validateWorkflows: process.env.COMFYUI_VALIDATE_WORKFLOWS !== 'false',
    trackMetadata: process.env.COMFYUI_TRACK_METADATA !== 'false',
  },

  // Model Configuration
  models: {
    defaultCheckpoint: process.env.COMFYUI_DEFAULT_CHECKPOINT || 'model.safetensors',
    preloadModels: (process.env.COMFYUI_PRELOAD_MODELS || '').split(',').filter(Boolean),
  },

  // Quality Settings
  quality: {
    defaultSteps: parseInt(process.env.COMFYUI_DEFAULT_STEPS || '20', 10),
    defaultCfg: parseFloat(process.env.COMFYUI_DEFAULT_CFG || '7.0'),
    defaultSampler: process.env.COMFYUI_DEFAULT_SAMPLER || 'euler',
    maxDimension: parseInt(process.env.COMFYUI_MAX_DIMENSION || '2048', 10),
  },

  // Performance Configuration
  performance: {
    enableOptimization: process.env.COMFYUI_ENABLE_OPTIMIZATION === 'true',
    batchSize: parseInt(process.env.COMFYUI_BATCH_SIZE || '1', 10),
    priorityQueueing: process.env.COMFYUI_PRIORITY_QUEUING === 'true',
  },

  // Analysis Settings  
  analysis: {
    enableAnalysis: process.env.COMFYUI_ENABLE_ANALYSIS === 'true',
    analysisDir: process.env.COMFYUI_ANALYSIS_DIR || './analysis/results',
    trackMetrics: process.env.COMFYUI_TRACK_METRICS !== 'false',
  },

  // Barb Cut Specific
  barbCut: {
    userDatasDir: process.env.BARB_CUT_USER_DATA || '../../apps/barbcut/assets/data',
    saveGeneratedImages: process.env.BARB_CUT_SAVE_IMAGES === 'true',
    syncToFirebase: process.env.BARB_CUT_SYNC_FIREBASE === 'true',
  },

  /**
   * Validate configuration
   */
  validate() {
    const errors = [];

    // Validate server URL
    try {
      new URL(this.server.url);
    } catch {
      errors.push(`Invalid COMFYUI_SERVER_URL: ${this.server.url}`);
    }

    // Validate numeric values
    if (this.server.timeout <= 0) {
      errors.push('COMFYUI_TIMEOUT must be greater than 0');
    }

    if (errors.length > 0) {
      throw new Error(`Configuration errors:\n${errors.join('\n')}`);
    }

    return true;
  },

  /**
   * Get configuration summary
   */
  summary() {
    return {
      server: this.server.url,
      outputDir: this.storage.outputDir,
      backupDir: this.storage.backupDir,
      logLevel: this.logging.level,
      backupEnabled: this.features.backupWorkflows,
      cacheEnabled: this.features.cacheGenerations,
    };
  },
};

// Validate on import
config.validate();

module.exports = config;
