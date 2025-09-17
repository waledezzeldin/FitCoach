import express from 'express';
import dotenv from 'dotenv';
import bodyParser from 'body-parser';
import mediaRouter from './media.controller';
import webhooksRouter from './webhooks.controller';
import recommendationsRouter from './recommendations.controller';
import productsRouter from './products/products.controller';
import ordersRouter from './orders/orders.controller';
import paymentsWebhook from './payments/webhook.controller';
import sessionsRouter from './sessions/sessions.controller';
import usersRouter from './users.controller';
import coachesRouter from './coaches.controller';
import progressRouter from './progress.controller';
import notificationsRouter from './notifications.controller';
import milestonesRouter from './milestones.controller';
import deliveryRouter from './delivery.controller';
import affiliateRouter from './affiliate.controller';
import commissionRouter from './commission.controller';
import subscriptionRouter from './subscription.controller';
import paymentsRouter from './payments.controller';
import adminUsersRouter from './admin/users.controller';
import bundlesRouter from './products/bundles.controller';
import categoriesRouter from './products/categories.controller';
import usersDeviceTokenRouter from './users.device-token.controller';
import { swaggerUi, swaggerSpec } from './swagger';
import rateLimit from 'express-rate-limit';
import csrf from 'csurf';

dotenv.config();
const app = express();
app.use(bodyParser.json());

const stripeWebhookRouter = require('./api/stripeWebhook');
import { Request, Response, NextFunction } from 'express';
app.use('/api/stripe', stripeWebhookRouter);

app.use('/v1/media', mediaRouter);
app.use('/v1/webhooks', webhooksRouter);
app.use('/v1/recommendations', recommendationsRouter);
app.use('/v1/products', productsRouter);
app.use('/v1/orders', ordersRouter);
app.use('/v1/webhooks', paymentsWebhook);
app.use('/v1/sessions', sessionsRouter);
app.use('/v1/users', usersRouter);
app.use('/v1/coaches', coachesRouter);
app.use('/v1/progress', progressRouter);
app.use('/v1/notifications', notificationsRouter);
app.use('/v1/milestones', milestonesRouter);
app.use('/v1/delivery', deliveryRouter);
app.use('/v1/affiliate', affiliateRouter);
app.use('/v1/commission', commissionRouter);
app.use('/v1/subscription', subscriptionRouter);
app.use('/v1/payments', paymentsRouter);
app.use('/v1/admin/users', adminUsersRouter);
app.use('/v1/products/bundles', bundlesRouter);
app.use('/v1/products/categories', categoriesRouter);
app.use('/v1/users', usersDeviceTokenRouter);
app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Apply rate limiting middleware
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
});
app.use(limiter);

// For example, if you have web routes:
// app.use(csrf());
// For APIs, you may skip or use a token-based approach.

// Global error handler (add this at the end, before app.listen)
interface ErrorWithStatus extends Error {
    status?: number;
}


app.use((err: ErrorWithStatus, req: Request, res: Response, next: NextFunction) => {
    console.error(err.stack);
    res.status(err.status || 500).json({ error: err.message || 'Internal Server Error' });
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Backend listening on ${port}`));

export default app;

