"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createDemoModeGuard = void 0;
const DEMO_HEADER = 'x-demo-mode';
const READ_METHODS = new Set(['GET', 'HEAD', 'OPTIONS']);
const WRITE_ALLOWLIST = ['/v1/payments', '/v1/notifications'];
const createDemoModeGuard = (options = {}) => {
    const header = (options.headerName ?? DEMO_HEADER).toLowerCase();
    return (req, res, next) => {
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
exports.createDemoModeGuard = createDemoModeGuard;
exports.default = exports.createDemoModeGuard;
//# sourceMappingURL=demo-mode.guard.js.map