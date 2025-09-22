import { Controller, Post, Req, Res } from '@nestjs/common';
import Stripe from 'stripe';
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, { apiVersion: '2022-11-15' });


@Controller('webhooks')
export class WebhooksController {
@Post('stripe')
async stripe(@Req() req: any, @Res() res: any) {
const sig = req.headers['stripe-signature'];
try {
const event = stripe.webhooks.constructEvent(req.rawBody, sig, process.env.STRIPE_WEBHOOK_SECRET!);
// idempotent handling
if (event.type === 'payment_intent.succeeded') {
// mark order paid
}
res.json({ received: true });
} catch (e) {
res.status(400).send(`Webhook error: ${(e as Error).message}`);
}
}
}