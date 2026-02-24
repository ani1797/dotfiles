// ags/.config/ags/config.js

const { App } = await Service.import('app');

// Import services
import './services/wallpaper.js';

// Basic configuration
App.config({
  style: './styles/main.css',
  windows: [],
});

console.log('AGS Material You Shell initialized');
