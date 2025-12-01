"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendPushNotification = sendPushNotification;
const firebase_admin_1 = require("firebase-admin");
const fs_1 = require("fs");
const path_1 = require("path");
let firebaseReady = false;
const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH ??
    path_1.default.resolve(__dirname, '../../firebase-service-account.json');
try {
    const serviceAccountRaw = process.env.FIREBASE_SERVICE_ACCOUNT
        ? JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)
        : fs_1.default.existsSync(serviceAccountPath)
            ? JSON.parse(fs_1.default.readFileSync(serviceAccountPath, 'utf-8'))
            : null;
    if (serviceAccountRaw) {
        firebase_admin_1.default.initializeApp({
            credential: firebase_admin_1.default.credential.cert(serviceAccountRaw),
        });
        firebaseReady = true;
    }
    else {
        console.warn('Firebase service account not configured; push notifications disabled.');
    }
}
catch (err) {
    console.warn('Failed to initialize Firebase Admin SDK. Push notifications disabled.', err);
}
async function sendPushNotification(token, title, body) {
    if (!firebaseReady) {
        console.warn('Skipping push notification because Firebase is not initialized.');
        return;
    }
    await firebase_admin_1.default.messaging().send({
        token,
        notification: { title, body },
    });
}
//# sourceMappingURL=push.service.js.map