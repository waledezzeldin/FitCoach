import { NextFunction, Request, Response } from 'express';

const DEMO_HEADER = 'x-demo-mode';
const READ_METHODS = new Set(['GET', 'HEAD', 'OPTIONS']);
const WRITE_ALLOWLIST = ['/v1/payments', '/v1/notifications'];

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

/**
 * Blocks mutating requests whenever the demo header is present.
 * Ensures the backend stays read-only while the mobile app showcases demo personas.
 */
export const createDemoModeGuard = (options: DemoGuardOptions = {}) => {
  const header = (options.headerName ?? DEMO_HEADER).toLowerCase();
  return (req: Request, res: Response, next: NextFunction) => {
    const demoFlag = req.headers[header];
    const isDemo = Boolean(demoFlag);
    req.isDemoMode = isDemo;
    res.locals.isDemoMode = isDemo;

    if (!isDemo) {
      return next();
    }

    res.setHeader('X-Demo-Mode', '1');
    if (READ_METHODS.has(req.method.toUpperCase())) {
      return next();
    }

    const path = req.path ?? req.originalUrl ?? '';
    const isAllowedWrite = WRITE_ALLOWLIST.some((prefix) => path.startsWith(prefix));
    if (isAllowedWrite) {
      return next();
    }

    return res.status(403).json({
      error: 'Demo environment is read-only. Please repeat this action in a non-demo session.',
    });
  };
};

export default createDemoModeGuard;
