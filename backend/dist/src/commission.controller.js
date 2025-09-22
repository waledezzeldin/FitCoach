"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
router.get('/', async (req, res) => {
    try {
        const { coachId, affiliateId } = req.query;
        let commissions = [];
        if (coachId) {
            commissions = await prisma.commission.findMany({ where: { coachId: String(coachId) } });
        }
        else if (affiliateId) {
            commissions = await prisma.commission.findMany({ where: { affiliateId: String(affiliateId) } });
        }
        else {
            commissions = await prisma.commission.findMany();
        }
        res.json(commissions);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to fetch commissions.' });
    }
});
exports.default = router;
//# sourceMappingURL=commission.controller.js.map