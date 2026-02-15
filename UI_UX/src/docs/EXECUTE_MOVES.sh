#!/bin/bash

# Documentation Reorganization - File Move Execution
# Run this script from the /docs/ directory
# Date: December 18, 2024

echo "========================================="
echo "Documentation Reorganization"
echo "Moving 6 files to their new locations..."
echo "========================================="
echo ""

# Check we're in the docs directory
if [ ! -f "INDEX.md" ]; then
    echo "❌ Error: Please run this script from the /docs/ directory"
    echo "   cd docs/"
    echo "   bash EXECUTE_MOVES.sh"
    exit 1
fi

echo "✅ Confirmed: Running from /docs/ directory"
echo ""

# Move Phase 2 files (Software Requirements)
echo "📁 Moving Phase 2 files (Software Requirements)..."

if [ -f "02-DATA-MODELS.md" ]; then
    mv 02-DATA-MODELS.md 2-software-requirements/data-models.md
    echo "  ✅ Moved: data-models.md"
else
    echo "  ⚠️  Skipped: 02-DATA-MODELS.md not found (may already be moved)"
fi

if [ -f "04-FEATURE-SPECIFICATIONS.md" ]; then
    mv 04-FEATURE-SPECIFICATIONS.md 2-software-requirements/feature-specifications.md
    echo "  ✅ Moved: feature-specifications.md"
else
    echo "  ⚠️  Skipped: 04-FEATURE-SPECIFICATIONS.md not found (may already be moved)"
fi

if [ -f "05-BUSINESS-LOGIC.md" ]; then
    mv 05-BUSINESS-LOGIC.md 2-software-requirements/business-logic.md
    echo "  ✅ Moved: business-logic.md"
else
    echo "  ⚠️  Skipped: 05-BUSINESS-LOGIC.md not found (may already be moved)"
fi

if [ -f "06-API-SPECIFICATIONS.md" ]; then
    mv 06-API-SPECIFICATIONS.md 2-software-requirements/api-specifications.md
    echo "  ✅ Moved: api-specifications.md"
else
    echo "  ⚠️  Skipped: 06-API-SPECIFICATIONS.md not found (may already be moved)"
fi

echo ""

# Move Phase 3 files (Software Architecture)
echo "📁 Moving Phase 3 files (Software Architecture)..."

if [ -f "01-EXECUTIVE-SUMMARY.md" ]; then
    mv 01-EXECUTIVE-SUMMARY.md 3-software-architecture/executive-summary.md
    echo "  ✅ Moved: executive-summary.md"
else
    echo "  ⚠️  Skipped: 01-EXECUTIVE-SUMMARY.md not found (may already be moved)"
fi

if [ -f "03-SCREEN-SPECIFICATIONS.md" ]; then
    mv 03-SCREEN-SPECIFICATIONS.md 3-software-architecture/screen-specifications.md
    echo "  ✅ Moved: screen-specifications.md"
else
    echo "  ⚠️  Skipped: 03-SCREEN-SPECIFICATIONS.md not found (may already be moved)"
fi

echo ""
echo "========================================="
echo "✅ File reorganization complete!"
echo "========================================="
echo ""

# Verify the new structure
echo "📋 Verification - checking new file locations..."
echo ""

echo "Phase 2 (Software Requirements):"
ls -1 2-software-requirements/*.md 2>/dev/null | sed 's/^/  /'
echo ""

echo "Phase 3 (Software Architecture):"
ls -1 3-software-architecture/*.md 2>/dev/null | sed 's/^/  /'
echo ""

echo "Reference:"
ls -1 reference/*.md 2>/dev/null | sed 's/^/  /'
echo ""

# Check for any remaining numbered files
echo "📋 Checking for remaining numbered files in /docs/ root..."
REMAINING=$(ls -1 0*.md 2>/dev/null | wc -l)

if [ "$REMAINING" -eq 0 ]; then
    echo "  ✅ Clean! No numbered files remaining in /docs/ root"
else
    echo "  ⚠️  Found $REMAINING numbered files still in /docs/ root:"
    ls -1 0*.md 2>/dev/null | sed 's/^/     /'
fi

echo ""
echo "========================================="
echo "🎉 Documentation reorganization complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Review the file locations above"
echo "  2. (Optional) Update references in other markdown files"
echo "  3. Delete planning documents when ready:"
echo "     - FILE_REORGANIZATION_PLAN.md"
echo "     - REORGANIZATION_EXECUTION_LOG.md"
echo "     - REFERENCE_UPDATE_MAPPING.md"
echo "     - REORGANIZATION_STATUS.md"
echo "     - REORGANIZATION_COMPLETE_GUIDE.md"
echo "     - FINAL_REORGANIZATION_STEPS.md"
echo "     - EXECUTE_MOVES.sh (this file)"
echo ""
