import swaggerUi from 'swagger-ui-express';
import swaggerJsdoc from 'swagger-jsdoc';

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'FitCoach+ API',
      version: '1.0.0',
    },
  },
  apis: ['./src/**/*.ts'], // Path to your API files
};

const swaggerSpec = swaggerJsdoc(options);

export { swaggerUi, swaggerSpec };