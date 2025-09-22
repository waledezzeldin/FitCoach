"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
router.get('/', async (req, res) => {
    try {
        const affiliates = await prisma.affiliate.findMany();
        res.json(affiliates);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to fetch affiliates.' });
    }
});
router.post('/', async (req, res) => {
    try {
        const { name, referralCode, brandUrl } = req.body;
        const affiliate = await prisma.affiliate.create({
            data: { name, referralCode, brandUrl }
        });
        res.status(201).json(affiliate);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to create affiliate.' });
    }
});
exports.default = router;
//# sourceMappingURL=affiliate.controller.js.map