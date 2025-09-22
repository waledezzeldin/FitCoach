"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
router.post('/device-token', async (req, res) => {
    try {
        const { userId, deviceToken } = req.body;
        await prisma.user.update({
            where: { id: userId },
            data: { deviceToken }
        });
        res.json({ success: true });
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to save device token.' });
    }
});
exports.default = router;
//# sourceMappingURL=users.device-token.controller.js.map