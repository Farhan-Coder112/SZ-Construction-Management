import React from 'react';

interface PaymentFormProps {
  onSubmit: (data: any) => void;
  onCancel: () => void;
}

const PaymentForm = ({ onSubmit, onCancel }: PaymentFormProps) => {
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit({});
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label className="block text-sm font-semibold text-slate-700 mb-1">Project</label>
        <select className="w-full px-4 py-2 rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white">
          <option>City Center Mall</option>
          <option>Skyline Apartments</option>
          <option>Riverfront Bridge</option>
          <option>Industrial Park</option>
        </select>
      </div>
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-semibold text-slate-700 mb-1">Transaction Type</label>
          <select className="w-full px-4 py-2 rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white">
            <option>Income (Client Payment)</option>
            <option>Expense (Vendor/Labour)</option>
          </select>
        </div>
        <div>
          <label className="block text-sm font-semibold text-slate-700 mb-1">Amount</label>
          <input 
            type="number" 
            placeholder="0.00"
            className="w-full px-4 py-2 rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
            required
          />
        </div>
      </div>
      <div>
        <label className="block text-sm font-semibold text-slate-700 mb-1">Payment Method</label>
        <select className="w-full px-4 py-2 rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white">
          <option>Bank Transfer</option>
          <option>Cash</option>
          <option>Cheque</option>
          <option>Online Payment</option>
        </select>
      </div>
      <div>
        <label className="block text-sm font-semibold text-slate-700 mb-1">Notes / Description</label>
        <textarea 
          rows={2}
          placeholder="Transaction details..."
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
          Record Transaction
        </button>
      </div>
    </form>
  );
};

export default PaymentForm;