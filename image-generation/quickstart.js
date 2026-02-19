#!/usr/bin/env node

/**
 * Quick Start Script - Displays all available commands
 */

const fs = require('fs');
const path = require('path');

console.log('\n');
console.log('╔════════════════════════════════════════════════════════════╗');
console.log('║        ComfyUI Image Generation - Quick Start Guide         ║');
console.log('╚════════════════════════════════════════════════════════════╝');

console.log('\n📁 Project Structure:\n');

const structure = `
image-generation/
├── 📋 COMFYUI_INTEGRATION_PLAN.md    Complete architecture & design
├── 📖 README.md                      Usage guide  
├── ✅ SETUP_COMPLETE.md              What was created (this guide)
├── 🚀 package.json                   Dependencies
│
├── 🔧 Core Files:
│   ├── comfyui-generator.js          Image generation engine
│   ├── config.js                     Configuration management
│   └── utils.js                      Utility functions
│
├── 📚 Examples:
│   ├── examples/basic-generation.js  Portrait generation example
│   ├── examples/test-connection.js   Server connection test
│   └── examples/submit-workflow.js   Custom workflow template
│
└── 📂 Data:
    ├── data/results/                 Generated images
    ├── data/backups/                 Workflow backups
    ├── data/workflows/               Workflow templates
    └── data/cache/                   Cached generations
`;

console.log(structure);

console.log('\n🚀 Quick Start Steps:\n');

const steps = [
  {
    num: 1,
    title: 'Install Dependencies',
    cmd: 'npm install',
    desc: 'Install node-fetch, ws, dotenv'
  },
  {
    num: 2,
    title: 'Setup Environment',
    cmd: 'cp .env.example .env',
    desc: 'Copy default configuration'
  },
  {
    num: 3,
    title: 'Start ComfyUI Server',
    cmd: 'python main.py  # From ComfyUI directory',
    desc: 'Must run on http://localhost:8188'
  },
  {
    num: 4,
    title: 'Test Connection',
    cmd: 'npm run test',
    desc: 'Verify server connectivity'
  },
  {
    num: 5,
    title: 'Generate Images',
    cmd: 'npm run example:basic',
    desc: 'Generate your first portrait'
  }
];

steps.forEach(step => {
  console.log(`\n  ${step.num}️⃣  ${step.title}`);
  console.log(`     $ ${step.cmd}`);
  console.log(`     ${step.desc}`);
});

console.log('\n\n📚 Available Scripts:\n');

const scripts = [
  { name: 'npm run test', desc: 'Test ComfyUI server connection & display info' },
  { name: 'npm run example:basic', desc: 'Generate sample portrait image' },
  { name: 'npm run example:workflow', desc: 'Submit custom workflow' },
  { name: 'npm run example:batch', desc: 'Generate multiple images' }
];

scripts.forEach(script => {
  console.log(`  ${script.name.padEnd(25)} → ${script.desc}`);
});

console.log('\n\n📖 Documentation:\n');

const docs = [
  {
    file: 'SETUP_COMPLETE.md',
    desc: 'Summary of what was created (read first)',
    location: 'image-generation/'
  },
  {
    file: 'COMFYUI_INTEGRATION_PLAN.md', 
    desc: 'Complete architecture & system design',
    location: 'image-generation/'
  },
  {
    file: 'README.md',
    desc: 'Detailed usage guide & API reference',
    location: 'image-generation/'
  }
];

docs.forEach(doc => {
  console.log(`  📄 ${doc.file}`);
  console.log(`     ${doc.desc}`);
  console.log(`     Location: ${doc.location}`);
  console.log('');
});

console.log('\n\n🔌 API Usage Examples:\n');

const examples = `
  // Basic usage
  const ComfyUIGenerator = require('./comfyui-generator');
  const generator = new ComfyUIGenerator();
  
  // Submit and wait for completion
  const result = await generator.generateImages({
    workflow: { /* your workflow */ },
    metadata: { userInitials: 'BC' }
  });
  
  // With progress monitoring
  await generator.generateImages({
    workflow,
    callbacks: {
      onProgress: (prog) => console.log(\`\${prog.percent}%\`),
      onComplete: (result) => console.log('Done!')
    }
  });
  
  // Check server status
  const stats = await generator.getSystemStats();
  const queue = await generator.getQueueStatus();
`;

console.log(examples);

console.log('\n\n⚙️  Configuration:\n');

console.log(`  Server:     http://localhost:8188`);
console.log(`  Output:     ./data/results/`);
console.log(`  Backups:    ./data/backups/`);
console.log(`  Workflows:  ./data/workflows/`);
console.log('\n  See .env for all configuration options\n');

console.log('\n\n🎯 Key Features:\n');

const features = [
  '✅ Complete workflow validation & submission',
  '✅ Real-time WebSocket monitoring',
  '✅ Automatic image download & storage',
  '✅ Comprehensive error handling',
  '✅ Workflow backup & metadata tracking',
  '✅ Flexible configuration system',
  '✅ Production-ready code'
];

features.forEach(feature => {
  console.log(`  ${feature}`);
});

console.log('\n\n💡 Next Steps:\n');

console.log(`  1. Read: SETUP_COMPLETE.md (overview of what was created)`);
console.log(`  2. Read: COMFYUI_INTEGRATION_PLAN.md (architecture & design)`);
console.log(`  3. Run: npm run test (verify ComfyUI connection)`);
console.log(`  4. Run: npm run example:basic (generate first image)`);
console.log(`  5. Integrate with Barb Cut backend`);

console.log('\n\n🔗 Resources:\n');

console.log(`  ComfyUI Documentation: https://docs.comfy.org/`);
console.log(`  API Routes: https://docs.comfy.org/development/comfyui-server/comms_routes`);
console.log(`  WebSocket: https://docs.comfy.org/development/comfyui-server/comms_messages`);

console.log('\n\n═══════════════════════════════════════════════════════════════\n');
console.log('✨ Everything is ready! Start with: npm run test\n');
console.log('═══════════════════════════════════════════════════════════════\n');

process.exit(0);
