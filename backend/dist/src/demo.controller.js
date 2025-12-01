"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const demo_fixtures_1 = require("./demo/demo.fixtures");
const router = (0, express_1.Router)();
router.get('/v1/demo/fixtures', (req, res) => {
    const persona = req.query.persona?.toString() ?? 'user';
    const fixture = (0, demo_fixtures_1.getDemoFixture)(persona);
    res.json({
        persona,
        availablePersonas: demo_fixtures_1.availableDemoPersonas,
        ...fixture,
    });
});
exports.default = router;
//# sourceMappingURL=demo.controller.js.map