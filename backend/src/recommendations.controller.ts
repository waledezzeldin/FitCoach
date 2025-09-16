import { Router } from 'express';
const router = Router();

router.post('/', (req, res) => {
  const userId = req.body.user_id || null;
  // Simple rule-based sample recommendations
  const recs = [
    { id: 'supp-001', title: 'Whey Protein', score: 0.92, reason: 'High-protein goal' },
    { id: 'supp-002', title: 'Creatine', score: 0.84, reason: 'Strength focus' }
  ];
  res.json({ user_id: userId, recommendations: recs, model_version: 'rule-v0' });
});

export default router;
