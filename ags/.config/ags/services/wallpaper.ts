// ags/.config/ags/services/wallpaper.ts

import GLib from 'gi://GLib';
import { exec, execAsync } from 'resource:///com/github/Aylur/ags/utils.js';
import { Service } from 'resource:///com/github/Aylur/ags/service.js';
import { ColorExtractor } from '../utils/colorExtractor.js';
import { ColorExport } from '../utils/colorExport.js';
import type { MaterialYouTheme } from '../types/material-you';

class WallpaperService extends Service {
  static {
    Service.register(
      this,
      {
        'wallpaper-changed': ['string'],
        'colors-generated': ['jsobject'],
      },
      {
        'current-wallpaper': ['string', 'r'],
        'current-colors': ['jsobject', 'r'],
      }
    );
  }

  private _currentWallpaper = '';
  private _currentColors: MaterialYouTheme | null = null;
  private _wallpaperDir = `${GLib.get_home_dir()}/.config/wallpapers`;
  private _rotationInterval = 3600000; // 1 hour
  private _rotationTimer: number | null = null;
  private _isDark = true;
  private _settingWallpaper = false;
  private _syncScript: string;

  private colorExtractor = new ColorExtractor();
  private colorExport: ColorExport;

  get current_wallpaper() {
    return this._currentWallpaper;
  }

  get current_colors() {
    return this._currentColors;
  }

  constructor() {
    super();

    const configDir = `${GLib.get_home_dir()}/.config/ags`;
    this._syncScript = `${configDir}/scripts/sync-colors.sh`;
    this.colorExport = new ColorExport(configDir);

    // Initialize
    this.init();
  }

  private async init() {
    try {
      // Ensure wallpaper directory exists
      await execAsync(`mkdir -p "${this._wallpaperDir}"`);

      // Set initial wallpaper
      await this.rotateWallpaper();

      // Start rotation timer
      this.startRotation();
    } catch (error) {
      console.error('[WallpaperService] Init failed:', error);
    }
  }

  async setWallpaper(path: string): Promise<void> {
    if (this._settingWallpaper) {
      console.warn('[WallpaperService] Already setting wallpaper, ignoring call');
      return;
    }

    this._settingWallpaper = true;
    try {
      console.log(`[WallpaperService] Setting wallpaper: ${path}`);

      // Set via hyprpaper
      await execAsync(`hyprctl hyprpaper preload "${path}"`);
      await execAsync(`hyprctl hyprpaper wallpaper ",${path}"`);

      this._currentWallpaper = path;
      this.emit('wallpaper-changed', path);
      this.notify('current-wallpaper');

      // Extract and apply colors
      await this.updateColors(path);
    } catch (error) {
      console.error('[WallpaperService] Failed to set wallpaper:', error);
    } finally {
      this._settingWallpaper = false;
    }
  }

  private async updateColors(wallpaperPath: string): Promise<void> {
    try {
      console.log('[WallpaperService] Extracting colors...');
      const colors = await this.colorExtractor.extractFromWallpaper(wallpaperPath);

      this._currentColors = colors;
      this.emit('colors-generated', colors);
      this.notify('current-colors');

      // Export to all formats
      const scheme = this._isDark ? colors.dark : colors.light;
      await this.colorExport.exportAll(scheme, this._isDark);

      // Sync to other applications
      await this.syncColors();
    } catch (error) {
      console.error('[WallpaperService] Color extraction failed:', error);
    }
  }

  private async syncColors(): Promise<void> {
    try {
      await execAsync(this._syncScript);
      console.log('[WallpaperService] Colors synced to system');
    } catch (error) {
      console.error('[WallpaperService] Sync failed:', error);
    }
  }

  private startRotation(): void {
    if (this._rotationTimer) {
      GLib.source_remove(this._rotationTimer);
    }

    this._rotationTimer = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, this._rotationInterval / 1000, () => {
      this.rotateWallpaper().catch(err => {
        console.error('[WallpaperService] Timer rotation failed:', err);
      });
      return true; // Continue timer
    });
  }

  stop(): void {
    if (this._rotationTimer) {
      GLib.source_remove(this._rotationTimer);
      this._rotationTimer = null;
      console.log('[WallpaperService] Rotation stopped');
    }
  }

  private async rotateWallpaper(): Promise<void> {
    try {
      const wallpapers = await this.getWallpapers();

      if (wallpapers.length === 0) {
        console.warn('[WallpaperService] No wallpapers found');
        return;
      }

      // Pick random wallpaper (excluding current)
      const available = wallpapers.filter(w => w !== this._currentWallpaper);
      if (available.length === 0) {
        return; // Only one wallpaper
      }

      const next = available[Math.floor(Math.random() * available.length)];
      await this.setWallpaper(next);
    } catch (error) {
      console.error('[WallpaperService] Rotation failed:', error);
    }
  }

  private async getWallpapers(): Promise<string[]> {
    try {
      const output = await execAsync(
        `find "${this._wallpaperDir}" -type f \\( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \\)`
      );
      return output.split('\n').filter(Boolean);
    } catch (error) {
      console.error('[WallpaperService] Failed to list wallpapers:', error);
      return [];
    }
  }

  async setDarkMode(isDark: boolean): Promise<void> {
    if (this._isDark === isDark) return;

    this._isDark = isDark;

    // Re-export colors with new mode
    if (this._currentColors) {
      try {
        const scheme = isDark ? this._currentColors.dark : this._currentColors.light;
        await this.colorExport.exportAll(scheme, isDark);
        await this.syncColors();
        console.log(`[WallpaperService] Switched to ${isDark ? 'dark' : 'light'} mode`);
      } catch (error) {
        console.error('[WallpaperService] Failed to apply dark mode:', error);
      }
    }
  }
}

export default new WallpaperService();
