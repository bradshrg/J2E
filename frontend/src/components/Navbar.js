// src/components/Navbar.jsx
import React from 'react';
import { NavLink } from 'react-router-dom';
import './Navbar.css';

const Navbar = () => {
  return (
    <div className="navbar-container">
      <div className="navbar-links-wrapper">
        <NavLink to="/" className="navbar-link">💦 MAVJHome 💦</NavLink>
        <NavLink to="/TheJourney" className="navbar-link">🌴 TheJourney 🌴</NavLink>
        <NavLink to="/AlignWithUs" className="navbar-link">🎉 AlignWithUs 🎉</NavLink>
        <NavLink to="/MAVJSearch" className="navbar-link">🔎 MAVJSearch 🔎</NavLink>
        <NavLink to="/LiveBroadcast" className="navbar-link">📺 LiveBroadcast 📺</NavLink>
        <NavLink to="/MAVJStore" className="navbar-link">💦 MAVJStore 💦</NavLink>
        <NavLink to="/PodcastVlog" className="navbar-link">🔥 Podcast/Vlog 🔥</NavLink>
        <NavLink to="/VibrationalIntelligence" className="navbar-link">⚛️ VibrationalIntelligence ⚛️</NavLink>
        <NavLink to="/ContactUs" className="navbar-link">☎️ ContactUs ☎️</NavLink>
      </div>
    </div>
  );
};

export default Navbar;