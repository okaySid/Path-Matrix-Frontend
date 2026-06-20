# Figma Flow Analyzer

A professional SaaS-grade Flutter dashboard for analyzing Figma flows and generating path matrices.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.10.0
- Dart SDK ≥ 3.0.0

### Installation

```bash
# 1. Navigate to project root
cd figma_flow_analyzer

# 2. Install dependencies
flutter pub get

# 3. Run on web (recommended for full dashboard experience)
flutter run -d chrome

# 4. Or run on desktop
flutter run -d macos    # macOS
flutter run -d windows  # Windows
flutter run -d linux    # Linux
```

---

## 📁 Project Structure

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # Root app + MaterialApp.router
│
├── core/
│   ├── theme/
│   │   └── app_theme.dart             # Material 3 light theme, colors, typography
│   ├── constants/
│   │   └── app_constants.dart         # Layout dimensions, spacing, labels
│   └── routing/
│       └── app_router.dart            # GoRouter setup with auth redirect guard
│
├── features/
│   ├── auth/
│   │   ├── pages/
│   │   │   └── login_page.dart        # Login screen with background decoration
│   │   └── widgets/
│   │       └── login_form.dart        # Email/password form, demo mode button
│   │
│   ├── dashboard/
│   │   ├── pages/
│   │   │   └── dashboard_page.dart    # 3-section responsive layout
│   │   └── widgets/
│   │       ├── sidebar.dart           # Collapsible left sidebar with project list
│   │       ├── action_bar.dart        # Top-right action buttons
│   │       ├── workspace.dart         # Main content area (empty/project views)
│   │       └── new_analysis_modal.dart # Modal dialog for creating analyses
│   │
│   └── analysis/
│       ├── pages/
│       │   └── analysis_detail_page.dart  # Standalone analysis page (future routing)
│       └── widgets/
│           ├── metrics_row.dart        # 6-card responsive metrics summary
│           ├── analysis_tabs.dart      # TabBar + TabBarView controller
│           ├── paths_tab.dart          # Paths table with search + length filter
│           ├── screens_tab.dart        # Reusable list for orphan/dead/isolated
│           ├── nodes_tab.dart          # Node Name + ID table with copy
│           ├── connections_tab.dart    # Source → Target connections table
│           └── data_table_widget.dart  # Reusable styled DataTable wrapper
│
└── shared/
    ├── widgets/
    │   └── shared_widgets.dart        # AppButton, AppCard, StatusChip, AppTextField,
    │                                  # EmptyStateWidget, SectionHeader, LoadingOverlay
    └── models/
        ├── analysis_models.dart       # AnalysisProject, NodeModel, ConnectionModel, PathModel
        └── app_state.dart             # ChangeNotifier AppState with demo data
```

---

## 🎨 Design System

| Token | Value |
|---|---|
| Primary | `#1E40AF` (Deep Blue) |
| Accent | `#7C3AED` (Violet) |
| Success | `#059669` (Emerald) |
| Warning | `#D97706` (Amber) |
| Error | `#DC2626` (Red) |
| Sidebar BG | `#0F172A` (Slate 900) |
| Font | Plus Jakarta Sans |

---

## 🧩 Key Features

- ✅ **Login page** with email/password, demo mode toggle, animated background
- ✅ **Collapsible sidebar** with project list, status indicators, delete confirmation
- ✅ **Action bar** — Run Analysis, Export CSV, Export Excel, Settings
- ✅ **Metrics cards** — 6 responsive stat cards with trend badges
- ✅ **6 analysis tabs** — Paths, Orphan Screens, Dead Ends, Isolated, Nodes, Connections
- ✅ **Search & filter** on every tab
- ✅ **New Analysis modal** — Figma URL + token input with loading overlay
- ✅ **Responsive layout** — desktop 3-column, mobile drawer-based
- ✅ **GoRouter** with auth redirect guard
- ✅ **Provider** state management
- ✅ **Material 3** with custom Plus Jakarta Sans typography

---

## 🔧 Extending the App

### Connect a real backend
Replace the `_generateDemoResult()` methods in `AppState` with actual API calls to your Figma analysis service.

### Add authentication
Replace `appState.login()` in `login_form.dart` with your auth service call (Firebase, Supabase, custom JWT, etc.).

### Export functionality
Wire up the Export CSV / Export Excel buttons in `action_bar.dart` using packages like `csv` or `excel`.
