"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const bcryptjs_1 = require("bcryptjs");
const jsonwebtoken_1 = require("jsonwebtoken");
const auth_middleware_1 = require("./middleware/auth.middleware");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
router.post('/register', async (req, res) => {
    try {
        const { email, password, name, role } = req.body;
        let user = await prisma.user.findUnique({ where: { email } });
        if (user)
            return res.status(400).json({ error: 'Email already exists.' });
        user = await prisma.user.create({
            data: {
                email,
                password,
                name,
                role: role === 'coach' ? 'pending_coach' : 'user',
            }
        });
        if (role === 'coach') {
            await prisma.coachRequest.create({
                data: {
                    userId: user.id,
                    status: 'pending',
                }
            });
        }
        res.json({ success: true, user });
    }
    catch (err) {
        res.status(500).json({ error: 'Registration failed.' });
    }
});
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password required.' });
        }
        const user = await prisma.user.findUnique({ where: { email } });
        if (!user) {
            return res.status(401).json({ error: 'Invalid credentials.' });
        }
        const valid = await bcryptjs_1.default.compare(password, user.password);
        if (!valid) {
            return res.status(401).json({ error: 'Invalid credentials.' });
        }
        const token = jsonwebtoken_1.default.sign({ userId: user.id, email: user.email }, process.env.JWT_SECRET || 'secret', { expiresIn: '7d' });
        res.json({ token, user: { id: user.id, email: user.email, name: user.name, phone: user.phone } });
    }
    catch (err) {
        res.status(500).json({ error: 'Login failed.' });
    }
});
router.post('/social', async (req, res) => {
    try {
        const { provider, accessToken } = req.body;
        let profile;
        if (provider === 'google') {
        }
        else if (provider === 'facebook') {
        }
        else if (provider === 'apple') {
            const decoded = jsonwebtoken_1.default.decode(accessToken, { complete: true });
            if (!decoded ||
                !decoded.payload ||
                typeof decoded.payload === 'string' ||
                !decoded.payload.email) {
                return res.status(400).json({ error: 'Invalid Apple token.' });
            }
            profile = {
                email: decoded.payload.email,
                name: decoded.payload.name || '',
            };
        }
        if (!profile || !profile.email) {
            return res.status(400).json({ error: 'Invalid social login.' });
        }
        let user = await prisma.user.findUnique({ where: { email: profile.email } });
        if (!user) {
            user = await prisma.user.create({
                data: {
                    email: profile.email,
                    name: profile.name,
                }
            });
        }
        const token = jsonwebtoken_1.default.sign({ userId: user.id, email: user.email }, process.env.JWT_SECRET || 'secret', { expiresIn: '7d' });
        res.json({ token, user: { id: user.id, email: user.email, name: user.name } });
    }
    catch (err) {
        res.status(500).json({ error: 'Social login failed.' });
    }
});
router.get('/:id', async (req, res) => {
    try {
        const user = await prisma.user.findUnique({
            where: { id: req.params.id },
            select: { id: true, email: true, name: true, phone: true }
        });
        if (!user) {
            return res.status(404).json({ error: 'User not found.' });
        }
        res.json(user);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to fetch user profile.' });
    }
});
router.put('/:id', async (req, res) => {
    try {
        const { name, phone } = req.body;
        const user = await prisma.user.update({
            where: { id: req.params.id },
            data: { name, phone }
        });
        res.json({ id: user.id, email: user.email, name: user.name, phone: user.phone });
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to update user profile.' });
    }
});
router.get('/', auth_middleware_1.authenticateJWT, auth_middleware_1.requireAdmin, async (req, res) => {
    try {
        const users = await prisma.user.findMany();
        res.json(users);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to fetch users.' });
    }
});
exports.default = router;
//# sourceMappingURL=users.controller.js.map