import React from 'react';
import { User, Phone, MapPin, BadgeCheck } from 'lucide-react';

interface WorkerCardProps {
  name: string;
  role: string;
  phone: string;
  location: string;
  status: 'Active' | 'On Leave' | 'Inactive';
  rating: number;
}

const WorkerCard = ({ name, role, phone, location, status, rating }: WorkerCardProps) => {
  const statusColors = {
    'Active': 'bg-green-100 text-green-700',
    'On Leave': 'bg-orange-100 text-orange-700',
    'Inactive': 'bg-slate-100 text-slate-700',
  };

  return (
    <div className="bg-white rounded-xl shadow-sm border border-slate-100 p-6 hover:shadow-md transition-shadow">
      <div className="flex justify-between items-start mb-4">
        <div className="w-12 h-12 rounded-full bg-blue-50 flex items-center justify-center text-blue-600">
          <User size={24} />
        </div>
        <span className={`text-xs font-medium px-2.5 py-1 rounded-full ${statusColors[status]}`}>
          {status}
        </span>
      </div>
      
      <h3 className="text-lg font-bold text-slate-800 mb-1">{name}</h3>
      <p className="text-blue-600 text-sm font-medium mb-4">{role}</p>

      <div className="space-y-2 mb-6">
        <div className="flex items-center gap-2 text-slate-500 text-sm">
          <Phone size={14} />
          <span>{phone}</span>
        </div>
        <div className="flex items-center gap-2 text-slate-500 text-sm">
          <MapPin size={14} />
          <span>{location}</span>
        </div>
      </div>

      <div className="flex items-center justify-between pt-4 border-t border-slate-50">
        <div className="flex items-center gap-1">
          <BadgeCheck size={16} className="text-blue-500" />
          <span className="text-sm font-semibold text-slate-700">{rating}/5.0</span>
        </div>
        <button className="text-blue-600 text-sm font-medium hover:underline">
          View Profile
        </button>
      </div>
    </div>
  );
};

export default WorkerCard;