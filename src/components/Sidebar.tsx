import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { 
  LayoutDashboard, 
  HardHat, 
  Users, 
  Wallet, 
  Package, 
  FileText, 
  Settings,
  MessageSquare,
  ClipboardCheck,
  Receipt
} from 'lucide-react';

const Sidebar = () => {
  const location = useLocation();
  
  const menuItems = [
    { icon: LayoutDashboard, label: 'Dashboard', path: '/' },
    { icon: HardHat, label: 'Projects', path: '/projects' },
    { icon: MessageSquare, label: 'Daily Updates', path: '/updates' },
    { icon: ClipboardCheck, label: 'Labour Tracking', path: '/labour' },
    { icon: Users, label: 'Workers', path: '/workers' },
    { icon: Receipt, label: 'Expenses', path: '/expenses' },
    { icon: Wallet, label: 'Payments', path: '/payments' },
    { icon: Package, label: 'Inventory', path: '/inventory' },
    { icon: FileText, label: 'Reports', path: '/reports' },
    { icon: Settings, label: 'Settings', path: '/settings' },
  ];

  return (
    <aside className="w-64 bg-slate-900 text-white p-6 hidden md:block h-screen sticky top-0">
      <div className="flex items-center gap-3 mb-10">
        <div className="bg-blue-600 p-2 rounded-lg">
          <HardHat size={24} />
        </div>
        <h1 className="text-xl font-bold">SZ Group</h1>
      </div>
      
      <nav className="space-y-2">
        {menuItems.map((item) => {
          const isActive = location.pathname === item.path;
          return (
            <Link
              key={item.label}
              to={item.path}
              className={`flex items-center gap-3 px-4 py-3 rounded-lg transition-colors ${
                isActive 
                  ? 'bg-blue-600 text-white' 
                  : 'text-slate-400 hover:bg-slate-800 hover:text-white'
              }`}
            >
              <item.icon size={20} />
              <span>{item.label}</span>
            </Link>
          );
        })}
      </nav>
    </aside>
  );
};

export default Sidebar;