# Design Specification: App Performance Optimization (Budgeting Screen NLP Keywords)

This specification outlines the performance optimization for the category detail panel in the budgeting screen. It resolves scrolling and loading lag (stutter) as the number of NLP keywords grows.

---

## 1. Problem Statement & Root Cause
When a user opens a category details panel in the budgeting screen, the sheet stutters during scrolling/dragging because:
- The UI listens to `keywordsNotifierProvider` which loads *all* keywords across *all* categories, running an in-memory list filtering pass (`.where((k) => k.categoryId == category.id)`) on every build.
- Adding, updating, or deleting a keyword in *any* category rebuilds the *entire* detail panel (inputs, dropdowns, buttons, and chips list).
- Layout overhead: rendering a `Wrap` of `Chip` widgets causes recurrent painting passes on scroll.

---

## 2. Proposed Design (Option A)

### A. SQLite Database & Family Provider
We will implement a family provider that queries only category-specific keywords using Riverpod's family modifier.
- **Provider**: `categoryKeywordsNotifierProvider(categoryId)`
  - Reads `DatabaseHelper.instance.getKeywordsForCategory(categoryId)` directly.
  - Automatically isolates state changes per category.

### B. Widget Deconstruction & Rebuild Isolation
We will move the keywords list into a separate, isolated widget:
- **`_KeywordsListWidget`**:
  - Extends `ConsumerWidget`.
  - Watches `categoryKeywordsNotifierProvider(categoryId)`.
  - Adding or deleting keywords will only trigger rebuilds of this small widget. The main detail panel (including input fields, dropdown, and sliders) will not be rebuilt.
  
### C. Paint Isolation (Repaint Boundary)
- Wrap `_KeywordsListWidget` in a `RepaintBoundary` to isolate chip list painting from sheet scrolling gestures, lowering GPU layout load.

---

## 3. Impact & Verification Plan
- **Verification**: Run `flutter analyze` and ensure no compile warnings.
- **Smoothness Test**: Scroll up and down category details sheet containing dozens of keywords to verify stutter is eliminated.
