"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
const router = (0, express_1.Router)();
router.post('/:id/approve', async (req, res) => {
    try {
        const requestId = req.params.id;
        const coachRequest = await prisma.coachRequest.update({
            where: { id: requestId },
            data: { status: 'approved' }
        });
        await prisma.user.update({
            where: { id: coachRequest.userId },
            data: { role: 'coach' }
        });
        res.json({ success: true });
    }
    catch (err) {
        res.status(500).json({ error: 'Approval failed.' });
    }
});
exports.default = router;
//# sourceMappingURL=coach_requests.controller.js.map