import admin from 'firebase-admin';
import fs from 'fs';
import path from 'path';

let firebaseReady = false;

const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH ??
  path.resolve(__dirname, '../../firebase-service-account.json');

try {
  const serviceAccountRaw = process.env.FIREBASE_SERVICE_ACCOUNT
    ? JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)
    : fs.existsSync(serviceAccountPath)
      ? JSON.parse(fs.readFileSync(serviceAccountPath, 'utf-8'))
      : null;

  if (serviceAccountRaw) {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccountRaw as admin.ServiceAccount),
    });
    firebaseReady = true;
  } else {
    console.warn('Firebase service account not configured; push notifications disabled.');
  }
} catch (err) {
  console.warn('Failed to initialize Firebase Admin SDK. Push notifications disabled.', err);
}

export async function sendPushNotification(token: string, title: string, body: string) {
  if (!firebaseReady) {
    console.warn('Skipping push notification because Firebase is not initialized.');
    return;
  }
  await admin.messaging().send({
    token,
    notification: { title, body },
  });
}