const admin = require("firebase-admin");

const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

async function setRole(uid, role) {
  await admin.auth().setCustomUserClaims(uid, { role });
  console.log(`✅ Role "${role}" berhasil diset untuk UID: ${uid}`);
}

// ===============================
// GANTI UID SESUAI FIREBASE AUTH
// ===============================
(async () => {
  await setRole("yM7eouaqZ9YnJ6rG5C4CDek19pD2", "admin");
  await setRole("os47rclI4XPUNvZZBQXYsQKQHlp2", "juri");
  await setRole("5RZqTmki5EPfJLAPw69tOl2xNu32", "peserta");
})();
