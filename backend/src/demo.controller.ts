import { Router, Request, Response } from 'express';
import { availableDemoPersonas, getDemoFixture } from './demo/demo.fixtures';

const router = Router();

router.get('/v1/demo/fixtures', (req: Request, res: Response) => {
  const persona = req.query.persona?.toString() ?? 'user';
  const fixture = getDemoFixture(persona);
  res.json({
    persona,
    availablePersonas: availableDemoPersonas,
    ...fixture,
  });
});

export default router;
