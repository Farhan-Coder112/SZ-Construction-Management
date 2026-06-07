import React from 'react';

interface ProjectFormProps {
  onSubmit: (data: any) => void;
  onCancel: () => void;
}

const ProjectForm = ({ onSubmit, onCancel }: ProjectFormProps) => {
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // In a real app, we'd collect form data here
    onSubmit({});
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label className="block text-sm font-semibold text-slate-700 mb-1">Project Name</label>
        <input 
          type="text" 
          placeholder="e.g. City Center Mall"
          className="w-full px-4 py-2 rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
          required
        />
      </div>
      <div>
        <label className="block text-sm font-semibold text-slate-700 mb-1">Location</label>
        <input 
          type="text" 
          placeholder="e.g. Downtown, NY"
          className="w-full px-4 py-2 rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
          required
        />
      </div>
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-semibold text-slate-700 mb-1">Budget</label>
          <input 
            type="text" 
            placeholder="$0.00"
            className="w-full px-4 py-2 rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
        <div>
          <label className="block text-sm font-semibold text-slate-700 mb-1">Due Date</label>
          <input 
            type="date" 
            className="w-full px-4 py-2 rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
      </div>
      <div>
        <label className="block text-sm font-semibold text-slate-700 mb-1">Description</label>
        <textarea 
          rows={3}
          placeholder="Project details..."
          className="w-full px-4 py-2 rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>
      <div className="flex gap-3 pt-4">
        <button 
          type="button"
          onClick={onCancel}
          className="flex-1 px-4 py-2 border border-slate-200 text-slate-600 font-semibold rounded-lg hover:bg-slate-50 transition-colors"
        >
          Cancel
        </button>
        <button 
          type="submit"
          className="flex-1 px-4 py-2 bg-blue-600 text-white font-semibold rounded-lg hover:bg-blue-700 transition-colors shadow-lg shadow-blue-100"
        >
          Create Project
        </button>
      </div>
    </form>
  );
};

export default ProjectForm;