import { Request, Response, NextFunction } from 'express';
declare global {
    namespace Express {
        interface Request {
            user?: any;
        }
    }
}
export declare function authenticateJWT(req: Request, res: Response, next: NextFunction): Response<any, Record<string, any>>;
export declare function requireAdmin(req: Request, res: Response, next: NextFunction): Response<any, Record<string, any>>;
