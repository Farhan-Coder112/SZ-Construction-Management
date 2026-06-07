import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Index from './pages/Index';
import Projects from './pages/Projects';
import Workers from './pages/Workers';
import Payments from './pages/Payments';
import Inventory from './pages/Inventory';
import Reports from './pages/Reports';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Index />} />
        <Route path="/projects" element={<Projects />} />
        <Route path="/workers" element={<Workers />} />
        <Route path="/payments" element={<Payments />} />
        <Route path="/inventory" element={<Inventory />} />
        <Route path="/reports" element={<Reports />} />
      </Routes>
    </Router>
  );
}

export default App;