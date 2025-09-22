"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.swaggerSpec = exports.swaggerUi = void 0;
const swagger_ui_express_1 = require("swagger-ui-express");
exports.swaggerUi = swagger_ui_express_1.default;
const swagger_jsdoc_1 = require("swagger-jsdoc");
const options = {
    definition: {
        openapi: '3.0.0',
        info: {
            title: 'FitCoach+ API',
            version: '1.0.0',
        },
    },
    apis: ['./src/**/*.ts'],
};
const swaggerSpec = (0, swagger_jsdoc_1.default)(options);
exports.swaggerSpec = swaggerSpec;
//# sourceMappingURL=swagger.js.map