import React from 'react';
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';
import { User, Bell, Shield, Globe, CreditCard, LogOut } from 'lucide-react';

const Settings = () => {
  const sections = [
    {
      title: 'Profile Settings',
      icon: User,
      items: [
        { label: 'Personal Information', description: 'Update your name, email and phone number' },
        { label: 'Profile Picture', description: 'Change your public profile image' },
      ]
    },
    {
      title: 'Notifications',
      icon: Bell,
      items: [
        { label: 'Email Notifications', description: 'Manage which emails you receive' },
        { label: 'Push Notifications', description: 'Configure alerts for your desktop' },
      ]
    },
    {
      title: 'Security',
      icon: Shield,
      items: [
        { label: 'Password', description: 'Change your account password' },
        { label: 'Two-Factor Authentication', description: 'Add an extra layer of security' },
      ]
    },
    {
      title: 'System',
      icon: Globe,
      items: [
        { label: 'Language & Region', description: 'Set your preferred language and timezone' },
        { label: 'Appearance', description: 'Switch between light and dark mode' },
      ]
    }
  ];

  return (
    <div className="flex h-screen bg-slate-50">
      <Sidebar />
      <main className="flex-1 overflow-y-auto p-8">
        <Header title="Settings" subtitle="Manage your account and application preferences" />

        <div className="max-w-4xl space-y-6">
          {sections.map((section) => (
            <div key={section.title} className="bg-white rounded-xl shadow-sm border border-slate-100 overflow-hidden">
              <div className="p-6 border-b border-slate-100 flex items-center gap-3">
                <div className="p-2 bg-slate-50 rounded-lg text-slate-600">
                  <section.icon size={20} />
                </div>
                <h3 className="text-lg font-bold text-slate-800">{section.title}</h3>
              </div>
              <div className="divide-y divide-slate-50">
                {section.items.map((item) => (
                  <button 
                    key={item.label} 
                    className="w-full p-6 flex items-center justify-between hover:bg-slate-50 transition-colors text-left group"
                  >
                    <div>
                      <h4 className="font-semibold text-slate-800 group-hover:text-blue-600 transition-colors">{item.label}</h4>
                      <p className="text-sm text-slate-500">{item.description}</p>
                    </div>
                    <div className="text-slate-300 group-hover:text-slate-400">
                      <Globe size={20} className="rotate-90" />
                    </div>
                  </button>
                ))}
              </div>
            </div>
          ))}

          <div className="pt-4">
            <button className="flex items-center gap-2 text-red-600 font-semibold hover:bg-red-50 px-4 py-2 rounded-lg transition-colors">
              <LogOut size={20} />
              <span>Sign Out of Account</span>
            </button>
          </div>
        </div>
      </main>
    </div>
  );
};

export default Settings;