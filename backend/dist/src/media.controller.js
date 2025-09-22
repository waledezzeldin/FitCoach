"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const agora_access_token_1 = require("agora-access-token");
const router = (0, express_1.Router)();
router.post('/token', (req, res) => {
    const channel = req.body.channel || `ch_${Date.now()}`;
    const appId = process.env.AGORA_APP_ID || 'APPID';
    const appCert = process.env.AGORA_APP_CERT || 'APPCERT';
    const uid = 0;
    const expire = Math.floor(Date.now() / 1000) + 3600;
    try {
        const token = agora_access_token_1.RtcTokenBuilder.buildTokenWithUid(appId, appCert, channel, uid, agora_access_token_1.RtcRole.PUBLISHER, expire);
        res.json({ channel, token, expiresAt: expire });
    }
    catch (e) {
        res.status(500).json({ error: 'token_error', message: e.message });
    }
});
exports.default = router;
//# sourceMappingURL=media.controller.js.map