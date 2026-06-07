import React from 'react';
import { useParams, Link } from 'react-router-dom';
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';
import { 
  ArrowLeft, 
  Calendar, 
  MapPin, 
  Users, 
  Clock, 
  CheckCircle2, 
  AlertCircle,
  FileText,
  Camera
} from 'lucide-react';

const ProjectDetails = () => {
  const { id } = useParams();

  // Mock data for the project
  const project = {
    name: 'City Center Mall',
    location: 'Downtown, NY',
    status: 'On Track',
    progress: 65,
    startDate: 'Jan 15, 2024',
    dueDate: 'Dec 20, 2024',
    manager: 'Alex Johnson',
    teamSize: 24,
    budget: '$2.4M',
    spent: '$1.2M',
    description: 'Construction of a 5-story commercial complex including underground parking and rooftop garden.',
    milestones: [
      { name: 'Foundation & Piling', status: 'Completed', date: 'Mar 10' },
      { name: 'Structural Framework', status: 'Completed', date: 'Jun 15' },
      { name: 'Electrical & Plumbing', status: 'In Progress', date: 'Aug 20' },
      { name: 'Interior Finishing', status: 'Pending', date: 'Oct 05' },
    ]
  };

  return (
    <div className="flex h-screen bg-slate-50">
      <Sidebar />
      <main className="flex-1 overflow-y-auto p-8">
        <Link to="/projects" className="flex items-center gap-2 text-slate-500 hover:text-blue-600 mb-6 transition-colors">
          <ArrowLeft size={20} />
          <span>Back to Projects</span>
        </Link>

        <div className="flex flex-col lg:flex-row gap-8">
          <div className="flex-1 space-y-8">
            <div className="bg-white rounded-2xl p-8 shadow-sm border border-slate-100">
              <div className="flex justify-between items-start mb-6">
                <div>
                  <h1 className="text-3xl font-bold text-slate-900 mb-2">{project.name}</h1>
                  <div className="flex items-center gap-4 text-slate-500">
                    <div className="flex items-center gap-1">
                      <MapPin size={16} />
                      <span>{project.location}</span>
                    </div>
                    <div className="flex items-center gap-1">
                      <Calendar size={16} />
                      <span>Started {project.startDate}</span>
                    </div>
                  </div>
                </div>
                <span className="px-4 py-1.5 rounded-full bg-green-100 text-green-700 font-semibold text-sm">
                  {project.status}
                </span>
              </div>

              <div className="grid grid-cols-2 md:grid-cols-4 gap-6 py-6 border-y border-slate-50">
                <div>
                  <p className="text-slate-400 text-xs uppercase font-bold tracking-wider mb-1">Budget</p>
                  <p className="text-lg font-bold text-slate-800">{project.budget}</p>
                </div>
                <div>
                  <p className="text-slate-400 text-xs uppercase font-bold tracking-wider mb-1">Spent</p>
                  <p className="text-lg font-bold text-slate-800">{project.spent}</p>
                </div>
                <div>
                  <p className="text-slate-400 text-xs uppercase font-bold tracking-wider mb-1">Team Size</p>
                  <p className="text-lg font-bold text-slate-800">{project.teamSize} Workers</p>
                </div>
                <div>
                  <p className="text-slate-400 text-xs uppercase font-bold tracking-wider mb-1">Manager</p>
                  <p className="text-lg font-bold text-slate-800">{project.manager}</p>
                </div>
              </div>

              <div className="mt-8">
                <h3 className="font-bold text-slate-800 mb-3">Project Description</h3>
                <p className="text-slate-600 leading-relaxed">{project.description}</p>
              </div>
            </div>

            <div className="bg-white rounded-2xl p-8 shadow-sm border border-slate-100">
              <h3 className="font-bold text-slate-800 mb-6">Project Milestones</h3>
              <div className="space-y-6">
                {project.milestones.map((m, i) => (
                  <div key={i} className="flex items-center gap-4">
                    <div className={`w-10 h-10 rounded-full flex items-center justify-center ${
                      m.status === 'Completed' ? 'bg-green-50 text-green-600' : 
                      m.status === 'In Progress' ? 'bg-blue-50 text-blue-600' : 'bg-slate-50 text-slate-400'
                    }`}>
                      {m.status === 'Completed' ? <CheckCircle2 size={20} /> : <Clock size={20} />}
                    </div>
                    <div className="flex-1">
                      <h4 className="font-semibold text-slate-800">{m.name}</h4>
                      <p className="text-sm text-slate-500">{m.status}</p>
                    </div>
                    <div className="text-right">
                      <p className="text-sm font-medium text-slate-800">{m.date}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          <div className="w-full lg:w-80 space-y-6">
            <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-100">
              <h3 className="font-bold text-slate-800 mb-4 text-center">Overall Progress</h3>
              <div className="relative w-32 h-32 mx-auto mb-4">
                <svg className="w-full h-full" viewBox="0 0 36 36">
                  <path
                    className="text-slate-100"
                    strokeDasharray="100, 100"
                    strokeWidth="3"
                    stroke="currentColor"
                    fill="none"
                    d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                  />
                  <path
                    className="text-blue-600"
                    strokeDasharray={`${project.progress}, 100`}
                    strokeWidth="3"
                    strokeLinecap="round"
                    stroke="currentColor"
                    fill="none"
                    d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                  />
                </svg>
                <div className="absolute inset-0 flex items-center justify-center">
                  <span className="text-2xl font-bold text-slate-800">{project.progress}%</span>
                </div>
              </div>
              <p className="text-center text-sm text-slate-500">Estimated completion: Dec 2024</p>
            </div>

            <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-100">
              <h3 className="font-bold text-slate-800 mb-4">Quick Actions</h3>
              <div className="space-y-3">
                <button className="w-full flex items-center gap-3 p-3 rounded-xl bg-slate-50 hover:bg-blue-50 hover:text-blue-600 transition-colors text-slate-600 font-medium">
                  <Camera size={18} />
                  <span>Upload Site Photos</span>
                </button>
                <button className="w-full flex items-center gap-3 p-3 rounded-xl bg-slate-50 hover:bg-blue-50 hover:text-blue-600 transition-colors text-slate-600 font-medium">
                  <FileText size={18} />
                  <span>Generate Report</span>
                </button>
                <button className="w-full flex items-center gap-3 p-3 rounded-xl bg-slate-50 hover:bg-blue-50 hover:text-blue-600 transition-colors text-slate-600 font-medium">
                  <Users size={18} />
                  <span>Manage Team</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};

export default ProjectDetails;