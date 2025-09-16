import { Router } from 'express';
import { RtcTokenBuilder, RtcRole } from 'agora-access-token';

const router = Router();

router.post('/token', (req, res) => {
  const channel = req.body.channel || `ch_${Date.now()}`;
  const appId = process.env.AGORA_APP_ID || 'APPID';
  const appCert = process.env.AGORA_APP_CERT || 'APPCERT';
  const uid = 0;
  const expire = Math.floor(Date.now()/1000) + 3600;
  try {
    const token = RtcTokenBuilder.buildTokenWithUid(appId, appCert, channel, uid, RtcRole.PUBLISHER, expire);
    res.json({ channel, token, expiresAt: expire });
  } catch (e) {
    res.status(500).json({ error: 'token_error', message: (e as Error).message });
  }
});

export default router;
