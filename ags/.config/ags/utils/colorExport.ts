// ags/.config/ags/utils/colorExport.ts

import { writeFile, mkdir } from 'fs/promises';
import { dirname } from 'path';
import type { ColorScheme, ColorExports } from '../types/material-you';

export class ColorExport {
  private configDir: string;

  constructor(configDir: string) {
    this.configDir = configDir;
  }

  async exportAll(scheme: ColorScheme, isDark: boolean): Promise<void> {
    const exports = this.generateAll(scheme, isDark);

    await this.ensureDir(`${this.configDir}/styles/exports`);

    await Promise.all([
      writeFile(`${this.configDir}/styles/_material-colors.scss`, exports.scss),
      writeFile(`${this.configDir}/styles/exports/material-colors.css`, exports.css),
      writeFile(`${this.configDir}/styles/exports/material-colors.conf`, exports.conf),
      writeFile(`${this.configDir}/styles/exports/material-colors.json`, exports.json),
      writeFile(`${this.configDir}/styles/exports/material-colors.sh`, exports.shell),
    ]);

    console.log(`[ColorExport] Exported ${isDark ? 'dark' : 'light'} theme colors`);
  }

  private generateAll(scheme: ColorScheme, isDark: boolean): ColorExports {
    return {
      scss: this.generateSCSS(scheme),
      css: this.generateCSS(scheme),
      conf: this.generateConf(scheme),
      json: this.generateJSON(scheme, isDark),
      shell: this.generateShell(scheme),
    };
  }

  private generateSCSS(scheme: ColorScheme): string {
    const entries = Object.entries(scheme);
    const vars = entries
      .map(([key, value]) => {
        const kebab = this.toKebabCase(key);
        return `$md-${kebab}: ${value};`;
      })
      .join('\n');

    return `// Material You Colors - Auto-generated
// Do not edit manually

${vars}
`;
  }

  private generateCSS(scheme: ColorScheme): string {
    const entries = Object.entries(scheme);
    const vars = entries
      .map(([key, value]) => {
        const kebab = this.toKebabCase(key);
        return `  --md-${kebab}: ${value};`;
      })
      .join('\n');

    const gtkVars = entries
      .map(([key, value]) => {
        const kebab = this.toKebabCase(key);
        return `@define-color md_${kebab.replace(/-/g, '_')} ${value};`;
      })
      .join('\n');

    return `/* Material You Colors - Auto-generated */
/* Do not edit manually */

:root {
${vars}
}

/* GTK3 compatibility */
${gtkVars}
`;
  }

  private generateConf(scheme: ColorScheme): string {
    const entries = Object.entries(scheme);
    const lines = entries
      .map(([key, value]) => {
        const snake = this.toSnakeCase(key);
        return `md_${snake}=${value}`;
      })
      .join('\n');

    return `# Material You Colors - Auto-generated
# Do not edit manually

${lines}
`;
  }

  private generateJSON(scheme: ColorScheme, isDark: boolean): string {
    return JSON.stringify(
      {
        mode: isDark ? 'dark' : 'light',
        generated: new Date().toISOString(),
        colors: scheme,
      },
      null,
      2
    );
  }

  private generateShell(scheme: ColorScheme): string {
    const entries = Object.entries(scheme);
    const vars = entries
      .map(([key, value]) => {
        const upper = this.toUpperSnakeCase(key);
        return `export MD_${upper}="${value}"`;
      })
      .join('\n');

    return `# Material You Colors - Auto-generated
# Do not edit manually
# Source this file in shell scripts

${vars}
`;
  }

  private toKebabCase(str: string): string {
    return str.replace(/([A-Z])/g, '-$1').toLowerCase().replace(/^-/, '');
  }

  private toSnakeCase(str: string): string {
    return str.replace(/([A-Z])/g, '_$1').toLowerCase().replace(/^_/, '');
  }

  private toUpperSnakeCase(str: string): string {
    return this.toSnakeCase(str).toUpperCase();
  }

  private async ensureDir(path: string): Promise<void> {
    await mkdir(path, { recursive: true });
  }
}
