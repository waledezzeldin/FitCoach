import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { OAuth2Client } from 'google-auth-library';
import axios from 'axios';
import { authenticateJWT, requireAdmin } from './middleware/auth.middleware';

const router = Router();
const prisma = new PrismaClient();

// Register
router.post('/register', async (req: Request, res: Response) => {
  try {
    const { email, password, name, phone } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password required.' });
    }
    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      return res.status(409).json({ error: 'Email already registered.' });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        name,
        phone,
      },
    });
    res.status(201).json({ id: user.id, email: user.email, name: user.name, phone: user.phone });
  } catch (err) {
    res.status(500).json({ error: 'Registration failed.' });
  }
});

// Login
router.post('/login', async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password required.' });
    }
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials.' });
    }
    const valid = await bcrypt.compare(password, user.password);
    if (!valid) {
      return res.status(401).json({ error: 'Invalid credentials.' });
    }
    // Generate JWT token
    const token = jwt.sign({ userId: user.id, email: user.email }, process.env.JWT_SECRET || 'secret', { expiresIn: '7d' });
    res.json({ token, user: { id: user.id, email: user.email, name: user.name, phone: user.phone } });
  } catch (err) {
    res.status(500).json({ error: 'Login failed.' });
  }
});

// Social Login
router.post('/social', async (req: Request, res: Response) => {
  try {
    const { provider, accessToken } = req.body;
    let profile;

    if (provider === 'google') {
      // Use google-auth-library or passport-google-oauth20 to verify token and get profile
      // For brevity, pseudo-code:
      // profile = await verifyGoogleToken(accessToken);
    } else if (provider === 'facebook') {
      // ...existing Facebook logic...
    } else if (provider === 'apple') {
      // Verify Apple identity token
      // Apple tokens are JWTs; decode and validate signature if needed
      const decoded = jwt.decode(accessToken, { complete: true }) as { payload?: jwt.JwtPayload | string };
      if (
        !decoded ||
        !decoded.payload ||
        typeof decoded.payload === 'string' ||
        !(decoded.payload as jwt.JwtPayload).email
      ) {
        return res.status(400).json({ error: 'Invalid Apple token.' });
      }
      profile = {
        email: (decoded.payload as jwt.JwtPayload).email as string,
        name: ((decoded.payload as jwt.JwtPayload).name as string) || '',
      };
    }

    if (!profile || !profile.email) {
      return res.status(400).json({ error: 'Invalid social login.' });
    }

    // Upsert user
    let user = await prisma.user.findUnique({ where: { email: profile.email } });
    if (!user) {
      user = await prisma.user.create({
        data: {
          email: profile.email,
          name: profile.name,
        }
      });
    }

    // Generate JWT
    const token = jwt.sign({ userId: user.id, email: user.email }, process.env.JWT_SECRET || 'secret', { expiresIn: '7d' });
    res.json({ token, user: { id: user.id, email: user.email, name: user.name } });
  } catch (err) {
    res.status(500).json({ error: 'Social login failed.' });
  }
});

// Get user profile
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.params.id },
      select: { id: true, email: true, name: true, phone: true }
    });
    if (!user) {
      return res.status(404).json({ error: 'User not found.' });
    }
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch user profile.' });
  }
});

// Update user profile
router.put('/:id', async (req: Request, res: Response) => {
  try {
    const { name, phone } = req.body;
    const user = await prisma.user.update({
      where: { id: req.params.id },
      data: { name, phone }
    });
    res.json({ id: user.id, email: user.email, name: user.name, phone: user.phone });
  } catch (err) {
    res.status(500).json({ error: 'Failed to update user profile.' });
  }
});

// Admin: Get all users
router.get('/', authenticateJWT, requireAdmin, async (req: Request, res: Response) => {
  try {
    const users = await prisma.user.findMany();
    res.json(users);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch users.' });
  }
});

export default router;