import React from 'react';
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';
import { Plus, Search, Filter, Receipt, ArrowDownLeft, Calendar, MoreVertical } from 'lucide-react';

const Expenses = () => {
  const expenses = [
    { id: 'EXP-001', category: 'Materials', project: 'City Center Mall', amount: '$4,500', date: 'Oct 14, 2024', status: 'Approved', vendor: 'BuildRight Supplies' },
    { id: 'EXP-002', category: 'Labour', project: 'Skyline Apartments', amount: '$1,200', date: 'Oct 13, 2024', status: 'Pending', vendor: 'Daily Wages' },
    { id: 'EXP-003', category: 'Equipment', project: 'Riverfront Bridge', amount: '$850', date: 'Oct 12, 2024', status: 'Approved', vendor: 'HeavyRent Corp' },
    { id: 'EXP-004', category: 'Utilities', project: 'Industrial Park', amount: '$320', date: 'Oct 10, 2024', status: 'Approved', vendor: 'City Power' },
    { id: 'EXP-005', category: 'Materials', project: 'Metro Station Ext', amount: '$2,100', date: 'Oct 08, 2024', status: 'Rejected', vendor: 'SteelCo' },
  ];

  return (
    <div className="flex h-screen bg-slate-50">
      <Sidebar />
      <main className="flex-1 overflow-y-auto p-8">
        <div className="flex justify-between items-start mb-6">
          <Header title="Expense Management" subtitle="Track and approve project-related costs" />
          <button className="bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 hover:bg-blue-700 transition-colors shadow-sm">
            <Plus size={20} />
            <span>Add Expense</span>
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="bg-white p-6 rounded-xl border border-slate-100 shadow-sm">
            <div className="flex items-center gap-4">
              <div className="p-3 bg-red-50 rounded-lg text-red-600">
                <ArrowDownLeft size={24} />
              </div>
              <div>
                <p className="text-sm text-slate-500">Total Expenses (MTD)</p>
                <h3 className="text-2xl font-bold text-slate-800">$12,450.00</h3>
              </div>
            </div>
          </div>
          <div className="bg-white p-6 rounded-xl border border-slate-100 shadow-sm">
            <div className="flex items-center gap-4">
              <div className="p-3 bg-orange-50 rounded-lg text-orange-600">
                <Receipt size={24} />
              </div>
              <div>
                <p className="text-sm text-slate-500">Pending Approval</p>
                <h3 className="text-2xl font-bold text-slate-800">8 Items</h3>
              </div>
            </div>
          </div>
          <div className="bg-white p-6 rounded-xl border border-slate-100 shadow-sm">
            <div className="flex items-center gap-4">
              <div className="p-3 bg-blue-50 rounded-lg text-blue-600">
                <Calendar size={24} />
              </div>
              <div>
                <p className="text-sm text-slate-500">Next Audit Date</p>
                <h3 className="text-2xl font-bold text-slate-800">Oct 30</h3>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
          <div className="p-6 border-b border-slate-100 flex flex-col md:flex-row justify-between items-center gap-4">
            <div className="relative flex-1 w-full md:w-auto">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
              <input 
                type="text" 
                placeholder="Search by vendor, project or category..." 
                className="w-full pl-10 pr-4 py-2 rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
              />
            </div>
            <button className="flex items-center gap-2 px-4 py-2 border border-slate-200 rounded-lg text-slate-600 hover:bg-slate-50 text-sm">
              <Filter size={18} />
              <span>Filters</span>
            </button>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="bg-slate-50 text-slate-500 text-xs uppercase tracking-wider">
                  <th className="px-6 py-4 font-bold">Expense ID</th>
                  <th className="px-6 py-4 font-bold">Category</th>
                  <th className="px-6 py-4 font-bold">Project</th>
                  <th className="px-6 py-4 font-bold">Vendor</th>
                  <th className="px-6 py-4 font-bold">Amount</th>
                  <th className="px-6 py-4 font-bold">Status</th>
                  <th className="px-6 py-4 font-bold"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {expenses.map((exp) => (
                  <tr key={exp.id} className="hover:bg-slate-50/50 transition-colors">
                    <td className="px-6 py-4 text-sm font-medium text-slate-800">{exp.id}</td>
                    <td className="px-6 py-4">
                      <span className="text-sm font-semibold text-slate-700">{exp.category}</span>
                    </td>
                    <td className="px-6 py-4 text-sm text-slate-600">{exp.project}</td>
                    <td className="px-6 py-4 text-sm text-slate-600">{exp.vendor}</td>
                    <td className="px-6 py-4 text-sm font-bold text-slate-800">{exp.amount}</td>
                    <td className="px-6 py-4">
                      <span className={`text-[10px] font-bold px-2 py-1 rounded-full uppercase tracking-wider ${
                        exp.status === 'Approved' ? 'bg-green-100 text-green-700' : 
                        exp.status === 'Pending' ? 'bg-orange-100 text-orange-700' : 
                        'bg-red-100 text-red-700'
                      }`}>
                        {exp.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <button className="text-slate-400 hover:text-slate-600">
                        <MoreVertical size={18} />
                      </button>
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

export default Expenses;