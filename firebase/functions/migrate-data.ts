import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';

// Initialize Firebase Admin
admin.initializeApp();

const db = admin.firestore();

/**
 * Migration script to upload local JSON data to Firebase Firestore
 * Run with: npx ts-node migrate-data.ts
 */

async function migrateHaircuts() {
  console.log('📂 Migrating haircuts...');
  
  const haircutsPath = path.join(__dirname, '../../apps/barbcut/assets/data/haircuts.json');
  const haircutsData = JSON.parse(fs.readFileSync(haircutsPath, 'utf8'));
  
  const batch = db.batch();
  let count = 0;
  
  for (const haircut of haircutsData) {
    const docRef = db.collection('haircuts').doc(haircut.id);
    batch.set(docRef, {
      ...haircut,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    count++;
    
    // Firestore batch limit is 500
    if (count % 500 === 0) {
      await batch.commit();
      console.log(`  ✓ Committed ${count} haircuts`);
    }
  }
  
  if (count % 500 !== 0) {
    await batch.commit();
  }
  
  console.log(`✅ Migrated ${count} haircuts`);
}

async function migrateBeardStyles() {
  console.log('📂 Migrating beard styles...');
  
  const beardStylesPath = path.join(__dirname, '../../apps/barbcut/assets/data/beard_styles.json');
  const beardStylesData = JSON.parse(fs.readFileSync(beardStylesPath, 'utf8'));
  
  const batch = db.batch();
  let count = 0;
  
  for (const beardStyle of beardStylesData) {
    const docRef = db.collection('beard_styles').doc(beardStyle.id);
    batch.set(docRef, {
      ...beardStyle,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    count++;
    
    if (count % 500 === 0) {
      await batch.commit();
      console.log(`  ✓ Committed ${count} beard styles`);
    }
  }
  
  if (count % 500 !== 0) {
    await batch.commit();
  }
  
  console.log(`✅ Migrated ${count} beard styles`);
}

async function migrateProducts() {
  console.log('📂 Migrating products...');
  
  const productsPath = path.join(__dirname, '../../apps/barbcut/assets/data/products.json');
  const productsData = JSON.parse(fs.readFileSync(productsPath, 'utf8'));
  
  const batch = db.batch();
  let count = 0;
  
  for (const product of productsData) {
    // Generate a unique ID if not present
    const productId = product.id || product.name.toLowerCase().replace(/\s+/g, '-');
    const docRef = db.collection('products').doc(productId);
    batch.set(docRef, {
      ...product,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    count++;
    
    if (count % 500 === 0) {
      await batch.commit();
      console.log(`  ✓ Committed ${count} products`);
    }
  }
  
  if (count % 500 !== 0) {
    await batch.commit();
  }
  
  console.log(`✅ Migrated ${count} products`);
}

async function clearCollection(collectionName: string) {
  console.log(`🗑️  Clearing ${collectionName} collection...`);
  
  const collectionRef = db.collection(collectionName);
  const snapshot = await collectionRef.get();
  
  const batch = db.batch();
  let count = 0;
  
  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
    count++;
    
    if (count % 500 === 0) {
      batch.commit();
    }
  });
  
  if (count % 500 !== 0) {
    await batch.commit();
  }
  
  console.log(`✅ Cleared ${count} documents from ${collectionName}`);
}

async function main() {
  try {
    console.log('🚀 Starting data migration...\n');
    
    const args = process.argv.slice(2);
    const shouldClear = args.includes('--clear');
    
    if (shouldClear) {
      console.log('⚠️  Clearing existing data...\n');
      await clearCollection('haircuts');
      await clearCollection('beard_styles');
      await clearCollection('products');
      console.log('');
    }
    
    await migrateHaircuts();
    await migrateBeardStyles();
    await migrateProducts();
    
    console.log('\n✨ Data migration completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
}

// Run the migration
main();
