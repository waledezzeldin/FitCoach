#!/bin/bash

# عاش Fitness Platform - Move Documentation Files
# This script moves all .md files from backend/ and mobile/ into their respective docs/ folders

echo "🚀 عاش Fitness - Documentation Organization Script"
echo "=================================================="
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# BACKEND FILES
echo -e "${BLUE}📦 Moving Backend Documentation Files...${NC}"
echo ""

# Move backend .md files (exclude README.md)
mv backend/BACKEND_AUDIT_COMPLETE.md backend/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved BACKEND_AUDIT_COMPLETE.md"
mv backend/BACKEND_COMPLETE_SUMMARY.md backend/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved BACKEND_COMPLETE_SUMMARY.md"
mv backend/BACKEND_TESTING_SUMMARY.md backend/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved BACKEND_TESTING_SUMMARY.md"
mv backend/COMPLETE_SYSTEM_OVERVIEW.md backend/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved COMPLETE_SYSTEM_OVERVIEW.md"
mv backend/COMPLETE_TEMPLATE_LIBRARY.md backend/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved COMPLETE_TEMPLATE_LIBRARY.md"
mv backend/FEATURES_COMPLETE.md backend/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved FEATURES_COMPLETE.md"
mv backend/INJURY_MAPPING_GUIDE.md backend/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved INJURY_MAPPING_GUIDE.md"
mv backend/PRODUCTION_READINESS_CHECKLIST.md backend/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved PRODUCTION_READINESS_CHECKLIST.md"
mv backend/TEMPLATE_STRUCTURE_FINAL.md backend/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved TEMPLATE_STRUCTURE_FINAL.md"
mv backend/TESTING.md backend/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved TESTING.md"
mv backend/TESTING_COMPLETE.md backend/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved TESTING_COMPLETE.md"
mv backend/WORKOUT_SYSTEM_GUIDE.md backend/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved WORKOUT_SYSTEM_GUIDE.md"
mv backend/WORKOUT_TEMPLATES_COMPLETE.md backend/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved WORKOUT_TEMPLATES_COMPLETE.md"
mv backend/WORKOUT_TEMPLATES_FORMAT_COMPARISON.md backend/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved WORKOUT_TEMPLATES_FORMAT_COMPARISON.md"
mv backend/WORKOUT_TEMPLATES_GUIDE.md backend/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved WORKOUT_TEMPLATES_GUIDE.md"
mv backend/WORKOUT_TEMPLATES_IMPLEMENTATION_COMPLETE.md backend/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved WORKOUT_TEMPLATES_IMPLEMENTATION_COMPLETE.md"
mv backend/WORKOUT_TEMPLATES_LIBRARY.md backend/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved WORKOUT_TEMPLATES_LIBRARY.md"
mv backend/WORKOUT_TEMPLATES_QUICK_START.md backend/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved WORKOUT_TEMPLATES_QUICK_START.md"
mv backend/WORKOUT_TEMPLATES_TWO_TIER_SYSTEM.md backend/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved WORKOUT_TEMPLATES_TWO_TIER_SYSTEM.md"

echo ""
echo -e "${BLUE}📱 Moving Mobile Documentation Files...${NC}"
echo ""

# Move mobile .md files (exclude README.md which will be kept in root)
mv mobile/100_PERCENT_COMPLETE.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved 100_PERCENT_COMPLETE.md"
mv mobile/100_PERCENT_TEST_COVERAGE_COMPLETE.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved 100_PERCENT_TEST_COVERAGE_COMPLETE.md"
mv mobile/BACKEND_INTEGRATION_GUIDE.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved BACKEND_INTEGRATION_GUIDE.md"
mv mobile/COMPLETION_STATUS.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved COMPLETION_STATUS.md"
mv mobile/COMPREHENSIVE_AUDIT_REPORT.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved COMPREHENSIVE_AUDIT_REPORT.md"
mv mobile/EXECUTIVE_SUMMARY.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved EXECUTIVE_SUMMARY.md"
mv mobile/FEATURE_AUDIT.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved FEATURE_AUDIT.md"
mv mobile/FINAL_AUDIT_SUMMARY.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved FINAL_AUDIT_SUMMARY.md"
mv mobile/FINAL_DELIVERABLES_REPORT.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved FINAL_DELIVERABLES_REPORT.md"
mv mobile/FINAL_IMPLEMENTATION_COMPLETE.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved FINAL_IMPLEMENTATION_COMPLETE.md"
mv mobile/FINAL_SUMMARY.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved FINAL_SUMMARY.md"
mv mobile/IMPLEMENTATION_GUIDE.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved IMPLEMENTATION_GUIDE.md"
mv mobile/IMPLEMENTATION_SUMMARY.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved IMPLEMENTATION_SUMMARY.md"
mv mobile/INDEX.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved INDEX.md"
mv mobile/MIGRATION_COMPLETENESS_REPORT.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved MIGRATION_COMPLETENESS_REPORT.md"
mv mobile/PHASE_2_COMPLETE.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved PHASE_2_COMPLETE.md"
mv mobile/PROGRESS.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved PROGRESS.md"
mv mobile/QUICK_START.md mobile/docs/QUICK_START_OLD.md 2>/dev/null && echo -e "${GREEN}✅${NC} Moved QUICK_START.md (renamed to avoid conflict)"
mv mobile/REACT_VS_FLUTTER_COMPARISON.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved REACT_VS_FLUTTER_COMPARISON.md"
mv mobile/REMAINING_SCREENS.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved REMAINING_SCREENS.md"
mv mobile/STATUS.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved STATUS.md"
mv mobile/TESTING_AND_FEATURE_COMPLETE_REPORT.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved TESTING_AND_FEATURE_COMPLETE_REPORT.md"
mv mobile/TEST_IMPLEMENTATION_COMPLETE.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved TEST_IMPLEMENTATION_COMPLETE.md"
mv mobile/TEST_READY_REPORT.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved TEST_READY_REPORT.md"
mv mobile/TEST_SUITE_STATUS.md mobile/docs/ 2>/dev/null && echo -e "${GREEN}✅${NC} Moved TEST_SUITE_STATUS.md"

echo ""
echo "=================================================="
echo -e "${GREEN}✅ Documentation organization complete!${NC}"
echo ""
echo "📂 Backend docs: /backend/docs/"
echo "📱 Mobile docs: /mobile/docs/"
echo ""
echo "Next: Update BACKEND README and MOBILE README to point to docs folder"
echo "=================================================="
