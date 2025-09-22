"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const agora_access_token_1 = require("agora-access-token");
const prisma = new client_1.PrismaClient();
const router = (0, express_1.Router)();
router.post('/', async (req, res) => {
    const { userId, coachId, scheduledAt, durationMin } = req.body;
    const session = await prisma.session.create({
        data: { userId, coachId, scheduledAt: new Date(scheduledAt), durationMin: durationMin || 30, status: 'scheduled' }
    });
    res.json(session);
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