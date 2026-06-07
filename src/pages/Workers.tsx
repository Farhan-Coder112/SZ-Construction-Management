import React from 'react';
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';
import WorkerCard from '../components/WorkerCard';
import { Plus, Search, Filter } from 'lucide-react';

const Workers = () => {
  const workers = [
    { name: 'John Doe', role: 'Site Supervisor', phone: '+1 234 567 890', location: 'Brooklyn, NY', status: 'Active', rating: 4.8 },
    { name: 'Robert Smith', role: 'Senior Mason', phone: '+1 234 567 891', location: 'Queens, NY', status: 'Active', rating: 4.5 },
    { name: 'Michael Brown', role: 'Electrician', phone: '+1 234 567 892', location: 'Bronx, NY', status: 'On Leave', rating: 4.9 },
    { name: 'David Wilson', role: 'Plumber', phone: '+1 234 567 893', location: 'Manhattan, NY', status: 'Active', rating: 4.2 },
    { name: 'James Taylor', role: 'Carpenter', phone: '+1 234 567 894', location: 'Staten Island, NY', status: 'Inactive', rating: 4.0 },
    { name: 'Richard Moore', role: 'Laborer', phone: '+1 234 567 895', location: 'Jersey City, NJ', status: 'Active', rating: 4.6 },
  ];

  return (
    <div className="flex h-screen bg-slate-50">
      <Sidebar />
      <main className="flex-1 overflow-y-auto p-8">
        <div className="flex justify-between items-start mb-6">
          <Header title="Workers" subtitle="Manage your workforce and assignments" />
          <button className="bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 hover:bg-blue-700 transition-colors shadow-sm">
            <Plus size={20} />
            <span>Add Worker</span>
          </button>
        </div>

        <div className="flex flex-col md:flex-row gap-4 mb-8">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
            <input 
              type="text" 
              placeholder="Search workers by name, role or location..." 
              className="w-full pl-10 pr-4 py-2 rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white"
            />
          </div>
          <button className="flex items-center gap-2 px-4 py-2 bg-white border border-slate-200 rounded-lg text-slate-600 hover:bg-slate-50">
            <Filter size={18} />
            <span>Filters</span>
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {workers.map((worker, index) => (
            <WorkerCard key={index} {...worker as any} />
          ))}
        </div>
      </main>
    </div>
  );
};

export default Workers;