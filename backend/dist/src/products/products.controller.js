"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
const router = (0, express_1.Router)();
router.get('/', async (req, res) => {
    const products = await prisma.product.findMany();
    res.json(products);
});
router.get('/:sku', async (req, res) => {
    const product = await prisma.product.findUnique({ where: { sku: req.params.sku } });
    if (!product)
        return res.status(404).json({ error: 'not_found' });
    res.json(product);
});
router.post('/', async (req, res) => {
    const { sku, name, priceCents, currency, inventory, description } = req.body;
    const p = await prisma.product.create({
        data: { sku, name, priceCents, currency: currency || 'usd', inventory: inventory || 0, description }
    });
    res.json(p);
});
exports.default = router;
//# sourceMappingURL=products.controller.js.map