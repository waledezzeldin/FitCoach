import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { RtcTokenBuilder, RtcRole } from 'agora-access-token';
const prisma = new PrismaClient();
const router = Router();

// POST /v1/sessions -> schedule session
router.post('/', async (req, res) => {
  const { userId, coachId, scheduledAt, durationMin } = req.body;
  const session = await prisma.session.create({
    data: { userId, coachId, scheduledAt: new Date(scheduledAt), durationMin: durationMin || 30, status: 'scheduled' }
  });
  res.json(session);
});

// GET /v1/sessions/:id/join -> return agora token + channel name
router.get('/:id/join', async (req, res) => {
  const session = await prisma.session.findUnique({ where: { id: req.params.id }});
  if (!session) return res.status(404).json({ error: 'not_found' });
  const channel = session.agoraChannel || `session_${session.id}`;
  const appId = process.env.AGORA_APP_ID || '';
  const appCert = process.env.AGORA_APP_CERT || '';
  const uid = 0;
  const expire = Math.floor(Date.now()/1000) + 3600;
  const token = RtcTokenBuilder.buildTokenWithUid(appId, appCert, channel, uid, RtcRole.PUBLISHER, expire);
  // persist channel if not present
  if (!session.agoraChannel) {
    await prisma.session.update({ where: { id: session.id }, data: { agoraChannel: channel }});
  }
  res.json({ channelName: channel, token, expiresAt: expire });
});

export default router;
