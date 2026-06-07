import React from 'react';
import { 
  LayoutDashboard, 
  Users, 
  Wallet, 
  Clock,
  HardHat
} from 'lucide-react';
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';
import StatCard from '../components/StatCard';

const Index = () => {
  const stats = [
    { label: 'Active Projects', value: '12', icon: LayoutDashboard, color: 'text-blue-600' },
    { label: 'Total Workers', value: '48', icon: Users, color: 'text-green-600' },
    { label: 'Monthly Expenses', value: '$24,500', icon: Wallet, color: 'text-red-600' },
    { label: 'Pending Tasks', value: '8', icon: Clock, color: 'text-orange-600' },
  ];

  return (
    <div className="flex h-screen bg-slate-50">
      <Sidebar />
      <main className="flex-1 overflow-y-auto p-8">
        <Header title="Dashboard Overview" subtitle="Welcome back, Admin" />

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          {stats.map((stat) => (
            <StatCard key={stat.label} {...stat} />
          ))}
        </div>

        <div className="bg-white rounded-xl shadow-sm border border-slate-100 p-6">
          <h3 className="text-lg font-bold text-slate-800 mb-4">Recent Project Updates</h3>
          <div className="space-y-4">
            {[1, 2, 3].map((i) => (
              <div key={i} className="flex items-center gap-4 p-4 rounded-lg border border-slate-50 hover:bg-slate-50 transition-colors">
                <div className="w-12 h-12 rounded bg-slate-100 flex items-center justify-center">
                  <HardHat size={20} className="text-slate-400" />
                </div>
                <div className="flex-1">
                  <h4 className="font-semibold text-slate-800">City Center Mall - Phase {i}</h4>
                  <p className="text-sm text-slate-500">Foundation work completed by Team A</p>
                </div>
                <div className="text-right">
                  <span className="text-xs font-medium px-2 py-1 rounded-full bg-green-100 text-green-700">
                    On Track
                  </span>
                  <p className="text-xs text-slate-400 mt-1">{i * 2} hours ago</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </main>
    </div>
  );
};

export default Index;