/**
 * ComfyUI Image Generation Script
 * 
 * This script manages communication with a ComfyUI server to:
 * - Submit workflows for image generation
 * - Monitor execution progress in real-time
 * - Retrieve generated images
 * - Handle errors and retries
 */

const fetch = require('node-fetch');
const WebSocket = require('ws');
const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto');

class ComfyUIGenerator {
  constructor(config = {}) {
    this.serverUrl = config.serverUrl || process.env.COMFYUI_SERVER_URL || 'http://localhost:8188';
    this.outputDir = config.outputDir || process.env.COMFYUI_OUTPUT_DIR || './data/results';
    this.backupDir = config.backupDir || process.env.COMFYUI_BACKUP_DIR || './data/backups';
    this.timeout = config.timeout || 600000; // 10 minutes default
    this.maxRetries = config.maxRetries || 3;
    this.retryDelay = config.retryDelay || 1000;
    
    this.ws = null;
    this.isConnected = false;
    this.pendingExecution = new Map(); // Track ongoing executions
    this.executionLog = [];
    
    // Ensure output directory exists
    this.ensureDirectories();
  }

  /**
   * Ensure required directories exist
   */
  async ensureDirectories() {
    try {
      await fs.mkdir(this.outputDir, { recursive: true });
      await fs.mkdir(this.backupDir, { recursive: true });
    } catch (error) {
      console.error('Error creating directories:', error);
    }
  }

  /**
   * Connect to ComfyUI WebSocket
   */
  async connectWebSocket() {
    return new Promise((resolve, reject) => {
      try {
        const wsUrl = this.serverUrl.replace('http', 'ws') + '/ws';
        
        this.ws = new WebSocket(wsUrl);
        
        this.ws.on('open', () => {
          this.isConnected = true;
          console.log('[WebSocket] Connected to ComfyUI');
          resolve();
        });

        this.ws.on('message', (data) => {
          this.handleWebSocketMessage(data);
        });

        this.ws.on('error', (error) => {
          console.error('[WebSocket] Error:', error.message);
          this.isConnected = false;
          reject(error);
        });

        this.ws.on('close', () => {
          this.isConnected = false;
          console.log('[WebSocket] Disconnected from ComfyUI');
        });

        // Set timeout for connection
        setTimeout(() => {
          if (!this.isConnected) {
            reject(new Error('WebSocket connection timeout'));
          }
        }, 5000);

      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * Disconnect WebSocket
   */
  async disconnect() {
    if (this.ws) {
      this.ws.close();
      this.isConnected = false;
    }
  }

  /**
   * Handle incoming WebSocket messages
   */
  handleWebSocketMessage(data) {
    try {
      const message = JSON.parse(data);
      const { type } = message;

      switch (type) {
        case 'execution_start':
          this.handleExecutionStart(message);
          break;
        case 'executing':
          this.handleExecuting(message);
          break;
        case 'progress':
          this.handleProgress(message);
          break;
        case 'executed':
          this.handleExecuted(message);
          break;
        case 'execution_success':
          this.handleExecutionSuccess(message);
          break;
        case 'execution_error':
          this.handleExecutionError(message);
          break;
        case 'execution_cached':
          this.handleExecutionCached(message);
          break;
        case 'execution_interrupted':
          this.handleExecutionInterrupted(message);
          break;
        case 'status':
          this.handleStatus(message);
          break;
        default:
          console.log('[WebSocket] Unknown message type:', type);
      }
    } catch (error) {
      console.error('[WebSocket] Error parsing message:', error);
    }
  }

  handleExecutionStart(message) {
    const { prompt_id } = message;
    console.log(`[${prompt_id}] ✓ Execution started`);
    
    if (this.pendingExecution.has(prompt_id)) {
      const execution = this.pendingExecution.get(prompt_id);
      execution.status = 'running';
      execution.startTime = Date.now();
      if (execution.callbacks.onStart) {
        execution.callbacks.onStart();
      }
    }
  }

  handleExecuting(message) {
    const { prompt_id, node } = message;
    
    if (node === null) {
      console.log(`[${prompt_id}] ✓ All nodes completed`);
    } else {
      console.log(`[${prompt_id}] → Executing node: ${node}`);
      if (this.pendingExecution.has(prompt_id)) {
        const execution = this.pendingExecution.get(prompt_id);
        execution.currentNode = node;
        if (execution.callbacks.onNodeExecute) {
          execution.callbacks.onNodeExecute({ node });
        }
      }
    }
  }

  handleProgress(message) {
    const { prompt_id, node, value, max } = message;
    const percent = Math.round((value / max) * 100);
    console.log(`[${prompt_id}] ⚙ Node ${node}: ${percent}%`);
    
    if (this.pendingExecution.has(prompt_id)) {
      const execution = this.pendingExecution.get(prompt_id);
      if (execution.callbacks.onProgress) {
        execution.callbacks.onProgress({ node, value, max, percent });
      }
    }
  }

  handleExecuted(message) {
    const { prompt_id, node, output } = message;
    console.log(`[${prompt_id}] ✓ Node ${node} output:`, output);
    
    if (this.pendingExecution.has(prompt_id)) {
      const execution = this.pendingExecution.get(prompt_id);
      if (execution.callbacks.onExecuted) {
        execution.callbacks.onExecuted({ node, output });
      }
    }
  }

  handleExecutionSuccess(message) {
    const { prompt_id, timestamp } = message;
    console.log(`[${prompt_id}] ✅ Execution successful (${timestamp})`);
    
    if (this.pendingExecution.has(prompt_id)) {
      const execution = this.pendingExecution.get(prompt_id);
      execution.status = 'completed';
      execution.endTime = Date.now();
    }
  }

  handleExecutionError(message) {
    const { prompt_id } = message;
    console.error(`[${prompt_id}] ❌ Execution error:`, message);
    
    if (this.pendingExecution.has(prompt_id)) {
      const execution = this.pendingExecution.get(prompt_id);
      execution.status = 'error';
      execution.error = message;
    }
  }

  handleExecutionCached(message) {
    const { prompt_id, nodes } = message;
    console.log(`[${prompt_id}] ⚡ Using cached results for nodes:`, nodes);
  }

  handleExecutionInterrupted(message) {
    const { prompt_id } = message;
    console.log(`[${prompt_id}] ⏹ Execution interrupted:`, message);
    
    if (this.pendingExecution.has(prompt_id)) {
      const execution = this.pendingExecution.get(prompt_id);
      execution.status = 'interrupted';
    }
  }

  handleStatus(message) {
    const { exec_info } = message;
    if (exec_info?.queue_remaining) {
      console.log(`[Status] Queue remaining: ${exec_info.queue_remaining}`);
    }
  }

  /**
   * Validate workflow structure
   */
  validateWorkflow(workflow) {
    if (typeof workflow !== 'object') {
      throw new Error('Workflow must be an object');
    }

    for (const [nodeId, node] of Object.entries(workflow)) {
      if (!node.class_type) {
        throw new Error(`Node ${nodeId} missing class_type`);
      }
      
      if (typeof node !== 'object') {
        throw new Error(`Node ${nodeId} is not an object`);
      }

      if (node.inputs && typeof node.inputs !== 'object') {
        throw new Error(`Node ${nodeId} inputs must be an object`);
      }
    }

    return true;
  }

  /**
   * Submit workflow to ComfyUI server
   */
  async submitWorkflow(workflow) {
    this.validateWorkflow(workflow);

    try {
      const response = await fetch(`${this.serverUrl}/prompt`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(workflow),
        timeout: 10000,
      });

      if (!response.ok) {
        const error = await response.text();
        throw new Error(`Server error (${response.status}): ${error}`);
      }

      const result = await response.json();

      if (result.error) {
        const errorMsg = `Workflow validation error: ${JSON.stringify(result.node_errors || result.error)}`;
        throw new Error(errorMsg);
      }

      if (!result.prompt_id) {
        throw new Error('No prompt_id returned from server');
      }

      console.log(`[${result.prompt_id}] Submitted to queue (position: ${result.number})`);
      return result.prompt_id;

    } catch (error) {
      console.error('Error submitting workflow:', error.message);
      throw error;
    }
  }

  /**
   * Get execution history for a prompt
   */
  async getHistory(promptId) {
    try {
      const response = await fetch(`${this.serverUrl}/history/${promptId}`, {
        timeout: 10000,
      });

      if (!response.ok) {
        throw new Error(`Failed to get history: ${response.statusText}`);
      }

      const history = await response.json();
      return history[promptId] || null;

    } catch (error) {
      console.error(`Error getting history for ${promptId}:`, error.message);
      throw error;
    }
  }

  /**
   * Download image from ComfyUI server
   */
  async downloadImage(filename, subfolder = '', type = 'output') {
    try {
      const url = new URL(`${this.serverUrl}/view`);
      url.searchParams.append('filename', filename);
      if (subfolder) url.searchParams.append('subfolder', subfolder);
      url.searchParams.append('type', type);

      const response = await fetch(url.toString(), { timeout: 30000 });

      if (!response.ok) {
        throw new Error(`Failed to download image: ${response.statusText}`);
      }

      const buffer = await response.buffer();
      return buffer;

    } catch (error) {
      console.error(`Error downloading image ${filename}:`, error.message);
      throw error;
    }
  }

  /**
   * Save image to local storage
   */
  async saveImage(imageBuffer, filename, metadata = {}) {
    try {
      const filepath = path.join(this.outputDir, filename);
      await fs.writeFile(filepath, imageBuffer);

      // Save metadata
      const metaFilepath = filepath + '.json';
      await fs.writeFile(metaFilepath, JSON.stringify(metadata, null, 2));

      console.log(`✓ Image saved: ${filepath}`);
      return { filepath, metaFilepath };

    } catch (error) {
      console.error(`Error saving image:`, error.message);
      throw error;
    }
  }

  /**
   * Backup workflow
   */
  async backupWorkflow(workflow, prefix = 'workflow') {
    try {
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const hash = crypto.createHash('sha256').update(JSON.stringify(workflow)).digest('hex').slice(0, 8);
      const filename = `${prefix}_${timestamp}_${hash}.json`;
      const filepath = path.join(this.backupDir, filename);

      await fs.writeFile(filepath, JSON.stringify(workflow, null, 2));
      console.log(`✓ Workflow backed up: ${filepath}`);
      return filepath;

    } catch (error) {
      console.error('Error backing up workflow:', error.message);
      throw error;
    }
  }

  /**
   * Generate images from workflow
   */
  async generateImages(options = {}) {
    const {
      workflow,
      workflowId = '',
      metadata = {},
      callbacks = {},
      backupWorkflow: shouldBackup = true,
      waitForCompletion = true,
    } = options;

    try {
      // Validate workflow
      this.validateWorkflow(workflow);

      // Backup workflow if requested
      if (shouldBackup) {
        await this.backupWorkflow(workflow, workflowId || 'generation');
      }

      // Ensure WebSocket is connected
      if (!this.isConnected) {
        await this.connectWebSocket();
      }

      // Submit workflow
      const promptId = await this.submitWorkflow(workflow);

      // Register execution tracking
      const execution = {
        promptId,
        workflowId,
        status: 'submitted',
        metadata,
        callbacks,
        createdAt: Date.now(),
      };

      this.pendingExecution.set(promptId, execution);

      if (callbacks.onSubmit) {
        callbacks.onSubmit({ promptId });
      }

      // Wait for completion if requested
      if (waitForCompletion) {
        const result = await this.waitForCompletion(promptId);
        
        if (result.status === 'error') {
          throw new Error(`Generation failed: ${JSON.stringify(result.error)}`);
        }

        return result;
      }

      return { promptId, status: 'submitted' };

    } catch (error) {
      console.error('Error generating images:', error.message);
      if (callbacks.onError) {
        callbacks.onError(error);
      }
      throw error;
    }
  }

  /**
   * Wait for execution to complete
   */
  async waitForCompletion(promptId) {
    return new Promise((resolve, reject) => {
      const startTime = Date.now();
      const checkInterval = setInterval(async () => {
        try {
          const execution = this.pendingExecution.get(promptId);
          
          if (!execution) {
            clearInterval(checkInterval);
            reject(new Error('Execution tracking lost'));
            return;
          }

          // Check timeout
          if (Date.now() - startTime > this.timeout) {
            clearInterval(checkInterval);
            execution.status = 'timeout';
            if (execution.callbacks.onError) {
              execution.callbacks.onError(new Error('Generation timeout'));
            }
            reject(new Error('Generation timeout'));
            return;
          }

          // Check if completed
          if (execution.status === 'completed') {
            clearInterval(checkInterval);
            
            try {
              const history = await this.getHistory(promptId);
              const result = this.processHistory(promptId, history, execution);
              
              if (execution.callbacks.onComplete) {
                execution.callbacks.onComplete(result);
              }
              
              resolve(result);
            } catch (error) {
              reject(error);
            }
            return;
          }

          // Check if error
          if (execution.status === 'error') {
            clearInterval(checkInterval);
            if (execution.callbacks.onError) {
              execution.callbacks.onError(execution.error);
            }
            reject(execution.error);
            return;
          }

          // Check if interrupted
          if (execution.status === 'interrupted') {
            clearInterval(checkInterval);
            const error = new Error('Execution interrupted');
            if (execution.callbacks.onError) {
              execution.callbacks.onError(error);
            }
            reject(error);
            return;
          }

        } catch (error) {
          clearInterval(checkInterval);
          reject(error);
        }
      }, 500);
    });
  }

  /**
   * Process history and retrieve images
   */
  async processHistory(promptId, history, execution) {
    const images = [];
    const metadata = execution.metadata;

    try {
      if (history && history.outputs) {
        for (const [nodeId, output] of Object.entries(history.outputs)) {
          if (output.images) {
            for (const imgData of output.images) {
              try {
                const imageBuffer = await this.downloadImage(
                  imgData.filename,
                  imgData.subfolder || '',
                  imgData.type || 'output'
                );

                const { filepath } = await this.saveImage(
                  imageBuffer,
                  imgData.filename,
                  {
                    promptId,
                    workflowId: execution.workflowId,
                    nodeId,
                    timestamp: Date.now(),
                    metadata,
                  }
                );

                images.push({
                  filename: imgData.filename,
                  path: filepath,
                  nodeId,
                  metadata: imgData,
                });
              } catch (error) {
                console.error(`Failed to process image ${imgData.filename}:`, error.message);
              }
            }
          }
        }
      }

      return {
        promptId,
        workflowId: execution.workflowId,
        status: 'completed',
        images,
        metadata: {
          executionTime: execution.endTime - execution.startTime,
          timestamp: execution.createdAt,
          nodeCount: Object.keys(history).length,
        },
      };

    } catch (error) {
      console.error('Error processing history:', error.message);
      throw error;
    }
  }

  /**
   * Get queue status
   */
  async getQueueStatus() {
    try {
      const response = await fetch(`${this.serverUrl}/queue`, {
        timeout: 5000,
      });

      if (!response.ok) {
        throw new Error(`Failed to get queue status: ${response.statusText}`);
      }

      return await response.json();

    } catch (error) {
      console.error('Error getting queue status:', error.message);
      throw error;
    }
  }

  /**
   * Get system stats
   */
  async getSystemStats() {
    try {
      const response = await fetch(`${this.serverUrl}/system_stats`, {
        timeout: 5000,
      });

      if (!response.ok) {
        throw new Error(`Failed to get system stats: ${response.statusText}`);
      }

      return await response.json();

    } catch (error) {
      console.error('Error getting system stats:', error.message);
      throw error;
    }
  }

  /**
   * Interrupt execution
   */
  async interrupt() {
    try {
      const response = await fetch(`${this.serverUrl}/interrupt`, {
        method: 'POST',
        timeout: 5000,
      });

      if (!response.ok) {
        throw new Error(`Failed to interrupt: ${response.statusText}`);
      }

      return await response.json();

    } catch (error) {
      console.error('Error interrupting:', error.message);
      throw error;
    }
  }

  /**
   * Get execution log
   */
  getExecutionLog() {
    return Array.from(this.pendingExecution.values());
  }

  /**
   * Clear completed executions from tracking
   */
  clearCompletedExecutions() {
    let cleared = 0;
    for (const [promptId, execution] of this.pendingExecution.entries()) {
      if (['completed', 'error', 'interrupted', 'timeout'].includes(execution.status)) {
        this.pendingExecution.delete(promptId);
        cleared++;
      }
    }
    return cleared;
  }
}

module.exports = ComfyUIGenerator;
