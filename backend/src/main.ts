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

dotenv.config();
const app = express();
app.use(bodyParser.json());

const stripeWebhookRouter = require('./api/stripeWebhook');
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

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Backend listening on ${port}`));

