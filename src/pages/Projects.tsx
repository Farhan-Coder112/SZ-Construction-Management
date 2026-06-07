import React, { useState } from 'react';
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';
import ProjectCard from '../components/ProjectCard';
import Modal from '../components/Modal';
import ProjectForm from '../components/ProjectForm';
import { Plus } from 'lucide-react';

const Projects = () => {
  const [isModalOpen, setIsModalOpen] = useState(false);
  
  const projects = [
    { name: 'City Center Mall', location: 'Downtown, NY', status: 'On Track', progress: 65, dueDate: 'Dec 2024' },
    { name: 'Skyline Apartments', location: 'Brooklyn, NY', status: 'Delayed', progress: 30, dueDate: 'Mar 2025' },
    { name: 'Riverfront Bridge', location: 'Jersey City, NJ', status: 'On Track', progress: 85, dueDate: 'Oct 2024' },
    { name: 'Industrial Park', location: 'Queens, NY', status: 'Completed', progress: 100, dueDate: 'Aug 2024' },
    { name: 'Metro Station Ext', location: 'Bronx, NY', status: 'On Track', progress: 15, dueDate: 'Jun 2025' },
    { name: 'Green Valley School', location: 'Staten Island, NY', status: 'On Track', progress: 45, dueDate: 'Jan 2025' },
  ];

  return (
    <div className="flex h-screen bg-slate-50">
      <Sidebar />
      <main className="flex-1 overflow-y-auto p-8">
        <div className="flex justify-between items-start">
          <Header title="Projects" subtitle="Manage and track all construction projects" />
          <button 
            onClick={() => setIsModalOpen(true)}
            className="bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 hover:bg-blue-700 transition-colors shadow-sm"
          >
            <Plus size={20} />
            <span>New Project</span>
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {projects.map((project, index) => (
            <ProjectCard key={index} {...project as any} />
          ))}
        </div>

        <Modal 
          isOpen={isModalOpen} 
          onClose={() => setIsModalOpen(false)} 
          title="Create New Project"
        >
          <ProjectForm 
            onSubmit={() => setIsModalOpen(false)} 
            onCancel={() => setIsModalOpen(false)} 
          />
        </Modal>
      </main>
    </div>
  );
};

export default Projects;