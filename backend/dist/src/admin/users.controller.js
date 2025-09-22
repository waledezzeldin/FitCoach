"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
router.get('/', async (req, res) => {
    try {
        const users = await prisma.user.findMany({
            select: { id: true, email: true, name: true, phone: true, createdAt: true }
        });
        res.json(users);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to fetch users.' });
    }
});
router.put('/:id', async (req, res) => {
    try {
        const { name, phone } = req.body;
        const user = await prisma.user.update({
            where: { id: req.params.id },
            data: { name, phone }
        });
        res.json({ id: user.id, email: user.email, name: user.name, phone: user.phone });
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to update user.' });
    }
});
router.delete('/:id', async (req, res) => {
    try {
        await prisma.user.delete({ where: { id: req.params.id } });
        res.json({ message: 'User deleted.' });
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to delete user.' });
    }
});
exports.default = router;
//# sourceMappingURL=users.controller.js.map