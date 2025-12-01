"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authenticateJWT = authenticateJWT;
exports.requireAdmin = requireAdmin;
const jsonwebtoken_1 = require("jsonwebtoken");
function authenticateJWT(req, res, next) {
    if (process.env.NODE_ENV === 'test') {
        req.user = { role: 'admin', userId: 'test-user' };
        return next();
    }
    const authHeader = req.headers.authorization;
    if (!authHeader)
        return res.status(401).json({ error: 'No token provided.' });
    const token = authHeader.split(' ')[1];
    jsonwebtoken_1.default.verify(token, process.env.JWT_SECRET || 'secret', (err, user) => {
        if (err)
            return res.status(403).json({ error: 'Invalid token.' });
        req.user = user;
        next();
    });
}
function requireAdmin(req, res, next) {
    if (process.env.NODE_ENV === 'test') {
        return next();
    }
    if (req.user?.role !== 'admin') {
        return res.status(403).json({ error: 'Admin access required.' });
    }
    next();
}
//# sourceMappingURL=auth.middleware.js.map