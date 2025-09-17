import admin from 'firebase-admin';
import path from 'path';

// Initialize Firebase Admin SDK (use your service account JSON file)
admin.initializeApp({
  credential: admin.credential.cert(path.resolve(__dirname, '../../firebase-service-account.json')),
});

export async function sendPushNotification(token: string, title: string, body: string) {
  await admin.messaging().send({
    token,
    notification: { title, body },
  });
}