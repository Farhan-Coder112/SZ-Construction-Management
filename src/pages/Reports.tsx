import React from 'react';
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';
import { FileText, Download, Calendar, PieChart, BarChart3, TrendingUp } from 'lucide-react';

const Reports = () => {
  const reportTypes = [
    { title: 'Financial Summary', description: 'Monthly income, expenses and profit analysis', icon: TrendingUp, color: 'bg-blue-50 text-blue-600' },
    { title: 'Project Progress', description: 'Detailed status of all active construction projects', icon: BarChart3, color: 'bg-green-50 text-green-600' },
    { title: 'Labour Attendance', description: 'Worker hours, shifts and wage distribution', icon: PieChart, color: 'bg-purple-50 text-purple-600' },
    { title: 'Inventory Usage', description: 'Material consumption and stock replenishment', icon: FileText, color: 'bg-orange-50 text-orange-600' },
  ];

  const recentReports = [
    { name: 'Q3 Financial Report.pdf', date: 'Oct 12, 2024', size: '2.4 MB', type: 'PDF' },
    { name: 'September Labour Log.xlsx', date: 'Oct 05, 2024', size: '1.1 MB', type: 'Excel' },
    { name: 'City Center Mall Progress.pdf', date: 'Sep 28, 2024', size: '4.8 MB', type: 'PDF' },
    { name: 'Inventory Audit - Sep.pdf', date: 'Sep 25, 2024', size: '1.5 MB', type: 'PDF' },
  ];

  return (
    <div className="flex h-screen bg-slate-50">
      <Sidebar />
      <main className="flex-1 overflow-y-auto p-8">
        <Header title="Reports & Analytics" subtitle="Generate and download business insights" />

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-10">
          {reportTypes.map((report) => (
            <div key={report.title} className="bg-white p-6 rounded-xl shadow-sm border border-slate-100 hover:shadow-md transition-shadow cursor-pointer group">
              <div className="flex items-start gap-4">
                <div className={`p-4 rounded-xl ${report.color} group-hover:scale-110 transition-transform`}>
                  <report.icon size={28} />
                </div>
                <div className="flex-1">
                  <h3 className="text-lg font-bold text-slate-800 mb-1">{report.title}</h3>
                  <p className="text-slate-500 text-sm mb-4">{report.description}</p>
                  <button className="flex items-center gap-2 text-blue-600 text-sm font-semibold hover:underline">
                    Generate Report
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>

        <div className="bg-white rounded-xl shadow-sm border border-slate-100 overflow-hidden">
          <div className="p-6 border-b border-slate-100 flex justify-between items-center">
            <h3 className="text-lg font-bold text-slate-800">Recent Generated Reports</h3>
            <div className="flex items-center gap-2 text-slate-400 text-sm">
              <Calendar size={16} />
              <span>Last 30 days</span>
            </div>
          </div>
          <div className="divide-y divide-slate-100">
            {recentReports.map((report, index) => (
              <div key={index} className="p-4 flex items-center justify-between hover:bg-slate-50 transition-colors">
                <div className="flex items-center gap-4">
                  <div className="w-10 h-10 rounded bg-slate-100 flex items-center justify-center text-slate-400">
                    <FileText size={20} />
                  </div>
                  <div>
                    <h4 className="font-medium text-slate-800">{report.name}</h4>
                    <p className="text-xs text-slate-500">{report.date} • {report.size}</p>
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <span className={`text-[10px] font-bold px-2 py-0.5 rounded ${
                    report.type === 'PDF' ? 'bg-red-50 text-red-600' : 'bg-green-50 text-green-600'
                  }`}>
                    {report.type}
                  </span>
                  <button className="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors">
                    <Download size={18} />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </main>
    </div>
  );
};

export default Reports;