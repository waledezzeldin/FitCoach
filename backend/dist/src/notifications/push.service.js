"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendPushNotification = sendPushNotification;
const firebase_admin_1 = require("firebase-admin");
const path_1 = require("path");
firebase_admin_1.default.initializeApp({
    credential: firebase_admin_1.default.credential.cert(path_1.default.resolve(__dirname, '../../firebase-service-account.json')),
});
async function sendPushNotification(token, title, body) {
    await firebase_admin_1.default.messaging().send({
        token,
        notification: { title, body },
    });
}
//# sourceMappingURL=push.service.js.map