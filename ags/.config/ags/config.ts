// ags/.config/ags/config.ts

import { App } from 'resource:///com/github/Aylur/ags/app.js';

// Import services (auto-initialize as singletons)
import './services/wallpaper.js';

// Basic configuration
App.config({
  style: './styles/main.css',
  windows: [],
});

console.log('AGS Material You Shell initialized');
