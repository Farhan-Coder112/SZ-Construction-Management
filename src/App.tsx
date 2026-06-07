import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Index from './pages/Index';
import Login from './pages/Login';
import Projects from './pages/Projects';
import ProjectDetails from './pages/ProjectDetails';
import DailyUpdates from './pages/DailyUpdates';
import Labour from './pages/Labour';
import Workers from './pages/Workers';
import Expenses from './pages/Expenses';
import Payments from './pages/Payments';
import Inventory from './pages/Inventory';
import Reports from './pages/Reports';
import Settings from './pages/Settings';
import MobileNav from './components/MobileNav';

function App() {
  return (
    <Router>
      <div className="flex flex-col md:flex-row min-h-screen">
        <MobileNav />
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/" element={<Index />} />
          <Route path="/projects" element={<Projects />} />
          <Route path="/projects/:id" element={<ProjectDetails />} />
          <Route path="/updates" element={<DailyUpdates />} />
          <Route path="/labour" element={<Labour />} />
          <Route path="/workers" element={<Workers />} />
          <Route path="/expenses" element={<Expenses />} />
          <Route path="/payments" element={<Payments />} />
          <Route path="/inventory" element={<Inventory />} />
          <Route path="/reports" element={<Reports />} />
          <Route path="/settings" element={<Settings />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;