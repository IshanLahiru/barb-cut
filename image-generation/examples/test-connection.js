/**
 * Test Connection Example
 * 
 * This example tests the connection to ComfyUI server and displays
 * system information and available models.
 */

const ComfyUIGenerator = require('../comfyui-generator');
const config = require('../config');

async function main() {
  const generator = new ComfyUIGenerator({
    serverUrl: config.server.url,
  });

  try {
    console.log('\n🔍 Testing ComfyUI Server Connection');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`🌐 Server URL: ${config.server.url}`);

    // Test basic fetching
    try {
      console.log('\n📡 Fetching system stats...');
      const stats = await generator.getSystemStats();
      
      console.log('\n✅ System Information:');
      if (stats.system) console.log(`  OS: ${stats.system.os}`);
      if (stats.devices) {
        console.log(`\n  Available Devices:`);
        Object.entries(stats.devices).forEach(([name, device]) => {
          if (device.type && device.device) {
            console.log(`    - ${name}: ${device.device.type}`);
          }
        });
      }
      if (stats.vram) {
        console.log(`\n  VRAM Summary:`);
        Object.entries(stats.vram).forEach(([key, value]) => {
          if (typeof value === 'number') {
            console.log(`    - ${key}: ${(value / 1024 / 1024).toFixed(2)} MB`);
          }
        });
      }
    } catch (error) {
      console.error('  ❌ Could not fetch system stats:', error.message);
    }

    // Test queue status
    try {
      console.log('\n📋 Fetching queue status...');
      const queue = await generator.getQueueStatus();
      
      console.log('✅ Queue Status:');
      console.log(`  - Queue size: ${queue.queue ? queue.queue.length : 0}`);
      if (queue.queue_pending) {
        console.log(`  - Pending: ${queue.queue_pending.length}`);
      }
    } catch (error) {
      console.error('  ❌ Could not fetch queue status:', error.message);
    }

    // Connect WebSocket
    try {
      console.log('\n🔗 Connecting to WebSocket...');
      await generator.connectWebSocket();
      console.log('✅ WebSocket connected successfully');
      
      // Give it a moment to receive status message
      await new Promise(resolve => setTimeout(resolve, 1000));
    } catch (error) {
      console.error('❌ WebSocket connection failed:', error.message);
    }

    console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('✅ Connection test completed!');

  } catch (error) {
    console.error('\n❌ Test failed:');
    console.error(error.message);
    process.exit(1);
  } finally {
    await generator.disconnect();
  }
}

main();
