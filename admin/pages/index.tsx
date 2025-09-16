import axios from 'axios'
import { useEffect, useState } from 'react'

export default function AdminDashboard() {
  const [metrics, setMetrics] = useState<any>(null)
  useEffect(() => { axios.get('/api/admin/metrics').then(r => setMetrics(r.data)) }, [])
  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold">Admin Dashboard</h1>
      <div className="grid grid-cols-3 gap-4 mt-6">
        <div className="p-4 bg-white rounded shadow">Users: {metrics?.users}</div>
        <div className="p-4 bg-white rounded shadow">MRR: ${metrics?.mrr}</div>
        <div className="p-4 bg-white rounded shadow">Active Sessions: {metrics?.activeSessions}</div>
      </div>
    </div>
  )
}