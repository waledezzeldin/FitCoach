import type { NextApiRequest, NextApiResponse } from 'next'
import axios from 'axios'
export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const token = process.env.ADMIN_API_KEY || ''
  try {
    const r = await axios.get((process.env.BACKEND_URL || 'http://localhost:3000') + '/v1/admin/metrics', { headers: { Authorization: `Bearer ${token}` } })
    res.status(r.status).json(r.data)
  } catch (e:any) {
    res.status(500).json({ error: e.message })
  }
}
