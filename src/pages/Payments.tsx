import React, { useState } from 'react';
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';
import Modal from '../components/Modal';
import PaymentForm from '../components/PaymentForm';
import { Wallet, ArrowUpRight, ArrowDownLeft, MoreVertical, Download, Plus } from 'lucide-react';

const Payments = () => {
  const [isModalOpen, setIsModalOpen] = useState(false);

  const transactions = [
    { id: 'TXN-001', project: 'City Center Mall', type: 'Income', amount: '$12,500', date: 'Oct 12, 2024', status: 'Completed' },
    { id: 'TXN-002', project: 'Skyline Apartments', type: 'Expense', amount: '$4,200', date: 'Oct 11, 2024', status: 'Pending' },
    { id: 'TXN-003', project: 'Riverfront Bridge', type: 'Income', amount: '$8,000', date: 'Oct 10, 2024', status: 'Completed' },
    { id: 'TXN-004', project: 'Industrial Park', type: 'Expense', amount: '$1,500', date: 'Oct 09, 2024', status: 'Completed' },
    { id: 'TXN-005', project: 'Metro Station Ext', type: 'Income', amount: '$25,000', date: 'Oct 08, 2024', status: 'Failed' },
  ];

  return (
    <div className="flex h-screen bg-slate-50">
      <Sidebar />
      <main className="flex-1 overflow-y-auto p-8">
        <div className="flex justify-between items-start mb-6">
          <Header title="Payments & Financials" subtitle="Track project budgets and transactions" />
          <button 
            onClick={() => setIsModalOpen(true)}
            className="bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 hover:bg-blue-700 transition-colors shadow-sm"
          >
            <Plus size={20} />
            <span>New Transaction</span>
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="bg-blue-600 text-white p-6 rounded-xl shadow-sm">
            <div className="flex justify-between items-start mb-4">
              <div className="p-2 bg-blue-500 rounded-lg">
                <Wallet size={24} />
              </div>
              <span className="text-xs font-medium bg-blue-500 px-2 py-1 rounded-full">Total Balance</span>
            </div>
            <h3 className="text-3xl font-bold">$142,500.00</h3>
            <p className="text-blue-100 text-sm mt-2">+12.5% from last month</p>
          </div>
          
          <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-100">
            <div className="flex justify-between items-start mb-4">
              <div className="p-2 bg-green-50 rounded-lg text-green-600">
                <ArrowUpRight size={24} />
              </div>
              <span className="text-xs font-medium text-slate-500">Monthly Income</span>
            </div>
            <h3 className="text-3xl font-bold text-slate-800">$45,200.00</h3>
            <p className="text-green-600 text-sm mt-2">8 transactions</p>
          </div>

          <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-100">
            <div className="flex justify-between items-start mb-4">
              <div className="p-2 bg-red-50 rounded-lg text-red-600">
                <ArrowDownLeft size={24} />
              </div>
              <span className="text-xs font-medium text-slate-500">Monthly Expenses</span>
            </div>
            <h3 className="text-3xl font-bold text-slate-800">$20,700.00</h3>
            <p className="text-red-600 text-sm mt-2">14 transactions</p>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-sm border border-slate-100 overflow-hidden">
          <div className="p-6 border-b border-slate-100 flex justify-between items-center">
            <h3 className="text-lg font-bold text-slate-800">Recent Transactions</h3>
            <button className="flex items-center gap-2 text-sm text-blue-600 font-medium hover:underline">
              <Download size={16} />
              Export CSV
            </button>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="bg-slate-50 text-slate-500 text-sm uppercase tracking-wider">
                  <th className="px-6 py-4 font-semibold">Transaction ID</th>
                  <th className="px-6 py-4 font-semibold">Project</th>
                  <th className="px-6 py-4 font-semibold">Type</th>
                  <th className="px-6 py-4 font-semibold">Amount</th>
                  <th className="px-6 py-4 font-semibold">Date</th>
                  <th className="px-6 py-4 font-semibold">Status</th>
                  <th className="px-6 py-4 font-semibold"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {transactions.map((txn) => (
                  <tr key={txn.id} className="hover:bg-slate-50 transition-colors">
                    <td className="px-6 py-4 font-medium text-slate-800">{txn.id}</td>
                    <td className="px-6 py-4 text-slate-600">{txn.project}</td>
                    <td className="px-6 py-4">
                      <span className={`flex items-center gap-1 ${txn.type === 'Income' ? 'text-green-600' : 'text-red-600'}`}>
                        {txn.type === 'Income' ? <ArrowUpRight size={14} /> : <ArrowDownLeft size={14} />}
                        {txn.type}
                      </span>
                    </td>
                    <td className="px-6 py-4 font-bold text-slate-800">{txn.amount}</td>
                    <td className="px-6 py-4 text-slate-500">{txn.date}</td>
                    <td className="px-6 py-4">
                      <span className={`text-xs font-medium px-2 py-1 rounded-full ${
                        txn.status === 'Completed' ? 'bg-green-100 text-green-700' : 
                        txn.status === 'Pending' ? 'bg-orange-100 text-orange-700' : 
                        'bg-red-100 text-red-700'
                      }`}>
                        {txn.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <button className="text-slate-400 hover:text-slate-600">
                        <MoreVertical size={18} />
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
          title="Record New Transaction"
        >
          <PaymentForm 
            onSubmit={() => setIsModalOpen(false)} 
            onCancel={() => setIsModalOpen(false)} 
          />
        </Modal>
      </main>
    </div>
  );
};

export default Payments;