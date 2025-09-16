import express from 'express';
import dotenv from 'dotenv';
import bodyParser from 'body-parser';
import mediaRouter from './media.controller';
import webhooksRouter from './webhooks.controller';
import recommendationsRouter from './recommendations.controller';

dotenv.config();
const app = express();
app.use(bodyParser.json());

app.use('/v1/media', mediaRouter);
app.use('/v1/webhooks', webhooksRouter);
app.use('/v1/recommendations', recommendationsRouter);

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Backend listening on ${port}`));
