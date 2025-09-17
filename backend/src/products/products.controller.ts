import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
const router = Router();

// list products
router.get('/', async (req, res) => {
  const products = await prisma.product.findMany();
  res.json(products);
});

// get product
router.get('/:sku', async (req, res) => {
  const product = await prisma.product.findUnique({ where: { sku: req.params.sku }});
  if (!product) return res.status(404).json({ error: 'not_found' });
  res.json(product);
});

// admin: create product (protect in real app)
router.post('/', async (req, res) => {
  const { sku, name, priceCents, currency, inventory, description } = req.body;
  const p = await prisma.product.create({
    data: { sku, name, priceCents, currency: currency || 'usd', inventory: inventory || 0, description }
  });
  res.json(p);
});

export default router;
