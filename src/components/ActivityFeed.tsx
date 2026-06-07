import React from 'react';
import { HardHat, Wallet, Users, Package } from 'lucide-react';

const ActivityFeed = () => {
  const activities = [
    { id: 1, type: 'project', text: 'City Center Mall - Phase 2 started', time: '2 hours ago', icon: HardHat, color: 'bg-blue-50 text-blue-600' },
    { id: 2, type: 'payment', text: 'Received $12,500 from Skyline Apartments', time: '4 hours ago', icon: Wallet, color: 'bg-green-50 text-green-600' },
    { id: 3, type: 'worker', text: 'New worker "Robert Smith" added to team', time: 'Yesterday', icon: Users, color: 'bg-purple-50 text-purple-600' },
    { id: 4, type: 'inventory', text: 'Cement stock reached low level (450 bags)', time: 'Yesterday', icon: Package, color: 'bg-orange-50 text-orange-600' },
  ];

  return (
    <div className="bg-white rounded-xl shadow-sm border border-slate-100 p-6">
      <h3 className="text-lg font-bold text-slate-800 mb-6">Recent Activity</h3>
      <div className="space-y-6">
        {activities.map((activity) => (
          <div key={activity.id} className="flex gap-4">
            <div className={`p-2 rounded-lg h-fit ${activity.color}`}>
              <activity.icon size={18} />
            </div>
            <div>
              <p className="text-sm font-medium text-slate-800">{activity.text}</p>
              <p className="text-xs text-slate-400 mt-1">{activity.time}</p>
            </div>
          </div>
        ))}
      </div>
      <button className="w-full mt-6 py-2 text-sm font-semibold text-blue-600 hover:bg-blue-50 rounded-lg transition-colors">
        View All Activity
      </button>
    </div>
  );
};

export default ActivityFeed;