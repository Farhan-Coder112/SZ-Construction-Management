import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Index from './pages/Index';
import Projects from './pages/Projects';
import Workers from './pages/Workers';
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
          <Route path="/" element={<Index />} />
          <Route path="/projects" element={<Projects />} />
          <Route path="/workers" element={<Workers />} />
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