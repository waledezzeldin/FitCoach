# Documentation File Reorganization Plan

## Overview
This plan organizes the comprehensive documentation files (01-06) into their proper SDLC phase folders for better discoverability and maintainability.

## File Migrations

### Phase 2: Software Requirements (`/docs/2-software-requirements/`)

| Old Location | New Location | Size | Status |
|--------------|--------------|------|--------|
| `/docs/02-DATA-MODELS.md` | `/docs/2-software-requirements/data-models.md` | ~8,000 words | ⏳ Pending |
| `/docs/04-FEATURE-SPECIFICATIONS.md` | `/docs/2-software-requirements/feature-specifications.md` | ~12,000 words | ⏳ Pending |
| `/docs/05-BUSINESS-LOGIC.md` | `/docs/2-software-requirements/business-logic.md` | ~10,000 words | ⏳ Pending |
| `/docs/06-API-SPECIFICATIONS.md` | `/docs/2-software-requirements/api-specifications.md` | ~7,000 words | ⏳ Pending |

### Phase 3: Software Architecture (`/docs/3-software-architecture/`)

| Old Location | New Location | Size | Status |
|--------------|--------------|------|--------|
| `/docs/01-EXECUTIVE-SUMMARY.md` | `/docs/3-software-architecture/executive-summary.md` | ~5,000 words | ⏳ Pending |
| `/docs/03-SCREEN-SPECIFICATIONS.md` | `/docs/3-software-architecture/screen-specifications.md` | ~15,000 words | ⏳ Pending |

### Reference Materials (`/docs/reference/`)

| Old Location | New Location | Size | Status |
|--------------|--------------|------|--------|
| `/docs/00-QUICK-START.md` | `/docs/reference/quick-start.md` | ~3,000 words | ⏳ Pending |
| `/docs/image-assets-catalog.md` | (already there) | ~8,000 words | ✅ Complete |

## Reference Updates Required

### Files with References to Update

1. **`/README.md`** - Main project README
2. **`/docs/INDEX.md`** - Documentation index
3. **`/docs/README.md`** - SDLC overview
4. **`/docs/00-QUICK-START.md`** - Internal references (before moving)
5. **`/docs/01-EXECUTIVE-SUMMARY.md`** - Internal references (before moving)
6. **`/docs/02-DATA-MODELS.md`** - Internal references (before moving)
7. **`/docs/2-software-requirements/README.md`** - Phase 2 overview
8. **`/docs/3-software-architecture/README.md`** - Phase 3 overview
9. **`/DOCUMENTATION_ORGANIZATION_SUMMARY.md`** - Historical record

### Reference Pattern Changes

| Old Pattern | New Pattern |
|-------------|-------------|
| `./00-QUICK-START.md` | `./reference/quick-start.md` |
| `./01-EXECUTIVE-SUMMARY.md` | `./3-software-architecture/executive-summary.md` |
| `./02-DATA-MODELS.md` | `./2-software-requirements/data-models.md` |
| `./03-SCREEN-SPECIFICATIONS.md` | `./3-software-architecture/screen-specifications.md` |
| `./04-FEATURE-SPECIFICATIONS.md` | `./2-software-requirements/feature-specifications.md` |
| `./05-BUSINESS-LOGIC.md` | `./2-software-requirements/business-logic.md` |
| `./06-API-SPECIFICATIONS.md` | `./2-software-requirements/api-specifications.md` |

## Implementation Steps

### Step 1: Move Files (No file modifications yet)
```bash
# Phase 2 files
mv /docs/02-DATA-MODELS.md /docs/2-software-requirements/data-models.md
mv /docs/04-FEATURE-SPECIFICATIONS.md /docs/2-software-requirements/feature-specifications.md
mv /docs/05-BUSINESS-LOGIC.md /docs/2-software-requirements/business-logic.md
mv /docs/06-API-SPECIFICATIONS.md /docs/2-software-requirements/api-specifications.md

# Phase 3 files
mv /docs/01-EXECUTIVE-SUMMARY.md /docs/3-software-architecture/executive-summary.md
mv /docs/03-SCREEN-SPECIFICATIONS.md /docs/3-software-architecture/screen-specifications.md

# Reference files
mv /docs/00-QUICK-START.md /docs/reference/quick-start.md
```

### Step 2: Update Internal File References
Update references within the moved files themselves:
- quick-start.md
- executive-summary.md
- data-models.md
- etc.

### Step 3: Update Documentation Index Files
- `/docs/INDEX.md`
- `/docs/README.md`
- `/docs/2-software-requirements/README.md`
- `/docs/3-software-architecture/README.md`

### Step 4: Update Project Root Files
- `/README.md`
- `/DOCUMENTATION_ORGANIZATION_SUMMARY.md`

### Step 5: Verification
- Check all links are valid
- Ensure no broken references
- Verify folder structure is clean

## Benefits

### Discoverability
- Files are now in their proper SDLC phase folders
- Easier to navigate by development stage
- Clear separation of concerns

### Maintainability
- Phase-based organization makes updates clearer
- Related documents grouped together
- Reduced clutter in `/docs` root

### Professional Structure
- Follows software engineering best practices
- Mirrors standard SDLC documentation organization
- Ready for professional development team handoff

##Backward Compatibility

While moving files, we'll consider creating symlinks or redirects if needed in the future, but for now, updating all references is the clearest approach.

## Final Structure

```
/docs/
├── INDEX.md                                    # Main documentation index
├── README.md                                   # SDLC overview
│
├── 1-customer-requirements/
│   ├── README.md
│   ├── end-user-requirements.md
│   ├── coach-requirements.md
│   └── admin-requirements.md
│
├── 2-software-requirements/
│   ├── README.md
│   ├── functional-requirements.md
│   ├── non-functional-requirements.md
│   ├── data-models.md                         # ← MOVED from 02-DATA-MODELS.md
│   ├── feature-specifications.md              # ← MOVED from 04-FEATURE-SPECIFICATIONS.md
│   ├── business-logic.md                      # ← MOVED from 05-BUSINESS-LOGIC.md
│   └── api-specifications.md                  # ← MOVED from 06-API-SPECIFICATIONS.md
│
├── 3-software-architecture/
│   ├── README.md
│   ├── system-architecture.md
│   ├── executive-summary.md                   # ← MOVED from 01-EXECUTIVE-SUMMARY.md
│   └── screen-specifications.md               # ← MOVED from 03-SCREEN-SPECIFICATIONS.md
│
├── 4-code-documentation/
│   ├── README.md
│   ├── component-reference.md
│   ├── utilities-reference.md
│   └── development-guide.md
│
├── reference/
│   ├── README.md
│   ├── quick-start.md                         # ← MOVED from 00-QUICK-START.md
│   ├── navigation-map.md
│   └── image-assets-catalog.md
│
└── archive/
    └── README.md
```

## Status: Ready to Execute

This plan has been reviewed and is ready for implementation.

---

**Created**: December 18, 2024  
**Status**: ⏳ Ready for Execution
