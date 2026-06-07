import React from 'react';
import { TrendingUp } from 'lucide-react';

interface HeaderProps {
  title: string;
  subtitle?: string;
}

const Header = ({ title, subtitle }: HeaderProps) => {
  return (
    <header className="flex justify-between items-center mb-8">
      <div>
        <h2 className="text-2xl font-bold text-slate-800">{title}</h2>
        {subtitle && <p className="text-slate-500">{subtitle}</p>}
      </div>
      <div className="flex items-center gap-4">
        <button className="bg-white p-2 rounded-full shadow-sm border border-slate-200 hover:bg-slate-50 transition-colors">
          <TrendingUp size={20} className="text-slate-600" />
        </button>
        <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 font-bold border border-blue-200">
          AD
        </div>
      </div>
    </header>
  );
};

export default Header;