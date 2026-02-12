import * as admin from "firebase-admin";

const isEmulator = Boolean(process.env.FIRESTORE_EMULATOR_HOST);
const credentialsPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;

if (isEmulator) {
  console.log("🔥 Using Firebase Emulator...");
  admin.initializeApp({
    projectId: "barb-cut",
    storageBucket: "barb-cut.appspot.com",
  });
} else {
  if (!credentialsPath) {
    console.error(
      "❌ Error: GOOGLE_APPLICATION_CREDENTIALS environment variable not set"
    );
    console.error(
      "   Set it with: export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccountKey.json"
    );
    console.error(
      "   OR set up emulator with: export FIRESTORE_EMULATOR_HOST=127.0.0.1:8080"
    );
    process.exit(1);
  }

  try {
    admin.initializeApp({
      credential: admin.credential.cert(require(credentialsPath)),
      storageBucket: "barb-cut.appspot.com",
    });
  } catch (error) {
    console.error("❌ Error: Could not load Firebase credentials");
    console.error(`   Path: ${credentialsPath}`);
    console.error(`   Error: ${error}`);
    process.exit(1);
  }
}

const db = admin.firestore();

async function seedMockData(): Promise<void> {
  const batch = db.batch();
  const baseDate = new Date("2026-02-13T10:00:00.000Z");

  const users = db.collection("test_users");
  const barbers = db.collection("test_barbers");
  const shops = db.collection("test_shops");
  const services = db.collection("test_services");
  const appointments = db.collection("test_appointments");
  const reviews = db.collection("test_reviews");

  const shopDowntownRef = shops.doc("shop_downtown");
  const shopUptownRef = shops.doc("shop_uptown");

  const barberARef = barbers.doc("barber_ali");
  const barberBRef = barbers.doc("barber_maya");

  const serviceFadeRef = services.doc("service_fade");
  const serviceBeardRef = services.doc("service_beard");
  const serviceColorRef = services.doc("service_color");

  const userRaviRef = users.doc("user_ravi");
  const userNiaRef = users.doc("user_nia");

  const appointmentARef = appointments.doc("appt_1001");
  const appointmentBRef = appointments.doc("appt_1002");

  batch.set(shopDowntownRef, {
    name: "Downtown Studio",
    phone: "+1-415-555-0100",
    isActive: true,
    ratingAvg: 4.7,
    createdAt: admin.firestore.Timestamp.fromDate(baseDate),
    address: {
      line1: "123 Market St",
      city: "San Francisco",
      state: "CA",
      postalCode: "94105",
    },
    location: new admin.firestore.GeoPoint(37.789, -122.401),
    amenities: ["parking", "wifi", "espresso"],
  });

  batch.set(shopUptownRef, {
    name: "Uptown Cut Lab",
    phone: "+1-415-555-0122",
    isActive: true,
    ratingAvg: 4.4,
    createdAt: admin.firestore.Timestamp.fromDate(
      new Date(baseDate.getTime() + 3600 * 1000)
    ),
    address: {
      line1: "88 Mission St",
      city: "San Francisco",
      state: "CA",
      postalCode: "94105",
    },
    location: new admin.firestore.GeoPoint(37.791, -122.393),
    amenities: ["private_room", "charging_stations"],
  });

  batch.set(barberARef, {
    displayName: "Ali Carter",
    yearsExperience: 8,
    isActive: true,
    specialties: ["fade", "texture", "lineup"],
    ratingAvg: 4.8,
    shopRef: shopDowntownRef,
    location: new admin.firestore.GeoPoint(37.789, -122.401),
    availability: {
      mon: ["10:00", "11:30", "14:00"],
      wed: ["12:00", "15:00"],
      fri: ["09:30", "13:00", "16:30"],
    },
    createdAt: admin.firestore.Timestamp.fromDate(
      new Date(baseDate.getTime() - 86400 * 1000)
    ),
  });

  batch.set(barberBRef, {
    displayName: "Maya Torres",
    yearsExperience: 5,
    isActive: true,
    specialties: ["beard", "color", "scalp_treatment"],
    ratingAvg: 4.6,
    shopRef: shopUptownRef,
    location: new admin.firestore.GeoPoint(37.791, -122.393),
    availability: {
      tue: ["09:00", "12:30", "16:00"],
      thu: ["11:00", "14:30"],
      sat: ["10:00", "13:30", "17:00"],
    },
    createdAt: admin.firestore.Timestamp.fromDate(
      new Date(baseDate.getTime() - 2 * 86400 * 1000)
    ),
  });

  batch.set(serviceFadeRef, {
    name: "Classic Fade",
    price: 35.0,
    durationMinutes: 30,
    isActive: true,
    categories: ["haircut", "fade"],
    barberRef: barberARef,
    shopRef: shopDowntownRef,
  });

  batch.set(serviceBeardRef, {
    name: "Beard Sculpt",
    price: 25.0,
    durationMinutes: 20,
    isActive: true,
    categories: ["beard", "grooming"],
    barberRef: barberBRef,
    shopRef: shopUptownRef,
  });

  batch.set(serviceColorRef, {
    name: "Color Refresh",
    price: 60.0,
    durationMinutes: 55,
    isActive: true,
    categories: ["color", "treatment"],
    barberRef: barberBRef,
    shopRef: shopUptownRef,
  });

  batch.set(userRaviRef, {
    displayName: "Ravi Patel",
    email: "ravi.patel@example.com",
    phone: "+1-415-555-0156",
    isActive: true,
    role: "client",
    rewardPoints: 120,
    createdAt: admin.firestore.Timestamp.fromDate(
      new Date(baseDate.getTime() - 6 * 86400 * 1000)
    ),
    lastLoginAt: admin.firestore.Timestamp.fromDate(
      new Date(baseDate.getTime() - 2 * 3600 * 1000)
    ),
    preferences: {
      prefersMorning: true,
      notes: "Sensitive scalp",
      favoriteStyles: ["fade", "textured_crop"],
    },
    address: {
      line1: "18 Howard St",
      city: "San Francisco",
      state: "CA",
      postalCode: "94105",
    },
    favoriteBarberRef: barberARef,
    favoriteServiceRefs: [serviceFadeRef, serviceBeardRef],
  });

  batch.set(userNiaRef, {
    displayName: "Nia Brooks",
    email: "nia.brooks@example.com",
    phone: "+1-415-555-0188",
    isActive: true,
    role: "client",
    rewardPoints: 75,
    createdAt: admin.firestore.Timestamp.fromDate(
      new Date(baseDate.getTime() - 3 * 86400 * 1000)
    ),
    lastLoginAt: admin.firestore.Timestamp.fromDate(
      new Date(baseDate.getTime() - 6 * 3600 * 1000)
    ),
    preferences: {
      prefersMorning: false,
      notes: "Allergic to certain dyes",
      favoriteStyles: ["beard", "scalp_treatment"],
    },
    address: {
      line1: "501 Mission St",
      city: "San Francisco",
      state: "CA",
      postalCode: "94105",
    },
    favoriteBarberRef: barberBRef,
    favoriteServiceRefs: [serviceBeardRef, serviceColorRef],
  });

  batch.set(appointmentARef, {
    userRef: userRaviRef,
    barberRef: barberARef,
    serviceRef: serviceFadeRef,
    shopRef: shopDowntownRef,
    status: "confirmed",
    isWalkIn: false,
    createdAt: admin.firestore.Timestamp.fromDate(
      new Date(baseDate.getTime() - 2 * 3600 * 1000)
    ),
    startAt: admin.firestore.Timestamp.fromDate(
      new Date(baseDate.getTime() + 2 * 3600 * 1000)
    ),
    endAt: admin.firestore.Timestamp.fromDate(
      new Date(baseDate.getTime() + 2.5 * 3600 * 1000)
    ),
    priceBreakdown: {
      base: 35,
      tip: 7,
      total: 42,
    },
    addOns: ["hot_towel"],
    notes: "Keep sides tight",
  });

  batch.set(appointmentBRef, {
    userRef: userNiaRef,
    barberRef: barberBRef,
    serviceRef: serviceColorRef,
    shopRef: shopUptownRef,
    status: "completed",
    isWalkIn: true,
    createdAt: admin.firestore.Timestamp.fromDate(
      new Date(baseDate.getTime() - 28 * 3600 * 1000)
    ),
    startAt: admin.firestore.Timestamp.fromDate(
      new Date(baseDate.getTime() - 24 * 3600 * 1000)
    ),
    endAt: admin.firestore.Timestamp.fromDate(
      new Date(baseDate.getTime() - 23 * 3600 * 1000)
    ),
    priceBreakdown: {
      base: 60,
      discount: 10,
      total: 50,
    },
    addOns: ["scalp_massage", "gloss"],
    notes: "Use ammonia-free dye",
  });

  batch.set(reviews.doc("review_5001"), {
    appointmentRef: appointmentBRef,
    userRef: userNiaRef,
    barberRef: barberBRef,
    rating: 5,
    comment: "Loved the color refresh!",
    createdAt: admin.firestore.Timestamp.fromDate(
      new Date(baseDate.getTime() - 22 * 3600 * 1000)
    ),
    tags: ["color", "friendly", "clean_shop"],
  });

  await batch.commit();
}

async function main() {
  try {
    console.log("🧪 Seeding mock Firestore data...");
    await seedMockData();
    console.log("✅ Mock data seeded successfully.");
  } catch (error) {
    console.error(`❌ Failed to seed mock data: ${error}`);
    process.exit(1);
  } finally {
    await admin.app().delete();
    process.exit(0);
  }
}

main();
