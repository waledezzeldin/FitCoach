import { Request, Response } from 'express';
export declare class StripeWebhookController {
    handleWebhook(req: Request, res: Response): Promise<void>;
}
