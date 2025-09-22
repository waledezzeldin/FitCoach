import { Controller, Post, Req, Res } from '@nestjs/common';
import { Request, Response } from 'express';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY as string, { apiVersion: '2022-11-15' });

@Controller('v1/webhooks/stripe')
export class StripeWebhookController {
  @Post()
  async handleWebhook(@Req() req: Request, @Res() res: Response) {
    const sig = req.headers['stripe-signature'] as string;
    let event: Stripe.Event;
    try {
      event = stripe.webhooks.constructEvent(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET as string);
    } catch (err) {
      const errorMessage = typeof err === 'object' && err !== null && 'message' in err ? (err as { message: string }).message : 'Unknown error';
      res.status(400).send(`Webhook Error: ${errorMessage}`);
      return;
    }
    if (event.type === 'checkout.session.completed') {
      console.log('Checkout success', event.data.object);
    }
    res.json({ received: true });
  }
}