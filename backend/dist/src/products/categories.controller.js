"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
router.get('/', async (req, res) => {
    try {
        const categories = await prisma.category.findMany({ include: { products: true } });
        res.json(categories);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to fetch categories.' });
    }
});
exports.default = router;
//# sourceMappingURL=categories.controller.js.map