#!/usr/bin/env node
/**
 * Build Ghost Theme ZIP
 * Creates a versioned zip file of the theme, excluding dev files
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const themeDir = __dirname;
const packageJsonPath = path.join(themeDir, 'package.json');

// Read package.json to get version
const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
const version = packageJson.version;
const themeName = packageJson.name;

// Output filename
const zipFilename = `${themeName}-v${version}.zip`;
const zipPath = path.join(themeDir, zipFilename);

// Files/directories to exclude from zip
const excludePatterns = [
  '.git',
  '.gitignore',
  '.devcontainer',
  'node_modules',
  '*.zip',
  '*.log',
  '.DS_Store',
  'Thumbs.db',
  '.vscode',
  '.idea',
  '*.md',
  'validate-theme.js',
  'test-theme.sh',
  'docker-compose.dev.yml',
  'VALIDATION-*.md',
  'DEVELOPMENT.md',
  'THEME-OVERVIEW.md',
  'STARTER-CONTENT.md',
  'INSTALLATION.md',
  '.env',
  '.env.local',
];

// Build exclude string for zip command
const excludeArgs = excludePatterns.flatMap(pattern => ['-x', pattern]);

try {
  // Remove old zip if it exists
  if (fs.existsSync(zipPath)) {
    console.log(`Removing old zip: ${zipFilename}`);
    fs.unlinkSync(zipPath);
  }

  console.log(`Building ${zipFilename}...`);
  
  // Create zip file
  // cd to theme directory and zip all files except excluded patterns
  execSync(
    `zip -r "${zipFilename}" . ${excludeArgs.join(' ')}`,
    {
      cwd: themeDir,
      stdio: 'inherit'
    }
  );

  // Get file size
  const stats = fs.statSync(zipPath);
  const fileSizeKB = (stats.size / 1024).toFixed(2);

  console.log(`\n✅ Successfully created ${zipFilename} (${fileSizeKB} KB)`);
  console.log(`   Version: ${version}`);
  console.log(`   Location: ${zipPath}\n`);

} catch (error) {
  console.error('❌ Error building zip:', error.message);
  process.exit(1);
}

