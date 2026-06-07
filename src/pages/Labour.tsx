import React from 'react';
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';
import { Users, Calendar, CheckCircle2, XCircle, Clock, Search, Filter } from 'lucide-react';

const Labour = () => {
  const attendance = [
    { id: 1, name: 'John Doe', role: 'Supervisor', project: 'City Center Mall', status: 'Present', checkIn: '08:00 AM', shift: 'Day' },
    { id: 2, name: 'Robert Smith', role: 'Mason', project: 'City Center Mall', status: 'Present', checkIn: '08:15 AM', shift: 'Day' },
    { id: 3, name: 'Michael Brown', role: 'Electrician', project: 'Skyline Apartments', status: 'Absent', checkIn: '-', shift: 'Day' },
    { id: 4, name: 'David Wilson', role: 'Plumber', project: 'Riverfront Bridge', status: 'Present', checkIn: '08:05 AM', shift: 'Day' },
    { id: 5, name: 'James Taylor', role: 'Carpenter', project: 'City Center Mall', status: 'Late', checkIn: '09:30 AM', shift: 'Day' },
  ];

  return (
    <div className="flex h-screen bg-slate-50">
      <Sidebar />
      <main className="flex-1 overflow-y-auto p-8">
        <Header title="Labour & Attendance" subtitle="Track daily workforce presence and shifts" />

        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="bg-white p-6 rounded-xl border border-slate-100 shadow-sm">
            <p className="text-slate-500 text-sm mb-1">Total Workforce</p>
            <h3 className="text-2xl font-bold text-slate-800">48</h3>
          </div>
          <div className="bg-white p-6 rounded-xl border border-slate-100 shadow-sm">
            <p className="text-green-600 text-sm mb-1 font-medium">Present Today</p>
            <h3 className="text-2xl font-bold text-slate-800">42</h3>
          </div>
          <div className="bg-white p-6 rounded-xl border border-slate-100 shadow-sm">
            <p className="text-red-600 text-sm mb-1 font-medium">Absent</p>
            <h3 className="text-2xl font-bold text-slate-800">4</h3>
          </div>
          <div className="bg-white p-6 rounded-xl border border-slate-100 shadow-sm">
            <p className="text-orange-600 text-sm mb-1 font-medium">Late Arrivals</p>
            <h3 className="text-2xl font-bold text-slate-800">2</h3>
          </div>
        </div>

        <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
          <div className="p-6 border-b border-slate-100 flex flex-col md:flex-row justify-between items-center gap-4">
            <div className="flex items-center gap-4 w-full md:w-auto">
              <div className="relative flex-1 md:w-64">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
                <input 
                  type="text" 
                  placeholder="Search workers..." 
                  className="w-full pl-10 pr-4 py-2 rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
                />
              </div>
              <button className="p-2 border border-slate-200 rounded-lg text-slate-600 hover:bg-slate-50">
                <Filter size={18} />
              </button>
            </div>
            <div className="flex items-center gap-2 text-sm font-semibold text-slate-600 bg-slate-50 px-4 py-2 rounded-lg">
              <Calendar size={16} />
              <span>October 14, 2024</span>
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="bg-slate-50 text-slate-500 text-xs uppercase tracking-wider">
                  <th className="px-6 py-4 font-bold">Worker Name</th>
                  <th className="px-6 py-4 font-bold">Project</th>
                  <th className="px-6 py-4 font-bold">Shift</th>
                  <th className="px-6 py-4 font-bold">Check In</th>
                  <th className="px-6 py-4 font-bold">Status</th>
                  <th className="px-6 py-4 font-bold"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {attendance.map((row) => (
                  <tr key={row.id} className="hover:bg-slate-50/50 transition-colors">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-blue-50 flex items-center justify-center text-blue-600 text-xs font-bold">
                          {row.name.charAt(0)}
                        </div>
                        <div>
                          <p className="font-bold text-slate-800 text-sm">{row.name}</p>
                          <p className="text-xs text-slate-500">{row.role}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 text-sm text-slate-600">{row.project}</td>
                    <td className="px-6 py-4 text-sm text-slate-600">{row.shift}</td>
                    <td className="px-6 py-4 text-sm text-slate-600">{row.checkIn}</td>
                    <td className="px-6 py-4">
                      <span className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold ${
                        row.status === 'Present' ? 'bg-green-100 text-green-700' : 
                        row.status === 'Late' ? 'bg-orange-100 text-orange-700' : 
                        'bg-red-100 text-red-700'
                      }`}>
                        {row.status === 'Present' && <CheckCircle2 size={12} />}
                        {row.status === 'Late' && <Clock size={12} />}
                        {row.status === 'Absent' && <XCircle size={12} />}
                        {row.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <button className="text-blue-600 text-xs font-bold hover:underline">Edit</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </main>
    </div>
  );
};

export default Labour;