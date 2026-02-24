// ags/.config/ags/utils/colorExtractor.ts

import { argbFromHex, themeFromSourceColor, hexFromArgb, Scheme } from '@material/material-color-utilities';
import ColorThief from 'colorthief';
import sharp from 'sharp';
import { readFile, stat } from 'fs/promises';
import { createHash } from 'crypto';
import type { MaterialYouTheme, ColorScheme } from '../types/material-you';

export class ColorExtractor {
  private cache = new Map<string, MaterialYouTheme>();

  async extractFromWallpaper(imagePath: string): Promise<MaterialYouTheme> {
    // Check cache
    const hash = await this.getImageHash(imagePath);
    if (this.cache.has(hash)) {
      console.log(`[ColorExtractor] Using cached colors for ${imagePath}`);
      return this.cache.get(hash)!;
    }

    console.log(`[ColorExtractor] Extracting colors from ${imagePath}`);

    // Extract dominant color
    const dominantColor = await this.getDominantColor(imagePath);
    console.log(`[ColorExtractor] Dominant color: ${dominantColor}`);

    // Generate Material You theme
    const sourceArgb = argbFromHex(dominantColor);
    const theme = themeFromSourceColor(sourceArgb);

    // Convert to our format
    const materialTheme = this.convertTheme(theme, dominantColor);

    // Cache result
    this.cache.set(hash, materialTheme);

    return materialTheme;
  }

  private async getDominantColor(imagePath: string): Promise<string> {
    try {
      // Resize image for faster processing
      const buffer = await sharp(imagePath)
        .resize(100, 100, { fit: 'cover' })
        .toBuffer();

      const colorThief = new ColorThief();
      const [r, g, b] = await colorThief.getColor(buffer);

      return `#${r.toString(16).padStart(2, '0')}${g.toString(16).padStart(2, '0')}${b.toString(16).padStart(2, '0')}`;
    } catch (error) {
      console.error('[ColorExtractor] Failed to extract color:', error);
      // Fallback to Material You blue
      return '#4285f4';
    }
  }

  private convertTheme(theme: any, source: string): MaterialYouTheme {
    const dark = theme.schemes.dark;
    const light = theme.schemes.light;

    return {
      dark: this.convertScheme(dark, source),
      light: this.convertScheme(light, source),
    };
  }

  private convertScheme(scheme: Scheme, source: string): ColorScheme {
    return {
      source,
      primary: hexFromArgb(scheme.primary),
      onPrimary: hexFromArgb(scheme.onPrimary),
      primaryContainer: hexFromArgb(scheme.primaryContainer),
      onPrimaryContainer: hexFromArgb(scheme.onPrimaryContainer),
      secondary: hexFromArgb(scheme.secondary),
      onSecondary: hexFromArgb(scheme.onSecondary),
      secondaryContainer: hexFromArgb(scheme.secondaryContainer),
      onSecondaryContainer: hexFromArgb(scheme.onSecondaryContainer),
      tertiary: hexFromArgb(scheme.tertiary),
      onTertiary: hexFromArgb(scheme.onTertiary),
      tertiaryContainer: hexFromArgb(scheme.tertiaryContainer),
      onTertiaryContainer: hexFromArgb(scheme.onTertiaryContainer),
      error: hexFromArgb(scheme.error),
      onError: hexFromArgb(scheme.onError),
      errorContainer: hexFromArgb(scheme.errorContainer),
      onErrorContainer: hexFromArgb(scheme.onErrorContainer),
      background: hexFromArgb(scheme.background),
      onBackground: hexFromArgb(scheme.onBackground),
      surface: hexFromArgb(scheme.surface),
      onSurface: hexFromArgb(scheme.onSurface),
      surfaceVariant: hexFromArgb(scheme.surfaceVariant),
      onSurfaceVariant: hexFromArgb(scheme.onSurfaceVariant),
      surfaceDim: hexFromArgb(scheme.surfaceDim),
      surfaceBright: hexFromArgb(scheme.surfaceBright),
      surfaceContainerLowest: hexFromArgb(scheme.surfaceContainerLowest),
      surfaceContainerLow: hexFromArgb(scheme.surfaceContainerLow),
      surfaceContainer: hexFromArgb(scheme.surfaceContainer),
      surfaceContainerHigh: hexFromArgb(scheme.surfaceContainerHigh),
      surfaceContainerHighest: hexFromArgb(scheme.surfaceContainerHighest),
      outline: hexFromArgb(scheme.outline),
      outlineVariant: hexFromArgb(scheme.outlineVariant),
      inverseSurface: hexFromArgb(scheme.inverseSurface),
      inverseOnSurface: hexFromArgb(scheme.inverseOnSurface),
      inversePrimary: hexFromArgb(scheme.inversePrimary),
      scrim: hexFromArgb(scheme.scrim),
      shadow: hexFromArgb(scheme.shadow),
    };
  }

  private async getImageHash(imagePath: string): Promise<string> {
    const stats = await stat(imagePath);
    const hash = createHash('md5')
      .update(`${imagePath}-${stats.mtimeMs}`)
      .digest('hex');
    return hash;
  }

  clearCache(): void {
    this.cache.clear();
    console.log('[ColorExtractor] Cache cleared');
  }
}
