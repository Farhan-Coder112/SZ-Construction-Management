import React from 'react';
import { 
  LayoutDashboard, 
  Users, 
  Wallet, 
  Clock,
  HardHat,
  TrendingUp
} from 'lucide-react';
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';
import StatCard from '../components/StatCard';
import ActivityFeed from '../components/ActivityFeed';

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

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <div className="lg:col-span-2 space-y-8">
            <div className="bg-white rounded-xl shadow-sm border border-slate-100 p-6">
              <div className="flex justify-between items-center mb-6">
                <h3 className="text-lg font-bold text-slate-800">Project Progress Overview</h3>
                <div className="flex items-center gap-2 text-xs font-semibold text-green-600 bg-green-50 px-2 py-1 rounded">
                  <TrendingUp size={14} />
                  <span>+12% this month</span>
                </div>
              </div>
              <div className="space-y-4">
                {[1, 2, 3].map((i) => (
                  <div key={i} className="flex items-center gap-4 p-4 rounded-lg border border-slate-50 hover:bg-slate-50 transition-colors">
                    <div className="w-12 h-12 rounded bg-slate-100 flex items-center justify-center">
                      <HardHat size={20} className="text-slate-400" />
                    </div>
                    <div className="flex-1">
                      <h4 className="font-semibold text-slate-800">City Center Mall - Phase {i}</h4>
                      <div className="w-full bg-slate-100 rounded-full h-1.5 mt-2">
                        <div className="bg-blue-600 h-1.5 rounded-full" style={{ width: `${40 + i * 15}%` }} />
                      </div>
                    </div>
                    <div className="text-right">
                      <span className="text-xs font-bold text-slate-800">{40 + i * 15}%</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          <div className="lg:col-span-1">
            <ActivityFeed />
          </div>
        </div>
      </main>
    </div>
  );
};

export default Index;