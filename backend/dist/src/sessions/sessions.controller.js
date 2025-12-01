"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const agora_access_token_1 = require("agora-access-token");
const quota_service_1 = require("../subscription/quota.service");
const prisma = new client_1.PrismaClient();
const router = (0, express_1.Router)();
const buildAvailability = (start, days, existing) => {
    const taken = new Set(existing.map((d) => d.toISOString()));
    const slotsPerDay = ['09:00', '11:00', '13:00', '15:00', '17:00'];
    const results = [];
    for (let i = 0; i < days; i += 1) {
        const day = new Date(start);
        day.setDate(start.getDate() + i);
        const dayISO = day.toISOString().split('T')[0];
        const slots = slotsPerDay
            .map((time) => {
            const [h, m] = time.split(':').map(Number);
            const slot = new Date(day);
            slot.setHours(h, m, 0, 0);
            return slot;
        })
            .filter((slot) => slot > new Date())
            .filter((slot) => !taken.has(slot.toISOString()))
            .map((slot) => ({
            label: slot.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' }),
            iso: slot.toISOString(),
        }));
        results.push({ date: dayISO, slots });
    }
    return results;
};
router.get('/availability/:coachId', async (req, res) => {
    const { coachId } = req.params;
    const days = Math.min(Math.max(Number(req.query.days ?? 7), 1), 14);
    const from = new Date();
    const until = new Date(from);
    until.setDate(from.getDate() + days);
    try {
        const sessions = await prisma.session.findMany({
            where: {
                coachId,
                scheduledAt: { gte: from, lt: until },
                status: { notIn: ['cancelled'] },
            },
            select: { scheduledAt: true },
        });
        res.json({ availability: buildAvailability(from, days, sessions.map((s) => s.scheduledAt)) });
    }
    catch (err) {
        console.error('Failed to fetch availability', err);
        res.status(500).json({ error: 'Failed to fetch availability.' });
    }
});
router.post('/', async (req, res) => {
    const { userId, coachId, scheduledAt, durationMin } = req.body;
    if (!userId || !coachId || !scheduledAt) {
        return res.status(400).json({ error: 'userId, coachId, and scheduledAt are required.' });
    }
    try {
        const slot = new Date(scheduledAt);
        const conflict = await prisma.session.findFirst({
            where: { coachId, scheduledAt: slot, status: { not: 'cancelled' } },
        });
        if (conflict) {
            return res.status(409).json({ error: 'Time slot unavailable.' });
        }
        const quotaResult = await (0, quota_service_1.consumeQuota)(prisma, userId, 'call');
        if (!quotaResult.allowed) {
            return res.status(409).json(quotaResult);
        }
        const session = await prisma.session.create({
            data: {
                userId,
                coachId,
                scheduledAt: slot,
                durationMin: durationMin || 30,
                status: 'scheduled',
            },
        });
        res.status(201).json(session);
    }
    catch (err) {
        console.error('Failed to schedule session', err);
        res.status(500).json({ error: 'Failed to schedule session.' });
    }
});
router.post('/:id/rate', async (req, res) => {
    const { id } = req.params;
    const { userId, rating, note } = req.body;
    if (!userId || typeof rating !== 'number' || rating < 1 || rating > 5) {
        return res.status(400).json({ error: 'userId and rating (1-5) are required.' });
    }
    try {
        const session = await prisma.session.findUnique({ where: { id } });
        if (!session) {
            return res.status(404).json({ error: 'Session not found.' });
        }
        if (session.userId !== userId) {
            return res.status(403).json({ error: 'Cannot rate this session.' });
        }
        const updated = await prisma.session.update({
            where: { id },
            data: {
                rating,
                ratingNote: note,
                status: 'completed',
            },
        });
        res.json(updated);
    }
    catch (err) {
        console.error('Failed to rate session', err);
        res.status(500).json({ error: 'Failed to submit rating.' });
    }
});
router.get('/:id/join', async (req, res) => {
    const session = await prisma.session.findUnique({ where: { id: req.params.id } });
    if (!session)
        return res.status(404).json({ error: 'not_found' });
    const channel = session.agoraChannel || `session_${session.id}`;
    const appId = process.env.AGORA_APP_ID || '';
    const appCert = process.env.AGORA_APP_CERT || '';
    const uid = 0;
    const expire = Math.floor(Date.now() / 1000) + 3600;
    const token = agora_access_token_1.RtcTokenBuilder.buildTokenWithUid(appId, appCert, channel, uid, agora_access_token_1.RtcRole.PUBLISHER, expire);
    if (!session.agoraChannel) {
        await prisma.session.update({ where: { id: session.id }, data: { agoraChannel: channel } });
    }
    res.json({ channelName: channel, token, expiresAt: expire });
});
exports.default = router;
//# sourceMappingURL=sessions.controller.js.map