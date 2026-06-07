import React from 'react';
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';
import { Plus, Calendar, MessageSquare, Camera, User, HardHat } from 'lucide-react';

const DailyUpdates = () => {
  const updates = [
    {
      id: 1,
      project: 'City Center Mall',
      user: 'Alex Johnson',
      time: '10:30 AM',
      date: 'Oct 14, 2024',
      content: 'Foundation pouring for Sector B completed. Inspection scheduled for tomorrow morning.',
      images: 3,
      category: 'Progress'
    },
    {
      id: 2,
      project: 'Skyline Apartments',
      user: 'Sarah Miller',
      time: '09:15 AM',
      date: 'Oct 14, 2024',
      content: 'Material delivery delayed due to traffic. Steel rods expected by 2 PM.',
      images: 1,
      category: 'Issue'
    },
    {
      id: 3,
      project: 'Riverfront Bridge',
      user: 'Mike Ross',
      time: '04:45 PM',
      date: 'Oct 13, 2024',
      content: 'Welding work on the main span is 80% complete. Safety protocols being strictly followed.',
      images: 5,
      category: 'Progress'
    }
  ];

  return (
    <div className="flex h-screen bg-slate-50">
      <Sidebar />
      <main className="flex-1 overflow-y-auto p-8">
        <div className="flex justify-between items-start mb-8">
          <Header title="Daily Site Updates" subtitle="Real-time logs from all active construction sites" />
          <button className="bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 hover:bg-blue-700 transition-colors shadow-sm">
            <Plus size={20} />
            <span>Post Update</span>
          </button>
        </div>

        <div className="max-w-3xl space-y-6">
          {updates.map((update) => (
            <div key={update.id} className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
              <div className="p-6">
                <div className="flex justify-between items-start mb-4">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center text-slate-600">
                      <User size={20} />
                    </div>
                    <div>
                      <h4 className="font-bold text-slate-800">{update.user}</h4>
                      <div className="flex items-center gap-2 text-xs text-slate-400">
                        <Calendar size={12} />
                        <span>{update.date} • {update.time}</span>
                      </div>
                    </div>
                  </div>
                  <span className={`text-[10px] font-bold px-2 py-1 rounded-full uppercase tracking-wider ${
                    update.category === 'Issue' ? 'bg-red-50 text-red-600' : 'bg-blue-50 text-blue-600'
                  }`}>
                    {update.category}
                  </span>
                </div>

                <div className="flex items-center gap-2 mb-3 text-blue-600 font-semibold text-sm">
                  <HardHat size={16} />
                  <span>{update.project}</span>
                </div>

                <p className="text-slate-600 leading-relaxed mb-6">
                  {update.content}
                </p>

                <div className="flex items-center gap-6 pt-4 border-t border-slate-50">
                  <button className="flex items-center gap-2 text-slate-400 hover:text-blue-600 transition-colors text-sm font-medium">
                    <Camera size={18} />
                    <span>{update.images} Photos</span>
                  </button>
                  <button className="flex items-center gap-2 text-slate-400 hover:text-blue-600 transition-colors text-sm font-medium">
                    <MessageSquare size={18} />
                    <span>Add Comment</span>
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </main>
    </div>
  );
};

export default DailyUpdates;