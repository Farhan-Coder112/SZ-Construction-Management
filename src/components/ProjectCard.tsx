import React from 'react';
import { HardHat, Calendar, MapPin } from 'lucide-react';

interface ProjectCardProps {
  name: string;
  location: string;
  status: 'On Track' | 'Delayed' | 'Completed';
  progress: number;
  dueDate: string;
}

const ProjectCard = ({ name, location, status, progress, dueDate }: ProjectCardProps) => {
  const statusColors = {
    'On Track': 'bg-green-100 text-green-700',
    'Delayed': 'bg-red-100 text-red-700',
    'Completed': 'bg-blue-100 text-blue-700',
  };

  return (
    <div className="bg-white rounded-xl shadow-sm border border-slate-100 p-6 hover:shadow-md transition-shadow">
      <div className="flex justify-between items-start mb-4">
        <div className="w-12 h-12 rounded-lg bg-slate-100 flex items-center justify-center">
          <HardHat size={24} className="text-slate-600" />
        </div>
        <span className={`text-xs font-medium px-2.5 py-1 rounded-full ${statusColors[status]}`}>
          {status}
        </span>
      </div>
      
      <h3 className="text-lg font-bold text-slate-800 mb-1">{name}</h3>
      <div className="flex items-center gap-2 text-slate-500 text-sm mb-4">
        <MapPin size={14} />
        <span>{location}</span>
      </div>

      <div className="space-y-2 mb-4">
        <div className="flex justify-between text-sm">
          <span className="text-slate-500">Progress</span>
          <span className="font-semibold text-slate-800">{progress}%</span>
        </div>
        <div className="w-full bg-slate-100 rounded-full h-2">
          <div 
            className="bg-blue-600 h-2 rounded-full transition-all duration-500" 
            style={{ width: `${progress}%` }}
          />
        </div>
      </div>

      <div className="flex items-center gap-2 text-slate-400 text-xs pt-4 border-t border-slate-50">
        <Calendar size={14} />
        <span>Due: {dueDate}</span>
      </div>
    </div>
  );
};

export default ProjectCard;