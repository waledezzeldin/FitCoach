"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const jsonwebtoken_1 = require("jsonwebtoken");
const axios_1 = require("axios");
const bcrypt_1 = require("bcrypt");
const apple_signin_auth_1 = require("apple-signin-auth");
const firebase_admin_1 = require("firebase-admin");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
const PHONE_ROLE_OVERRIDES = {
    '+966507654321': 'coach',
    '+966509876543': 'admin',
};
if (!firebase_admin_1.default.apps.length) {
    firebase_admin_1.default.initializeApp({
        credential: firebase_admin_1.default.credential.applicationDefault(),
    });
}
const inferRoleFromPhone = (phone) => {
    if (!phone)
        return 'user';
    return PHONE_ROLE_OVERRIDES[phone] ?? 'user';
};
const deriveEmailFromPhone = (phone, fallback) => {
    if (fallback && fallback.includes('@'))
        return fallback;
    const digits = phone.replace(/[^0-9]/g, '');
    const suffix = digits || Date.now().toString();
    return `phone_${suffix}@fitcoach.app`;
};
const sanitizeUser = (user) => ({
    id: user.id,
    name: user.name,
    email: user.email,
    phone: user.phone,
    role: user.role,
    preferredLocale: user.preferredLocale,
});
async function upsertPhoneUser(phone, name, emailHint, preferredLocale) {
    const inferredRole = inferRoleFromPhone(phone);
    const fallbackEmail = deriveEmailFromPhone(phone, emailHint);
    const displayName = name || 'Phone User';
    let user = (await prisma.user.findUnique({ where: { phone } }));
    if (!user) {
        user = await prisma.user.create({
            data: {
                name: displayName,
                email: fallbackEmail,
                phone,
                role: inferredRole,
                preferredLocale,
            },
        });
    }
    else {
        const updateData = {};
        if (user.role !== inferredRole) {
            updateData.role = inferredRole;
        }
        if (preferredLocale && preferredLocale !== user.preferredLocale) {
            updateData.preferredLocale = preferredLocale;
        }
        if (Object.keys(updateData).length > 0) {
            user = await prisma.user.update({ where: { id: user.id }, data: updateData });
        }
    }
    return user;
}
const preferredLocaleFromRequest = (req) => {
    const header = req.headers['accept-language'];
    if (!header)
        return undefined;
    const raw = Array.isArray(header) ? header[0] : header;
    if (!raw)
        return undefined;
    const code = raw.split(',')[0]?.trim();
    if (!code)
        return undefined;
    return code.slice(0, 5);
};
router.post('/auth/signup', async (req, res) => {
    try {
        const { name, email, password, role, preferredLocale } = req.body;
        if (!name || !email || !password || !role) {
            return res.status(400).json({ error: 'All fields are required.' });
        }
        const existing = await prisma.user.findUnique({ where: { email } });
        if (existing) {
            return res.status(409).json({ error: 'User already exists.' });
        }
        const hashed = await bcrypt_1.default.hash(password, 10);
        const user = await prisma.user.create({
            data: { name, email, password: hashed, role, preferredLocale },
        });
        const token = jsonwebtoken_1.default.sign({ userId: user.id }, process.env.JWT_SECRET);
        res.json({ token, user: sanitizeUser(user) });
    }
    catch (err) {
        res.status(500).json({ error: 'Signup failed.' });
    }
});
router.post('/auth/social/google', async (req, res) => {
    try {
        const { idToken } = req.body;
        const googleRes = await axios_1.default.get(`https://oauth2.googleapis.com/tokeninfo?id_token=${idToken}`);
        const { email, name } = googleRes.data;
        if (!email)
            return res.status(400).json({ error: 'Google token invalid.' });
        let user = await prisma.user.findUnique({ where: { email } });
        if (!user) {
            user = await prisma.user.create({ data: { name, email, role: 'user' } });
        }
        const token = jsonwebtoken_1.default.sign({ userId: user.id }, process.env.JWT_SECRET);
        res.json({ token, user });
    }
    catch (err) {
        res.status(500).json({ error: 'Google sign-in failed.' });
    }
});
router.post('/auth/social/facebook', async (req, res) => {
    try {
        const { accessToken } = req.body;
        const fbRes = await axios_1.default.get(`https://graph.facebook.com/me?fields=id,name,email&access_token=${accessToken}`);
        const { email, name } = fbRes.data;
        if (!email)
            return res.status(400).json({ error: 'Facebook token invalid.' });
        let user = await prisma.user.findUnique({ where: { email } });
        if (!user) {
            user = await prisma.user.create({ data: { name, email, role: 'user' } });
        }
        const token = jsonwebtoken_1.default.sign({ userId: user.id }, process.env.JWT_SECRET);
        res.json({ token, user });
    }
    catch (err) {
        res.status(500).json({ error: 'Facebook sign-in failed.' });
    }
});
router.post('/auth/social/apple', async (req, res) => {
    try {
        const { appleToken } = req.body;
        const payload = await apple_signin_auth_1.default.verifyIdToken(appleToken, {
            audience: 'YOUR_APPLE_SERVICE_ID',
            ignoreExpiration: false,
        });
        const email = payload.email;
        const name = 'Apple User';
        if (!email)
            return res.status(400).json({ error: 'Apple token invalid.' });
        let user = await prisma.user.findUnique({ where: { email } });
        if (!user) {
            user = await prisma.user.create({ data: { name, email, role: 'user' } });
        }
        const token = jsonwebtoken_1.default.sign({ userId: user.id }, process.env.JWT_SECRET);
        res.json({ token, user });
    }
    catch (err) {
        res.status(500).json({ error: 'Apple sign-in failed.' });
    }
});
router.post('/auth/social/phone', async (req, res) => {
    try {
        const { phoneToken } = req.body;
        const decoded = await firebase_admin_1.default.auth().verifyIdToken(phoneToken);
        const phone = decoded.phone_number;
        if (!phone)
            return res.status(400).json({ error: 'Phone token invalid.' });
        const preferredLocale = preferredLocaleFromRequest(req);
        const user = await upsertPhoneUser(phone, decoded.name, decoded.email, preferredLocale);
        const token = jsonwebtoken_1.default.sign({ userId: user.id, role: user.role }, process.env.JWT_SECRET);
        const subscriptionType = user.role === 'coach' || user.role === 'admin' ? 'smart_premium' : 'freemium';
        res.json({ access_token: token, refresh_token: token, user: sanitizeUser(user), subscriptionType });
    }
    catch (err) {
        res.status(500).json({ error: 'Phone sign-in failed.' });
    }
});
router.post('/auth/firebase/exchange', async (req, res) => {
    try {
        const { idToken } = req.body;
        if (!idToken) {
            return res.status(400).json({ error: 'idToken required.' });
        }
        const decoded = await firebase_admin_1.default.auth().verifyIdToken(idToken);
        const phone = decoded.phone_number;
        if (!phone)
            return res.status(400).json({ error: 'Phone number missing from token.' });
        const preferredLocale = preferredLocaleFromRequest(req);
        const user = await upsertPhoneUser(phone, decoded.name, decoded.email, preferredLocale);
        const payload = { userId: user.id, role: user.role };
        const accessToken = jsonwebtoken_1.default.sign(payload, process.env.JWT_SECRET);
        const subscriptionType = user.role === 'coach' || user.role === 'admin' ? 'smart_premium' : 'freemium';
        res.json({ access_token: accessToken, refresh_token: accessToken, user: sanitizeUser(user), subscriptionType });
    }
    catch (err) {
        res.status(500).json({ error: 'Phone sign-in failed.' });
    }
});
exports.default = router;
//# sourceMappingURL=auth.controller.js.map