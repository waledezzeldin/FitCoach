"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
router.get('/', async (req, res) => {
    try {
        const bundles = await prisma.bundle.findMany({ include: { products: true } });
        res.json(bundles);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to fetch bundles.' });
    }
});
exports.default = router;
//# sourceMappingURL=bundles.controller.js.map