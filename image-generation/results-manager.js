/**
 * Results Manager
 * 
 * Manages image generation results, galleries, and master images.
 * Tracks all generations with metadata and displays comparisons.
 */

const fs = require('fs').promises;
const path = require('path');
const { readJSON, writeJSON, generateId, formatBytes } = require('./utils');

class ResultsManager {
  constructor(config = {}) {
    this.dataDir = config.dataDir || path.join(__dirname, 'data');
    this.resultsDir = path.join(this.dataDir, 'results');
    this.galleriesDir = path.join(this.resultsDir, 'galleries');
    this.masterImagesDir = path.join(this.resultsDir, 'master-images');
    
    this.ensureDirectories();
  }

  /**
   * Ensure all required directories exist
   */
  async ensureDirectories() {
    try {
      await fs.mkdir(this.resultsDir, { recursive: true });
      await fs.mkdir(this.galleriesDir, { recursive: true });
      await fs.mkdir(this.masterImagesDir, { recursive: true });
    } catch (error) {
      console.error('Error creating directories:', error);
    }
  }

  /**
   * Save a generation result
   */
  async saveResult(options = {}) {
    const {
      promptId,
      workflowId,
      promptId: generationId = generateId('result'),
      images = [], // Array of { filename, path, bytes }
      executionTime = 0,
      nodeCount = 0,
      metadata = {},
    } = options;

    if (!promptId) throw new Error('Prompt ID is required');
    if (images.length === 0) throw new Error('At least one image is required');

    const timestamp = new Date().toISOString();
    const resultId = generationId;

    const resultData = {
      id: resultId,
      promptId,
      workflowId,
      images: images.map(img => ({
        filename: img.filename,
        path: img.path,
        size: img.bytes ? formatBytes(img.bytes) : 'unknown',
        bytes: img.bytes || 0,
      })),
      executionTime,
      nodeCount,
      metadata: {
        ...metadata,
        generatedAt: timestamp,
      },
      status: 'completed',
      isMaster: false,
    };

    // Save result metadata
    const filepath = path.join(this.resultsDir, `${resultId}.json`);
    await writeJSON(filepath, resultData);

    console.log(`✅ Saved result: ${resultId} with ${images.length} image(s)`);
    return resultData;
  }

  /**
   * Get a result
   */
  async getResult(resultId) {
    const filepath = path.join(this.resultsDir, `${resultId}.json`);
    return await readJSON(filepath);
  }

  /**
   * List all results for a prompt
   */
  async listResults(promptId, options = {}) {
    try {
      const files = await fs.readdir(this.resultsDir);
      const results = [];

      for (const file of files) {
        if (!file.endsWith('.json')) continue;
        
        const resultId = file.replace('.json', '');
        const result = await this.getResult(resultId);

        if (result.promptId !== promptId) continue;

        results.push(result);
      }

      // Sort by newest first
      results.sort((a, b) => new Date(b.metadata.generatedAt) - new Date(a.metadata.generatedAt));

      // Limit results if requested
      if (options.limit) {
        results.splice(options.limit);
      }

      return results;
    } catch (error) {
      console.error('Error listing results:', error);
      return [];
    }
  }

  /**
   * Create a gallery for a prompt
   */
  async createGallery(promptId, options = {}) {
    const {
      name = '',
      description = '',
      includeAllResults = true,
      maxResults = 50,
    } = options;

    const galleryId = generateId('gallery');
    const timestamp = new Date().toISOString();

    // Get results for this prompt
    const results = await this.listResults(promptId, { limit: includeAllResults ? maxResults : 1 });

    const galleryData = {
      id: galleryId,
      promptId,
      name: name || `Gallery for ${promptId}`,
      description,
      results: results.map(r => ({
        id: r.id,
        timestamp: r.metadata.generatedAt,
        executionTime: r.executionTime,
        images: r.images,
        isMaster: r.isMaster,
      })),
      createdAt: timestamp,
      updatedAt: timestamp,
      totalImages: results.reduce((sum, r) => sum + r.images.length, 0),
    };

    const filepath = path.join(this.galleriesDir, `${galleryId}.json`);
    await writeJSON(filepath, galleryData);

    console.log(`✅ Created gallery: ${galleryData.name} with ${galleryData.results.length} results`);
    return galleryData;
  }

  /**
   * Get a gallery
   */
  async getGallery(galleryId) {
    const filepath = path.join(this.galleriesDir, `${galleryId}.json`);
    return await readJSON(filepath);
  }

  /**
   * Set a master image for a prompt
   */
  async setMasterImage(promptId, resultId, imageIndex = 0) {
    // Get the result
    const result = await this.getResult(resultId);

    if (!result.images[imageIndex]) {
      throw new Error(`Image index ${imageIndex} not found in result`);
    }

    const masterImage = {
      id: generateId('master'),
      promptId,
      resultId,
      imageIndex,
      image: result.images[imageIndex],
      metadata: {
        ...result.metadata,
        selectedAsmaster: new Date().toISOString(),
      },
    };

    // Write master image reference
    const filepath = path.join(this.masterImagesDir, `${promptId}_master.json`);
    await writeJSON(filepath, masterImage);

    // Update result to mark as master
    result.isMaster = true;
    const resultPath = path.join(this.resultsDir, `${resultId}.json`);
    await writeJSON(resultPath, result);

    console.log(`✅ Set master image for prompt ${promptId}`);
    return masterImage;
  }

  /**
   * Get master image for a prompt
   */
  async getMasterImage(promptId) {
    const filepath = path.join(this.masterImagesDir, `${promptId}_master.json`);
    try {
      return await readJSON(filepath);
    } catch (error) {
      return null; // No master image set yet
    }
  }

  /**
   * Get comparison data for a prompt
   */
  async getComparison(promptId, limit = 10) {
    // Get all results
    const results = await this.listResults(promptId, { limit });

    // Get master image
    const masterImage = await this.getMasterImage(promptId);

    return {
      promptId,
      masterImage,
      results: results.map(r => ({
        id: r.id,
        timestamp: r.metadata.generatedAt,
        executionTime: r.executionTime,
        images: r.images,
        isMaster: r.id === masterImage?.resultId,
      })),
      totalResults: results.length,
    };
  }

  /**
   * Generate gallery HTML for viewing
   */
  async generateGalleryHTML(promptId, options = {}) {
    const comparison = await this.getComparison(promptId, options.limit || 20);
    const masterImage = comparison.masterImage;

    let html = `
<!DOCTYPE html>
<html>
<head>
  <title>Gallery - ${promptId}</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f5f5f5; }
    .container { max-width: 1400px; margin: 0 auto; padding: 20px; }
    .header { background: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
    .master-section { background: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
    .master-image { text-align: center; margin: 20px 0; }
    .master-image img { max-width: 100%; height: auto; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
    .gallery { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; }
    .gallery-item { background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1); transition: transform 0.2s; }
    .gallery-item:hover { transform: translateY(-4px); box-shadow: 0 4px 16px rgba(0,0,0,0.15); }
    .gallery-item img { width: 100%; height: 300px; object-fit: cover; }
    .gallery-item-info { padding: 12px; font-size: 12px; color: #666; }
    .master-badge { display: inline-block; background: #ffd700; color: #333; padding: 4px 8px; border-radius: 4px; font-weight: bold; margin-bottom: 8px; }
    h1 { color: #333; margin-bottom: 10px; }
    .stat { display: inline-block; margin-right: 20px; color: #666; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>Generation Gallery</h1>
      <p>Prompt ID: <code>${promptId}</code></p>
      <div>
        <span class="stat">Total Results: ${comparison.totalResults}</span>
        <span class="stat">Total Images: ${comparison.results.reduce((sum, r) => sum + r.images.length, 0)}</span>
      </div>
    </div>
`;

    // Master image section
    if (masterImage) {
      html += `
    <div class="master-section">
      <h2>⭐ Master Image</h2>
      <div class="master-image">
        <div class="master-badge">SELECTED AS MASTER</div>
        <img src="${masterImage.image.path}" alt="Master Image" />
        <div class="gallery-item-info">
          <p>Execution Time: ${masterImage.metadata.generatedAt}</p>
          <p>Size: ${masterImage.image.size}</p>
        </div>
      </div>
    </div>
`;
    }

    // Gallery items
    html += '<div class="gallery">';
    for (const result of comparison.results) {
      for (const image of result.images) {
        const isMaster = result.isMaster ? ' MASTER' : '';
        html += `
    <div class="gallery-item">
      <img src="${image.path}" alt="Generated Image" />
      <div class="gallery-item-info">
        ${isMaster ? '<div class="master-badge">MASTER</div>' : ''}
        <p><strong>Time:</strong> ${result.executionTime}ms</p>
        <p><strong>Size:</strong> ${image.size}</p>
        <p><small>${new Date(result.timestamp).toLocaleString()}</small></p>
      </div>
    </div>
`;
      }
    }
    html += '</div></div></body></html>';

    return html;
  }

  /**
   * Export results as JSON
   */
  async exportResults(promptId, limit = 50) {
    const results = await this.listResults(promptId, { limit });
    const masterImage = await this.getMasterImage(promptId);

    return {
      promptId,
      masterImage,
      results,
      exportedAt: new Date().toISOString(),
    };
  }
}

module.exports = ResultsManager;
