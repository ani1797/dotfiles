// ags/.config/ags/config.js

const { App } = await Service.import('app');

// Import services
import './services/wallpaper.js';

// Import widgets
import Shelf from './widgets/shelf/Shelf.js';

// Basic configuration
App.config({
  style: './styles/main.css',
  windows: [Shelf()],
});

console.log('AGS Material You Shell initialized');
