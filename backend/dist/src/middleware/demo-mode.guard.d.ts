import { NextFunction, Request, Response } from 'express';
declare global {
    namespace Express {
        interface Request {
            isDemoMode?: boolean;
        }
    }
}
type DemoGuardOptions = {
    headerName?: string;
};
export declare const createDemoModeGuard: (options?: DemoGuardOptions) => (req: Request, res: Response, next: NextFunction) => void | Response<any, Record<string, any>>;
export default createDemoModeGuard;
