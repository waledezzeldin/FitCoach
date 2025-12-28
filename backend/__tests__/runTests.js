#!/usr/bin/env node

/**
 * Test Runner Script
 * Runs different test suites and generates coverage reports
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const COLORS = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m'
};

function log(message, color = 'reset') {
  console.log(`${COLORS[color]}${message}${COLORS.reset}`);
}

function runCommand(command, description) {
  log(`\n${description}...`, 'cyan');
  try {
    execSync(command, { stdio: 'inherit' });
    log(`✓ ${description} completed`, 'green');
    return true;
  } catch (error) {
    log(`✗ ${description} failed`, 'red');
    return false;
  }
}

function main() {
  const args = process.argv.slice(2);
  const testType = args[0] || 'all';

  log('='.repeat(60), 'blue');
  log('  FitCoach+ Backend Test Runner', 'blue');
  log('='.repeat(60), 'blue');

  let success = true;

  switch (testType) {
    case 'unit':
      log('\n📦 Running Unit Tests...', 'yellow');
      success = runCommand(
        'jest __tests__/controllers __tests__/services __tests__/middleware --coverage',
        'Unit Tests'
      );
      break;

    case 'integration':
      log('\n🔗 Running Integration Tests...', 'yellow');
      success = runCommand(
        'jest __tests__/integration --coverage',
        'Integration Tests'
      );
      break;

    case 'controllers':
      log('\n🎮 Running Controller Tests...', 'yellow');
      success = runCommand(
        'jest __tests__/controllers --coverage',
        'Controller Tests'
      );
      break;

    case 'services':
      log('\n⚙️  Running Service Tests...', 'yellow');
      success = runCommand(
        'jest __tests__/services --coverage',
        'Service Tests'
      );
      break;

    case 'middleware':
      log('\n🛡️  Running Middleware Tests...', 'yellow');
      success = runCommand(
        'jest __tests__/middleware --coverage',
        'Middleware Tests'
      );
      break;

    case 'coverage':
      log('\n📊 Running All Tests with Coverage...', 'yellow');
      success = runCommand(
        'jest --coverage --coverageReporters=text --coverageReporters=lcov --coverageReporters=html',
        'Coverage Report'
      );
      if (success) {
        log('\n📄 Coverage report generated at: coverage/index.html', 'green');
      }
      break;

    case 'watch':
      log('\n👀 Running Tests in Watch Mode...', 'yellow');
      runCommand('jest --watch', 'Watch Mode');
      break;

    case 'all':
    default:
      log('\n🚀 Running All Tests...', 'yellow');
      
      // Run unit tests
      log('\n1️⃣  Unit Tests', 'cyan');
      const unitSuccess = runCommand(
        'jest __tests__/controllers __tests__/services __tests__/middleware --collectCoverage=false',
        'Unit Tests'
      );

      // Run integration tests
      log('\n2️⃣  Integration Tests', 'cyan');
      const integrationSuccess = runCommand(
        'jest __tests__/integration --collectCoverage=false',
        'Integration Tests'
      );

      // Generate coverage
      log('\n3️⃣  Coverage Report', 'cyan');
      const coverageSuccess = runCommand(
        'jest --coverage --coverageReporters=text-summary',
        'Coverage Report'
      );

      success = unitSuccess && integrationSuccess && coverageSuccess;
      break;
  }

  log('\n' + '='.repeat(60), 'blue');
  if (success) {
    log('  ✅ All Tests Passed!', 'green');
  } else {
    log('  ❌ Some Tests Failed', 'red');
  }
  log('='.repeat(60), 'blue');

  process.exit(success ? 0 : 1);
}

main();
