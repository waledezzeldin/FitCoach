#!/bin/bash

# Documentation Reorganization Script
# This script moves documentation files to their proper SDLC phase folders
# Date: December 18, 2024

echo "Starting documentation reorganization..."

# Create backup
echo "Creating backup..."
mkdir -p /docs/backup-$(date +%Y%m%d)
cp /docs/01-*.md /docs/02-*.md /docs/03-*.md /docs/04-*.md /docs/05-*.md /docs/06-*.md /docs/backup-$(date +%Y%m%d)/

# Phase 2: Software Requirements
echo "Moving Phase 2 files..."
mv /docs/02-DATA-MODELS.md /docs/2-software-requirements/data-models.md
mv /docs/04-FEATURE-SPECIFICATIONS.md /docs/2-software-requirements/feature-specifications.md
mv /docs/05-BUSINESS-LOGIC.md /docs/2-software-requirements/business-logic.md
mv /docs/06-API-SPECIFICATIONS.md /docs/2-software-requirements/api-specifications.md

# Phase 3: Software Architecture
echo "Moving Phase 3 files..."
mv /docs/01-EXECUTIVE-SUMMARY.md /docs/3-software-architecture/executive-summary.md
mv /docs/03-SCREEN-SPECIFICATIONS.md /docs/3-software-architecture/screen-specifications.md

echo "✅ Files moved successfully!"
echo ""
echo "Next: Update all cross-references using the patterns in REFERENCE_UPDATE_MAPPING.md"
