import React, { useState } from 'react';
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';
import Modal from '../components/Modal';
import InventoryForm from '../components/InventoryForm';
import { Plus, Search, Filter, Package, AlertTriangle, CheckCircle2 } from 'lucide-react';

const Inventory = () => {
  const [isModalOpen, setIsModalOpen] = useState(false);

  const inventoryItems = [
    { id: 'INV-001', name: 'Cement (50kg)', category: 'Materials', stock: 450, unit: 'Bags', status: 'In Stock' },
    { id: 'INV-002', name: 'Steel Rods (12mm)', category: 'Materials', stock: 120, unit: 'Tons', status: 'Low Stock' },
    { id: 'INV-003', name: 'Bricks', category: 'Materials', stock: 15000, unit: 'Units', status: 'In Stock' },
    { id: 'INV-004', name: 'Sand', category: 'Materials', stock: 45, unit: 'Trucks', status: 'In Stock' },
    { id: 'INV-005', name: 'Paint (White)', category: 'Finishing', stock: 5, unit: 'Buckets', status: 'Out of Stock' },
    { id: 'INV-006', name: 'Electrical Wire (2.5mm)', category: 'Electrical', stock: 25, unit: 'Rolls', status: 'Low Stock' },
  ];

  return (
    <div className="flex h-screen bg-slate-50">
      <Sidebar />
      <main className="flex-1 overflow-y-auto p-8">
        <div className="flex justify-between items-start mb-6">
          <Header title="Inventory Management" subtitle="Track materials and equipment stock" />
          <button 
            onClick={() => setIsModalOpen(true)}
            className="bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 hover:bg-blue-700 transition-colors shadow-sm"
          >
            <Plus size={20} />
            <span>Add Item</span>
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-100">
            <div className="flex items-center gap-4">
              <div className="p-3 bg-blue-50 rounded-lg text-blue-600">
                <Package size={24} />
              </div>
              <div>
                <p className="text-sm text-slate-500">Total Items</p>
                <h3 className="text-2xl font-bold text-slate-800">1,240</h3>
              </div>
            </div>
          </div>
          <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-100">
            <div className="flex items-center gap-4">
              <div className="p-3 bg-orange-50 rounded-lg text-orange-600">
                <AlertTriangle size={24} />
              </div>
              <div>
                <p className="text-sm text-slate-500">Low Stock</p>
                <h3 className="text-2xl font-bold text-slate-800">12</h3>
              </div>
            </div>
          </div>
          <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-100">
            <div className="flex items-center gap-4">
              <div className="p-3 bg-green-50 rounded-lg text-green-600">
                <CheckCircle2 size={24} />
              </div>
              <div>
                <p className="text-sm text-slate-500">In Stock</p>
                <h3 className="text-2xl font-bold text-slate-800">1,180</h3>
              </div>
            </div>
          </div>
        </div>

        <div className="flex flex-col md:flex-row gap-4 mb-8">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
            <input 
              type="text" 
              placeholder="Search inventory by name or category..." 
              className="w-full pl-10 pr-4 py-2 rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white"
            />
          </div>
          <button className="flex items-center gap-2 px-4 py-2 bg-white border border-slate-200 rounded-lg text-slate-600 hover:bg-slate-50">
            <Filter size={18} />
            <span>Filters</span>
          </button>
        </div>

        <div className="bg-white rounded-xl shadow-sm border border-slate-100 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="bg-slate-50 text-slate-500 text-sm uppercase tracking-wider">
                  <th className="px-6 py-4 font-semibold">Item ID</th>
                  <th className="px-6 py-4 font-semibold">Item Name</th>
                  <th className="px-6 py-4 font-semibold">Category</th>
                  <th className="px-6 py-4 font-semibold">Stock Level</th>
                  <th className="px-6 py-4 font-semibold">Status</th>
                  <th className="px-6 py-4 font-semibold"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {inventoryItems.map((item) => (
                  <tr key={item.id} className="hover:bg-slate-50 transition-colors">
                    <td className="px-6 py-4 font-medium text-slate-800">{item.id}</td>
                    <td className="px-6 py-4 text-slate-800 font-semibold">{item.name}</td>
                    <td className="px-6 py-4 text-slate-600">{item.category}</td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <span className="font-bold text-slate-800">{item.stock}</span>
                        <span className="text-slate-400 text-sm">{item.unit}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <span className={`text-xs font-medium px-2 py-1 rounded-full ${
                        item.status === 'In Stock' ? 'bg-green-100 text-green-700' : 
                        item.status === 'Low Stock' ? 'bg-orange-100 text-orange-700' : 
                        'bg-red-100 text-red-700'
                      }`}>
                        {item.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <button className="text-blue-600 hover:underline text-sm font-medium">
                        Update
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        <Modal 
          isOpen={isModalOpen} 
          onClose={() => setIsModalOpen(false)} 
          title="Add Inventory Item"
        >
          <InventoryForm 
            onSubmit={() => setIsModalOpen(false)} 
            onCancel={() => setIsModalOpen(false)} 
          />
        </Modal>
      </main>
    </div>
  );
};

export default Inventory;