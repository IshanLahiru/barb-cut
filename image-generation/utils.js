/**
 * Utility Functions for ComfyUI Integration
 */

const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto');

/**
 * Generate unique ID
 */
function generateId(prefix = 'gen') {
  const timestamp = Date.now().toString(36);
  const random = Math.random().toString(36).substring(2, 8);
  return `${prefix}_${timestamp}_${random}`;
}

/**
 * Generate hash of object
 */
function hashObject(obj) {
  return crypto
    .createHash('sha256')
    .update(JSON.stringify(obj))
    .digest('hex');
}

/**
 * Deep clone object
 */
function deepClone(obj) {
  return JSON.parse(JSON.stringify(obj));
}

/**
 * Merge objects recursively
 */
function deepMerge(target, source) {
  const output = deepClone(target);
  
  if (isObject(source)) {
    Object.keys(source).forEach((key) => {
      if (isObject(source[key])) {
        if (!(key in output)) {
          output[key] = source[key];
        } else {
          output[key] = deepMerge(output[key], source[key]);
        }
      } else {
        output[key] = source[key];
      }
    });
  }

  return output;
}

/**
 * Check if value is an object
 */
function isObject(obj) {
  return obj && typeof obj === 'object' && !Array.isArray(obj);
}

/**
 * Format bytes to human readable
 */
function formatBytes(bytes) {
  if (bytes === 0) return '0 Bytes';
  
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  
  return Math.round((bytes / Math.pow(k, i)) * 100) / 100 + ' ' + sizes[i];
}

/**
 * Format duration to human readable
 */
function formatDuration(ms) {
  const seconds = Math.floor((ms / 1000) % 60);
  const minutes = Math.floor((ms / (1000 * 60)) % 60);
  const hours = Math.floor((ms / (1000 * 60 * 60)) % 24);

  const parts = [];
  if (hours > 0) parts.push(`${hours}h`);
  if (minutes > 0) parts.push(`${minutes}m`);
  if (seconds > 0 || parts.length === 0) parts.push(`${seconds}s`);

  return parts.join(' ');
}

/**
 * Get file info
 */
async function getFileInfo(filepath) {
  try {
    const stat = await fs.stat(filepath);
    const ext = path.extname(filepath);
    const name = path.basename(filepath, ext);

    return {
      path: filepath,
      name,
      ext,
      size: stat.size,
      sizeFormatted: formatBytes(stat.size),
      created: stat.birthtimeMs,
      modified: stat.mtimeMs,
    };
  } catch (error) {
    throw new Error(`Failed to get file info for ${filepath}: ${error.message}`);
  }
}

/**
 * List directory contents
 */
async function listDirectory(dir, filter = null) {
  try {
    const files = await fs.readdir(dir);
    const contents = [];

    for (const file of files) {
      if (filter && !filter(file)) continue;

      const filepath = path.join(dir, file);
      const info = await getFileInfo(filepath);
      contents.push(info);
    }

    return contents.sort((a, b) => b.modified - a.modified);
  } catch (error) {
    throw new Error(`Failed to list directory ${dir}: ${error.message}`);
  }
}

/**
 * Read JSON file
 */
async function readJSON(filepath) {
  try {
    const content = await fs.readFile(filepath, 'utf-8');
    return JSON.parse(content);
  } catch (error) {
    throw new Error(`Failed to read JSON from ${filepath}: ${error.message}`);
  }
}

/**
 * Write JSON file
 */
async function writeJSON(filepath, data, pretty = true) {
  try {
    const content = pretty ? JSON.stringify(data, null, 2) : JSON.stringify(data);
    await fs.writeFile(filepath, content, 'utf-8');
  } catch (error) {
    throw new Error(`Failed to write JSON to ${filepath}: ${error.message}`);
  }
}

/**
 * Delete file safely
 */
async function deleteFile(filepath) {
  try {
    await fs.unlink(filepath);
    return true;
  } catch (error) {
    if (error.code === 'ENOENT') {
      return false; // File doesn't exist
    }
    throw error;
  }
}

/**
 * Delete directory recursively
 */
async function deleteDirectory(dir) {
  try {
    const files = await fs.readdir(dir);
    
    for (const file of files) {
      const filepath = path.join(dir, file);
      const stat = await fs.stat(filepath);
      
      if (stat.isDirectory()) {
        await deleteDirectory(filepath);
      } else {
        await fs.unlink(filepath);
      }
    }
    
    await fs.rmdir(dir);
  } catch (error) {
    throw new Error(`Failed to delete directory ${dir}: ${error.message}`);
  }
}

/**
 * Copy file
 */
async function copyFile(source, destination) {
  try {
    await fs.copyFile(source, destination);
  } catch (error) {
    throw new Error(`Failed to copy ${source} to ${destination}: ${error.message}`);
  }
}

/**
 * Sleep for specified milliseconds
 */
function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/**
 * Retry function with exponential backoff
 */
async function retry(fn, options = {}) {
  const {
    maxRetries = 3,
    initialDelay = 1000,
    maxDelay = 30000,
    backoffMultiplier = 2,
  } = options;

  let lastError;
  let delay = initialDelay;

  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;
      
      if (attempt < maxRetries - 1) {
        console.log(`Retry attempt ${attempt + 1} after ${delay}ms...`);
        await sleep(delay);
        delay = Math.min(delay * backoffMultiplier, maxDelay);
      }
    }
  }

  throw new Error(`Failed after ${maxRetries} retries: ${lastError.message}`);
}

/**
 * Validate object schema
 */
function validateSchema(obj, schema) {
  const errors = [];

  for (const [key, rules] of Object.entries(schema)) {
    const value = obj[key];

    if (rules.required && value === undefined) {
      errors.push(`Missing required field: ${key}`);
      continue;
    }

    if (value !== undefined) {
      if (rules.type && typeof value !== rules.type) {
        errors.push(`Field ${key} should be ${rules.type}, got ${typeof value}`);
      }

      if (rules.enum && !rules.enum.includes(value)) {
        errors.push(`Field ${key} should be one of ${rules.enum.join(', ')}, got ${value}`);
      }

      if (rules.min !== undefined && value < rules.min) {
        errors.push(`Field ${key} should be >= ${rules.min}, got ${value}`);
      }

      if (rules.max !== undefined && value > rules.max) {
        errors.push(`Field ${key} should be <= ${rules.max}, got ${value}`);
      }

      if (rules.pattern && !rules.pattern.test(value)) {
        errors.push(`Field ${key} does not match pattern ${rules.pattern}`);
      }
    }
  }

  return {
    valid: errors.length === 0,
    errors,
  };
}

/**
 * Parse workflow to extract metadata
 */
function parseWorkflow(workflow) {
  const nodes = Object.keys(workflow).length;
  const nodeTypes = new Set();
  const connections = [];

  for (const [nodeId, node] of Object.entries(workflow)) {
    nodeTypes.add(node.class_type);

    if (node.inputs) {
      for (const [key, value] of Object.entries(node.inputs)) {
        if (Array.isArray(value) && value.length === 2) {
          connections.push({
            from: value[0],
            fromOutput: value[1],
            to: nodeId,
            toInput: key,
          });
        }
      }
    }
  }

  return {
    nodeCount: nodes,
    nodeTypes: Array.from(nodeTypes),
    connections,
    depth: calculateWorkflowDepth(workflow, connections),
  };
}

/**
 * Calculate workflow depth (longest path from input to output)
 */
function calculateWorkflowDepth(workflow, connections) {
  const graph = new Map();
  
  // Build adjacency list
  for (const conn of connections) {
    if (!graph.has(conn.from)) {
      graph.set(conn.from, []);
    }
    graph.get(conn.from).push(conn.to);
  }

  // Find all sink nodes (nodes with no outgoing connections)
  const sinkNodes = Object.keys(workflow).filter(
    (nodeId) => !graph.has(nodeId) || graph.get(nodeId).length === 0
  );

  // Calculate depth for each node using DFS
  const depths = new Map();

  function dfs(nodeId) {
    if (depths.has(nodeId)) {
      return depths.get(nodeId);
    }

    const incoming = connections.filter((conn) => conn.to === nodeId);

    if (incoming.length === 0) {
      depths.set(nodeId, 1);
      return 1;
    }

    const maxDepth = Math.max(...incoming.map((conn) => dfs(conn.from)));
    const depth = maxDepth + 1;
    depths.set(nodeId, depth);
    return depth;
  }

  // Find max depth
  let maxDepth = 0;
  for (const nodeId of Object.keys(workflow)) {
    maxDepth = Math.max(maxDepth, dfs(nodeId));
  }

  return maxDepth;
}

module.exports = {
  generateId,
  hashObject,
  deepClone,
  deepMerge,
  isObject,
  formatBytes,
  formatDuration,
  getFileInfo,
  listDirectory,
  readJSON,
  writeJSON,
  deleteFile,
  deleteDirectory,
  copyFile,
  sleep,
  retry,
  validateSchema,
  parseWorkflow,
  calculateWorkflowDepth,
};
