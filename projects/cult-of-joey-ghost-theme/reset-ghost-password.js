#!/usr/bin/env node
/**
 * Ghost Password Reset Script
 * Generates bcrypt hash for password reset
 */

const bcrypt = require('bcryptjs');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

const email = process.argv[2] || 'joey@cultofjoey.com';
const password = process.argv[3] || (() => {
  console.error('ERROR: Password must be provided as third argument');
  console.error('Usage: node reset-ghost-password.js <email> <password>');
  process.exit(1);
})();

console.log(`Generating password hash for: ${email}`);
console.log(`Password: ${password.replace(/./g, '*')}`);

bcrypt.hash(password, 10)
  .then(hash => {
    console.log('\n=== Password Hash ===');
    console.log(hash);
    console.log('\n=== SQL Update Query ===');
    console.log(`UPDATE users SET password = '${hash}' WHERE email = '${email}';`);
    console.log('\n=== Verification Query ===');
    console.log(`SELECT email, name FROM users WHERE email = '${email}';`);
    process.exit(0);
  })
  .catch(err => {
    console.error('Error generating hash:', err);
    process.exit(1);
  });
