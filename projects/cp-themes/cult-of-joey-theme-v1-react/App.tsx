import React, { useEffect } from 'react';
import { HashRouter, Routes, Route, useLocation } from 'react-router-dom';
import Header from './components/Header';
import Footer from './components/Footer';
import Home from './pages/Home';
import Journal from './pages/Journal';
import Workshops from './pages/Workshops';
import Gallery from './pages/Gallery';
import RVLife from './pages/RVLife';
import Contact from './pages/Contact';
import SinglePost from './pages/SinglePost';

const ScrollToTop = () => {
  const { pathname } = useLocation();
  useEffect(() => {
    window.scrollTo(0, 0);
  }, [pathname]);
  return null;
};

const App: React.FC = () => {
  return (
    <HashRouter>
      <ScrollToTop />
      <div className="flex flex-col min-h-screen font-body selection:bg-primary selection:text-white">
        <Header />
        <main className="flex-grow pt-20">
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/journal" element={<Journal />} />
            <Route path="/journal/:slug" element={<SinglePost />} />
            <Route path="/workshops" element={<Workshops />} />
            <Route path="/gallery" element={<Gallery />} />
            <Route path="/rv-life" element={<RVLife />} />
            <Route path="/contact" element={<Contact />} />
          </Routes>
        </main>
        <Footer />
      </div>
    </HashRouter>
  );
};

export default App;