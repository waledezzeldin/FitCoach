"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const stripe_1 = require("stripe");
const router = (0, express_1.Router)();
const stripe = new stripe_1.default(process.env.STRIPE_SECRET_KEY || '', { apiVersion: '2024-08-01' });
router.post('/stripe', (req, res) => {
    const event = req.body;
    console.log('stripe webhook', event.type);
    res.json({ received: true });
});
exports.default = router;
//# sourceMappingURL=webhooks.controller.js.map