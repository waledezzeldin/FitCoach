# Reference Update Mapping

This document maps all old references to new references for the documentation reorganization.

## Global Find & Replace Patterns

Execute these replacements across all markdown files in `/docs/` and root `/`:

### Pattern 1: Quick Start
```
FIND:    ./00-QUICK-START.md
REPLACE: ./reference/quick-start.md

FIND:    /docs/00-QUICK-START.md
REPLACE: /docs/reference/quick-start.md

FIND:    00-QUICK-START.md
REPLACE: reference/quick-start.md
```

### Pattern 2: Executive Summary
```
FIND:    ./01-EXECUTIVE-SUMMARY.md
REPLACE: ./3-software-architecture/executive-summary.md

FIND:    /docs/01-EXECUTIVE-SUMMARY.md
REPLACE: /docs/3-software-architecture/executive-summary.md

FIND:    01-EXECUTIVE-SUMMARY.md
REPLACE: 3-software-architecture/executive-summary.md
```

### Pattern 3: Data Models
```
FIND:    ./02-DATA-MODELS.md
REPLACE: ./2-software-requirements/data-models.md

FIND:    /docs/02-DATA-MODELS.md
REPLACE: /docs/2-software-requirements/data-models.md

FIND:    02-DATA-MODELS.md
REPLACE: 2-software-requirements/data-models.md
```

### Pattern 4: Screen Specifications
```
FIND:    ./03-SCREEN-SPECIFICATIONS.md
REPLACE: ./3-software-architecture/screen-specifications.md

FIND:    /docs/03-SCREEN-SPECIFICATIONS.md
REPLACE: /docs/3-software-architecture/screen-specifications.md

FIND:    03-SCREEN-SPECIFICATIONS.md
REPLACE: 3-software-architecture/screen-specifications.md
```

### Pattern 5: Feature Specifications
```
FIND:    ./04-FEATURE-SPECIFICATIONS.md
REPLACE: ./2-software-requirements/feature-specifications.md

FIND:    /docs/04-FEATURE-SPECIFICATIONS.md
REPLACE: /docs/2-software-requirements/feature-specifications.md

FIND:    04-FEATURE-SPECIFICATIONS.md
REPLACE: 2-software-requirements/feature-specifications.md
```

### Pattern 6: Business Logic
```
FIND:    ./05-BUSINESS-LOGIC.md
REPLACE: ./2-software-requirements/business-logic.md

FIND:    /docs/05-BUSINESS-LOGIC.md
REPLACE: /docs/2-software-requirements/business-logic.md

FIND:    05-BUSINESS-LOGIC.md
REPLACE: 2-software-requirements/business-logic.md
```

### Pattern 7: API Specifications
```
FIND:    ./06-API-SPECIFICATIONS.md
REPLACE: ./2-software-requirements/api-specifications.md

FIND:    /docs/06-API-SPECIFICATIONS.md
REPLACE: /docs/2-software-requirements/api-specifications.md

FIND:    06-API-SPECIFICATIONS.md
REPLACE: 2-software-requirements/api-specifications.md
```

---

## Files Requiring Updates (Total: 9 files)

1. `/README.md` - Main project README
2. `/DOCUMENTATION_ORGANIZATION_SUMMARY.md` - Organization summary
3. `/docs/INDEX.md` - Main documentation index
4. `/docs/README.md` - SDLC overview
5. `/docs/2-software-requirements/README.md` - Phase 2 overview
6. `/docs/3-software-architecture/README.md` - Phase 3 overview  
7. `/docs/reference/README.md` - Reference materials overview
8. **Each of the 7 moved files** (internal cross-references)

---

## Post-Move Internal Reference Updates

After files are moved, update internal cross-references within each moved file:

### `reference/quick-start.md` (formerly 00-QUICK-START.md)
- Update all `./XX-` references to use new folder paths
- Change `./01-EXECUTIVE-SUMMARY.md` → `../3-software-architecture/executive-summary.md`
- Change `./02-DATA-MODELS.md` → `../2-software-requirements/data-models.md`
- etc.

### `3-software-architecture/executive-summary.md` (formerly 01-)
- Update references to other docs using `../` for parent folder navigation

### `2-software-requirements/data-models.md` (formerly 02-)
- Update cross-references to other documents

### `3-software-architecture/screen-specifications.md` (formerly 03-)
- Update cross-references

### `2-software-requirements/feature-specifications.md` (formerly 04-)
- Update cross-references

### `2-software-requirements/business-logic.md` (formerly 05-)
- Update cross-references

### `2-software-requirements/api-specifications.md` (formerly 06-)
- Update cross-references

---

## Verification Checklist

After all updates:

- [ ] All links in `/README.md` work
- [ ] All links in `/docs/INDEX.md` work  
- [ ] All links in `/docs/README.md` work
- [ ] All cross-references within moved files work
- [ ] No broken links reported
- [ ] `/docs/` root only contains folders and index files

---

**Status**: Ready for systematic execution  
**Created**: December 18, 2024
