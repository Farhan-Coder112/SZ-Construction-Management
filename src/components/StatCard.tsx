import React from 'react';
import { LucideIcon } from 'lucide-react';

interface StatCardProps {
  label: string;
  value: string;
  icon: LucideIcon;
  color: string;
}

const StatCard = ({ label, value, icon: Icon, color }: StatCardProps) => {
  return (
    <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-100 hover:shadow-md transition-shadow">
      <div className="flex justify-between items-start mb-4">
        <div className={`p-2 rounded-lg bg-slate-50 ${color}`}>
          <Icon size={24} />
        </div>
      </div>
      <h3 className="text-slate-500 text-sm font-medium">{label}</h3>
      <p className="text-2xl font-bold text-slate-800 mt-1">{value}</p>
    </div>
  );
};

export default StatCard;