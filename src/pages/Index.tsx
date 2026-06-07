import React from 'react';
import { 
  LayoutDashboard, 
  HardHat, 
  Users, 
  Wallet, 
  Package, 
  FileText, 
  Settings,
  TrendingUp,
  Clock
} from 'lucide-react';

const Index = () => {
  const stats = [
    { label: 'Active Projects', value: '12', icon: LayoutDashboard, color: 'text-blue-600' },
    { label: 'Total Workers', value: '48', icon: Users, color: 'text-green-600' },
    { label: 'Monthly Expenses', value: '$24,500', icon: Wallet, color: 'text-red-600' },
    { label: 'Pending Tasks', value: '8', icon: Clock, color: 'text-orange-600' },
  ];

  return (
    <div className="flex h-screen bg-slate-50">
      {/* Sidebar */}
      <aside className="w-64 bg-slate-900 text-white p-6 hidden md:block">
        <div className="flex items-center gap-3 mb-10">
          <div className="bg-blue-600 p-2 rounded-lg">
            <HardHat size={24} />
          </div>
          <h1 className="text-xl font-bold">SZ Group</h1>
        </div>
        
        <nav className="space-y-2">
          {[
            { icon: LayoutDashboard, label: 'Dashboard', active: true },
            { icon: HardHat, label: 'Projects' },
            { icon: Users, label: 'Workers' },
            { icon: Wallet, label: 'Payments' },
            { icon: Package, label: 'Inventory' },
            { icon: FileText, label: 'Reports' },
            { icon: Settings, label: 'Settings' },
          ].map((item) => (
            <a
              key={item.label}
              href="#"
              className={`flex items-center gap-3 px-4 py-3 rounded-lg transition-colors ${
                item.active ? 'bg-blue-600 text-white' : 'text-slate-400 hover:bg-slate-800 hover:text-white'
              }`}
            >
              <item.icon size={20} />
              <span>{item.label}</span>
            </a>
          ))}
        </nav>
      </aside>

      {/* Main Content */}
      <main className="flex-1 overflow-y-auto p-8">
        <header className="flex justify-between items-center mb-8">
          <div>
            <h2 className="text-2xl font-bold text-slate-800">Dashboard Overview</h2>
            <p className="text-slate-500">Welcome back, Admin</p>
          </div>
          <div className="flex items-center gap-4">
            <button className="bg-white p-2 rounded-full shadow-sm border border-slate-200">
              <TrendingUp size={20} className="text-slate-600" />
            </button>
            <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 font-bold">
              AD
            </div>
          </div>
        </header>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          {stats.map((stat) => (
            <div key={stat.label} className="bg-white p-6 rounded-xl shadow-sm border border-slate-100">
              <div className="flex justify-between items-start mb-4">
                <div className={`p-2 rounded-lg bg-slate-50 ${stat.color}`}>
                  <stat.icon size={24} />
                </div>
              </div>
              <h3 className="text-slate-500 text-sm font-medium">{stat.label}</h3>
              <p className="text-2xl font-bold text-slate-800 mt-1">{stat.value}</p>
            </div>
          ))}
        </div>

        {/* Recent Activity Placeholder */}
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
                  <p className="text-xs text-slate-400 mt-1">2 hours ago</p>
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