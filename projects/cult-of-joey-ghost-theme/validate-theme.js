#!/usr/bin/env node

/**
 * Ghost Theme Validator
 * Based on Ghost CMS theme validation standards
 * Validates themes against Ghost's requirements and best practices
 */

const fs = require('fs');
const path = require('path');

// ANSI color codes for terminal output
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  bold: '\x1b[1m'
};

class GhostThemeValidator {
  constructor(themePath) {
    this.themePath = themePath;
    this.errors = [];
    this.warnings = [];
    this.info = [];
    this.requiredFiles = [
      'package.json',
      'default.hbs'
    ];
    this.optionalFiles = [
      'index.hbs',
      'home.hbs',
      'post.hbs',
      'page.hbs',
      'tag.hbs',
      'author.hbs',
      'error.hbs'
    ];
    this.requiredHandlebarsHelpers = [
      '{{ghost_head}}',
      '{{ghost_foot}}'
    ];
    this.validHandlebarsHelpers = [
      // Content helpers
      '{{title}}', '{{content}}', '{{excerpt}}', '{{url}}', '{{slug}}',
      '{{date}}', '{{updated_at}}', '{{published_at}}', '{{reading_time}}',
      '{{feature_image}}', '{{img_url}}', '{{tags}}', '{{authors}}',
      '{{primary_tag}}', '{{primary_author}}',
      
      // Site helpers
      '{{@site.title}}', '{{@site.description}}', '{{@site.url}}',
      '{{@site.locale}}', '{{@site.navigation}}',
      
      // Page helpers
      '{{@page.show_title_and_feature_image}}',
      
      // Navigation
      '{{navigation}}',
      
      // Ghost helpers
      '{{ghost_head}}', '{{ghost_foot}}',
      
      // Conditionals
      '{{#if}}', '{{#unless}}', '{{#foreach}}', '{{#get}}',
      '{{#match}}', '{{#has}}', '{{#is}}',
      
      // Utilities
      '{{asset}}', '{{plural}}', '{{pagination}}'
    ];
    this.invalidHelpers = [
      '{{eq}}', // Not a valid Ghost helper - use {{#match}} instead
      '{{meta_description}}', // No longer needed in head
      '{{meta_title}}' // Still valid but ghost_head handles it
    ];
  }

  log(message, type = 'info') {
    const prefix = {
      error: `${colors.red}✗ ERROR:${colors.reset}`,
      warning: `${colors.yellow}⚠ WARNING:${colors.reset}`,
      info: `${colors.cyan}ℹ INFO:${colors.reset}`,
      success: `${colors.green}✓${colors.reset}`
    }[type];
    console.log(`${prefix} ${message}`);
  }

  validate() {
    console.log(`${colors.bold}${colors.blue}Ghost Theme Validator${colors.reset}\n`);
    console.log(`Validating theme: ${this.themePath}\n`);

    this.checkRequiredFiles();
    this.checkPackageJson();
    this.checkHandlebarsFiles();
    this.checkCSSFiles();
    this.checkJavaScriptFiles();
    this.checkThemeStructure();

    this.printSummary();
    return this.errors.length === 0;
  }

  checkRequiredFiles() {
    this.log('Checking required files...', 'info');
    for (const file of this.requiredFiles) {
      const filePath = path.join(this.themePath, file);
      if (!fs.existsSync(filePath)) {
        this.errors.push({
          type: 'fatal',
          file: file,
          message: `Required file missing: ${file}`
        });
        this.log(`Missing required file: ${file}`, 'error');
      } else {
        this.log(`Found: ${file}`, 'success');
      }
    }
  }

  checkPackageJson() {
    this.log('Validating package.json...', 'info');
    const packagePath = path.join(this.themePath, 'package.json');
    
    if (!fs.existsSync(packagePath)) {
      return; // Already caught in required files check
    }

    try {
      const packageContent = JSON.parse(fs.readFileSync(packagePath, 'utf8'));

      // Check required fields
      if (!packageContent.name) {
        this.errors.push({
          type: 'error',
          file: 'package.json',
          message: 'package.json must have a "name" field'
        });
        this.log('Missing "name" field in package.json', 'error');
      }

      if (!packageContent.engines || !packageContent.engines.ghost) {
        this.errors.push({
          type: 'error',
          file: 'package.json',
          message: 'package.json must specify "engines.ghost" version (e.g., ">=5.0.0")'
        });
        this.log('Missing "engines.ghost" in package.json', 'error');
      }

      // Check author.email (required for distributed themes)
      if (!packageContent.author) {
        this.errors.push({
          type: 'error',
          file: 'package.json',
          message: 'package.json must have an "author" object'
        });
        this.log('Missing "author" object in package.json', 'error');
      } else if (!packageContent.author.email) {
        this.errors.push({
          type: 'error',
          file: 'package.json',
          message: 'package.json "author.email" is required for theme distribution'
        });
        this.log('Missing "author.email" in package.json', 'error');
      }

      // Check for unused custom settings
      if (packageContent.config && packageContent.config.custom) {
        const customSettings = Object.keys(packageContent.config.custom);
        this.warnings.push({
          type: 'warning',
          file: 'package.json',
          message: `Custom theme settings defined but may not be used: ${customSettings.join(', ')}`
        });
        this.log(`Custom settings defined: ${customSettings.join(', ')}`, 'warning');
      }

      this.log('package.json structure is valid', 'success');
    } catch (error) {
      this.errors.push({
        type: 'fatal',
        file: 'package.json',
        message: `Invalid JSON in package.json: ${error.message}`
      });
      this.log(`Invalid JSON: ${error.message}`, 'error');
    }
  }

  checkHandlebarsFiles() {
    this.log('Validating Handlebars templates...', 'info');
    const hbsFiles = this.findAllFiles('.hbs');

    if (hbsFiles.length === 0) {
      this.errors.push({
        type: 'fatal',
        file: 'templates',
        message: 'No Handlebars template files found'
      });
      this.log('No .hbs files found', 'error');
      return;
    }

    for (const file of hbsFiles) {
      this.validateHandlebarsFile(file);
    }
  }

  validateHandlebarsFile(filePath) {
    const content = fs.readFileSync(filePath, 'utf8');
    const relativePath = path.relative(this.themePath, filePath);
    const fileName = path.basename(filePath);

    // Check for required helpers in default.hbs
    if (fileName === 'default.hbs') {
      if (!content.includes('{{ghost_head}}')) {
        this.errors.push({
          type: 'fatal',
          file: relativePath,
          message: 'default.hbs must include {{ghost_head}} helper'
        });
        this.log(`${relativePath}: Missing {{ghost_head}}`, 'error');
      } else {
        this.log(`${relativePath}: Contains {{ghost_head}}`, 'success');
      }

      if (!content.includes('{{ghost_foot}}')) {
        this.errors.push({
          type: 'error',
          file: relativePath,
          message: 'default.hbs should include {{ghost_foot}} helper'
        });
        this.log(`${relativePath}: Missing {{ghost_foot}}`, 'warning');
      }

      // Check for deprecated meta_description
      if (content.includes('{{meta_description}}')) {
        this.errors.push({
          type: 'error',
          file: relativePath,
          message: '{{meta_description}} in HTML head is no longer required - Ghost outputs this automatically in {{ghost_head}}'
        });
        this.log(`${relativePath}: Contains deprecated {{meta_description}}`, 'error');
      }
    }

    // Check for invalid helpers
    for (const invalidHelper of this.invalidHelpers) {
      if (content.includes(invalidHelper)) {
        this.errors.push({
          type: 'fatal',
          file: relativePath,
          message: `Invalid Handlebars helper used: ${invalidHelper}`
        });
        this.log(`${relativePath}: Invalid helper ${invalidHelper}`, 'error');
      }
    }

    // Check for @page.show_title_and_feature_image usage in page.hbs
    if (fileName === 'page.hbs' && !content.includes('@page.show_title_and_feature_image')) {
      this.errors.push({
        type: 'error',
        file: relativePath,
        message: 'page.hbs should use @page.show_title_and_feature_image to support page features'
      });
      this.log(`${relativePath}: Missing @page.show_title_and_feature_image support`, 'warning');
    }

    // Check for proper Handlebars syntax
    const unclosedBlocks = this.checkUnclosedBlocks(content);
    if (unclosedBlocks.length > 0) {
      this.errors.push({
        type: 'fatal',
        file: relativePath,
        message: `Unclosed Handlebars blocks: ${unclosedBlocks.join(', ')}`
      });
      this.log(`${relativePath}: Unclosed blocks found`, 'error');
    }
  }

  checkUnclosedBlocks(content) {
    const blocks = [];
    const blockRegex = /\{\{#(\w+)\}/g;
    const endRegex = /\{\{\/(\w+)\}/g;
    let match;

    const openBlocks = [];
    while ((match = blockRegex.exec(content)) !== null) {
      openBlocks.push(match[1]);
    }

    const closeBlocks = [];
    while ((match = endRegex.exec(content)) !== null) {
      closeBlocks.push(match[1]);
    }

    // Simple check - more complex validation would require a parser
    if (openBlocks.length !== closeBlocks.length) {
      return ['Block count mismatch'];
    }

    return [];
  }

  checkCSSFiles() {
    this.log('Checking CSS files...', 'info');
    const cssFiles = this.findAllFiles('.css');

    if (cssFiles.length === 0) {
      this.warnings.push({
        type: 'warning',
        file: 'styles',
        message: 'No CSS files found - theme may not have styles'
      });
      this.log('No CSS files found', 'warning');
      return;
    }

    for (const file of cssFiles) {
      const content = fs.readFileSync(file, 'utf8');
      const relativePath = path.relative(this.themePath, file);

      // Check for required Koenig editor classes
      if (!content.includes('.kg-width-wide') || !content.includes('.kg-width-full')) {
        this.errors.push({
          type: 'error',
          file: relativePath,
          message: 'CSS must include .kg-width-wide and .kg-width-full classes for Koenig editor support'
        });
        this.log(`${relativePath}: Missing Koenig editor width classes`, 'error');
      } else {
        this.log(`${relativePath}: Contains Koenig editor classes`, 'success');
      }

      // Check for accessibility (reduced motion)
      if (!content.includes('prefers-reduced-motion') && !content.includes('reduced-motion')) {
        this.warnings.push({
          type: 'warning',
          file: relativePath,
          message: 'Consider adding support for prefers-reduced-motion for accessibility'
        });
        this.log(`${relativePath}: Consider reduced-motion support`, 'warning');
      }
    }
  }

  checkJavaScriptFiles() {
    this.log('Checking JavaScript files...', 'info');
    const jsFiles = this.findAllFiles('.js');

    if (jsFiles.length > 0) {
      this.log(`Found ${jsFiles.length} JavaScript file(s)`, 'info');
    }
  }

  checkThemeStructure() {
    this.log('Checking theme structure...', 'info');
    
    const partialsDir = path.join(this.themePath, 'partials');
    if (fs.existsSync(partialsDir)) {
      const partials = fs.readdirSync(partialsDir).filter(f => f.endsWith('.hbs'));
      this.log(`Found ${partials.length} partial(s)`, 'info');
    }

    const assetsDir = path.join(this.themePath, 'assets');
    if (fs.existsSync(assetsDir)) {
      this.log('Assets directory found', 'success');
    } else {
      this.warnings.push({
        type: 'warning',
        file: 'structure',
        message: 'No assets directory found - consider organizing CSS/JS in assets/'
      });
    }
  }

  findAllFiles(extension) {
    const files = [];
    
    const walkDir = (dir) => {
      if (!fs.existsSync(dir)) return;
      
      const entries = fs.readdirSync(dir);
      for (const entry of entries) {
        const fullPath = path.join(dir, entry);
        const stat = fs.statSync(fullPath);
        
        if (stat.isDirectory() && !entry.startsWith('.') && entry !== 'node_modules') {
          walkDir(fullPath);
        } else if (stat.isFile() && entry.endsWith(extension)) {
          files.push(fullPath);
        }
      }
    };

    walkDir(this.themePath);
    return files;
  }

  printSummary() {
    console.log(`\n${colors.bold}${colors.blue}Validation Summary${colors.reset}\n`);
    
    if (this.errors.length === 0 && this.warnings.length === 0) {
      console.log(`${colors.green}${colors.bold}✓ Theme validation passed!${colors.reset}\n`);
      return;
    }

    if (this.errors.length > 0) {
      console.log(`${colors.red}${colors.bold}Errors (${this.errors.length}):${colors.reset}`);
      this.errors.forEach((error, index) => {
        console.log(`  ${index + 1}. [${error.type.toUpperCase()}] ${error.file}: ${error.message}`);
      });
      console.log();
    }

    if (this.warnings.length > 0) {
      console.log(`${colors.yellow}${colors.bold}Warnings (${this.warnings.length}):${colors.reset}`);
      this.warnings.forEach((warning, index) => {
        console.log(`  ${index + 1}. ${warning.file}: ${warning.message}`);
      });
      console.log();
    }

    if (this.errors.length > 0) {
      console.log(`${colors.red}Theme validation failed. Please fix the errors above.${colors.reset}\n`);
    } else {
      console.log(`${colors.yellow}Theme validation passed with warnings.${colors.reset}\n`);
    }
  }
}

// CLI execution
if (require.main === module) {
  const themePath = process.argv[2] || process.cwd();
  
  if (!fs.existsSync(themePath)) {
    console.error(`${colors.red}Error: Theme path does not exist: ${themePath}${colors.reset}`);
    process.exit(1);
  }

  const validator = new GhostThemeValidator(themePath);
  const isValid = validator.validate();
  
  process.exit(isValid ? 0 : 1);
}

module.exports = GhostThemeValidator;

