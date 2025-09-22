import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import jwt from 'jsonwebtoken';
import axios from 'axios';
import bcrypt from 'bcrypt';
import appleSigninAuth from 'apple-signin-auth';
import admin from 'firebase-admin';

const router = Router();
const prisma = new PrismaClient();

// Initialize Firebase Admin once in your app
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
  });
}

// Email/password signup
router.post('/auth/signup', async (req, res) => {
  try {
    const { name, email, password, role } = req.body;
    if (!name || !email || !password || !role) {
      return res.status(400).json({ error: 'All fields are required.' });
    }
    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
      return res.status(409).json({ error: 'User already exists.' });
    }
    const hashed = await bcrypt.hash(password, 10);
    const user = await prisma.user.create({ data: { name, email, password: hashed, role } });
    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET!);
    res.json({ token, user });
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
    let user = await prisma.user.findUnique({ where: { phone } });
    if (!user) {
      user = await prisma.user.create({ data: { name: 'Phone User', phone, role: 'user' } });
    }
    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET!);
    res.json({ token, user });
  } catch (err) {
    res.status(500).json({ error: 'Phone sign-in failed.' });
  }
});

export default router;