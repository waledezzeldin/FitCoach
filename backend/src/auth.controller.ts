import { Router, Request } from 'express';
import { PrismaClient } from '@prisma/client';
import jwt from 'jsonwebtoken';
import axios from 'axios';
import bcrypt from 'bcrypt';
import appleSigninAuth from 'apple-signin-auth';
import admin from 'firebase-admin';

const router = Router();
const prisma = new PrismaClient();
const PHONE_ROLE_OVERRIDES: Record<string, 'coach' | 'admin'> = {
  '+966507654321': 'coach',
  '+966509876543': 'admin',
};

// Initialize Firebase Admin once in your app
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
  });
}

const inferRoleFromPhone = (phone?: string): 'user' | 'coach' | 'admin' => {
  if (!phone) return 'user';
  return PHONE_ROLE_OVERRIDES[phone] ?? 'user';
};

const deriveEmailFromPhone = (phone: string, fallback?: string | null) => {
  if (fallback && fallback.includes('@')) return fallback;
  const digits = phone.replace(/[^0-9]/g, '');
  const suffix = digits || Date.now().toString();
  return `phone_${suffix}@fitcoach.app`;
};

const sanitizeUser = (user: {
  id: string;
  name: string | null;
  email: string | null;
  phone: string | null;
  role: string;
  preferredLocale?: string | null;
}) => ({
  id: user.id,
  name: user.name,
  email: user.email,
  phone: user.phone,
  role: user.role,
  preferredLocale: user.preferredLocale,
});

async function upsertPhoneUser(
  phone: string,
  name?: string | null,
  emailHint?: string | null,
  preferredLocale?: string | null,
) {
  const inferredRole = inferRoleFromPhone(phone);
  const fallbackEmail = deriveEmailFromPhone(phone, emailHint);
  const displayName = name || 'Phone User';
  let user = (await prisma.user.findUnique({ where: { phone } })) as any;
  if (!user) {
    user = await prisma.user.create({
      data: {
        name: displayName,
        email: fallbackEmail,
        phone,
        role: inferredRole,
        preferredLocale,
      } as any,
    });
  } else {
    const updateData: Record<string, unknown> = {};
    if (user.role !== inferredRole) {
      updateData.role = inferredRole;
    }
    if (preferredLocale && preferredLocale !== user.preferredLocale) {
      updateData.preferredLocale = preferredLocale;
    }
    if (Object.keys(updateData).length > 0) {
      user = await prisma.user.update({ where: { id: user.id }, data: updateData as any });
    }
  }
  return user;
}

const preferredLocaleFromRequest = (req: Request): string | undefined => {
  const header = req.headers['accept-language'];
  if (!header) return undefined;
  const raw = Array.isArray(header) ? header[0] : header;
  if (!raw) return undefined;
  const code = raw.split(',')[0]?.trim();
  if (!code) return undefined;
  return code.slice(0, 5);
};

// Email/password signup
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
    const hashed = await bcrypt.hash(password, 10);
    const user = await prisma.user.create({
      data: { name, email, password: hashed, role, preferredLocale } as any,
    });
    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET!);
    res.json({ token, user: sanitizeUser(user as any) });
  } catch (err) {
    res.status(500).json({ error: 'Signup failed.' });
  }
});

// Social signup (Google)
router.post('/auth/social/google', async (req, res) => {
  try {
    const { idToken } = req.body;
    const googleRes = await axios.get(`https://oauth2.googleapis.com/tokeninfo?id_token=${idToken}`);
    const { email, name } = googleRes.data as { email?: string; name?: string };
    if (!email) return res.status(400).json({ error: 'Google token invalid.' });
    let user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      user = await prisma.user.create({ data: { name, email, role: 'user' } });
    }
    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET!);
    res.json({ token, user });
  } catch (err) {
    res.status(500).json({ error: 'Google sign-in failed.' });
  }
});

// Social signup (Facebook)
router.post('/auth/social/facebook', async (req, res) => {
  try {
    const { accessToken } = req.body;
    const fbRes = await axios.get<{ email?: string; name?: string }>(`https://graph.facebook.com/me?fields=id,name,email&access_token=${accessToken}`);
    const { email, name } = fbRes.data;
    if (!email) return res.status(400).json({ error: 'Facebook token invalid.' });
    let user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      user = await prisma.user.create({ data: { name, email, role: 'user' } });
    }
    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET!);
    res.json({ token, user });
  } catch (err) {
    res.status(500).json({ error: 'Facebook sign-in failed.' });
  }
});

// Apple sign-in (pseudo, you need to verify Apple token)
router.post('/auth/social/apple', async (req, res) => {
  try {
    const { appleToken } = req.body;
    const payload = await appleSigninAuth.verifyIdToken(appleToken, {
      audience: 'YOUR_APPLE_SERVICE_ID', // Replace with your Apple Service ID
      ignoreExpiration: false,
    });
    const email = payload.email;
    const name = 'Apple User';
    if (!email) return res.status(400).json({ error: 'Apple token invalid.' });
    let user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      user = await prisma.user.create({ data: { name, email, role: 'user' } });
    }
    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET!);
    res.json({ token, user });
  } catch (err) {
    res.status(500).json({ error: 'Apple sign-in failed.' });
  }
});

// Phone sign-in (pseudo, you need to verify Firebase token)
router.post('/auth/social/phone', async (req, res) => {
  try {
    const { phoneToken } = req.body;
    const decoded = await admin.auth().verifyIdToken(phoneToken);
    const phone = decoded.phone_number;
    if (!phone) return res.status(400).json({ error: 'Phone token invalid.' });
    const preferredLocale = preferredLocaleFromRequest(req);
    const user = await upsertPhoneUser(phone, decoded.name, decoded.email, preferredLocale);
    const token = jwt.sign({ userId: user.id, role: user.role }, process.env.JWT_SECRET!);
    const subscriptionType = user.role === 'coach' || user.role === 'admin' ? 'smart_premium' : 'freemium';
    res.json({ access_token: token, refresh_token: token, user: sanitizeUser(user), subscriptionType });
  } catch (err) {
    res.status(500).json({ error: 'Phone sign-in failed.' });
  }
});

router.post('/auth/firebase/exchange', async (req, res) => {
  try {
    const { idToken } = req.body;
    if (!idToken) {
      return res.status(400).json({ error: 'idToken required.' });
    }
    const decoded = await admin.auth().verifyIdToken(idToken);
    const phone = decoded.phone_number;
    if (!phone) return res.status(400).json({ error: 'Phone number missing from token.' });
    const preferredLocale = preferredLocaleFromRequest(req);
    const user = await upsertPhoneUser(phone, decoded.name, decoded.email, preferredLocale);
    const payload = { userId: user.id, role: user.role };
    const accessToken = jwt.sign(payload, process.env.JWT_SECRET!);
    const subscriptionType = user.role === 'coach' || user.role === 'admin' ? 'smart_premium' : 'freemium';
    res.json({ access_token: accessToken, refresh_token: accessToken, user: sanitizeUser(user), subscriptionType });
  } catch (err) {
    res.status(500).json({ error: 'Phone sign-in failed.' });
  }
});

export default router;