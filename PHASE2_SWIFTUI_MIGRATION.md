# Phase 2 – SwiftUI Migration Plan

**Owner:** Modernization initiative  
**Last Updated:** November 3, 2025  
**Status:** Draft

---

## 🎯 Goals

- Replace the storyboard / UIKit entry point with a SwiftUI-first architecture.
- Gradually rewrite high-impact screens in SwiftUI while keeping the app shippable.
- Introduce a testable MVVM layer to decouple business logic from the view layer.
- Preserve existing Firebase, AdMob, and Vision functionality during the transition.

---

## 🧱 Architectural Direction

1. **SwiftUI App Lifecycle**
   - Create `ReaderApp` using the SwiftUI `@main` entry point.
   - Adopt `UIApplicationDelegateAdaptor` so the existing `AppDelegate` logic (Firebase, ads, audio session) keeps working.
   - Replace manual `UIWindow` bootstrapping with a SwiftUI `WindowGroup`.

2. **Root Navigation**
   - Introduce a `RootContainerView` that hosts a `NavigationStack` (iOS 16+) or `NavigationView` fallback (iOS 15).
   - Use a coordinator-style `ObservableObject` to drive navigation so UIKit push logic can be retired screen-by-screen.
   - For legacy flows that are still UIKit, wrap them in `UIViewControllerRepresentable` and present via SwiftUI sheets or navigation destinations.

3. **Design System Layer**
   - Mirror existing helpers (`Colors`, `CustomButton`, typography) with SwiftUI extensions/components.
   - House all shared SwiftUI styles in `ReaderDesignSystem` namespace for reuse.

4. **Feature Migration Strategy**
   - Prioritize screens where SwiftUI provides immediate wins (home/input screen, choice list).
   - Extract business logic into `ObservableObject` view models before rewriting the UI.
   - Wrap remaining UIKit controllers so they remain accessible until their SwiftUI equivalents ship.

5. **Shared Services**
   - Keep services (Vision OCR, speech, persistence, ads) in pure Swift or protocol-based layers.
   - Provide async-friendly facades for SwiftUI (e.g., `@MainActor` methods, async error handling).

---

## 🚀 Migration Milestones

| Milestone | Scope | Expected Outcome |
|-----------|-------|------------------|
| **M1. SwiftUI Shell** | Create `ReaderApp` + `RootContainerView`; bridge existing root controller. | App boots into SwiftUI without breaking legacy flows. |
| **M2. Home Screen Rewrite** | Replace `InputTextController` UI with `InputTextView` + view model. | Modern SwiftUI UI with parity text recognition + navigation hooks. |
| **M3. Choices & Readers** | Port `ReadingChoicesViewController` and reading modes. | SwiftUI navigation with unified design system. |
| **M4. Speech & Settings** | Migrate speech flows, settings forms, banners. | All major user journeys in SwiftUI; UIKit wrappers retired. |
| **M5. Polish & Cleanup** | Remove unused UIKit assets, deprecate storyboard, update tests/docs. | Fully SwiftUI-driven app with simplified codebase. |

---

## 🧪 Testing & Tooling

- Add snapshot tests for SwiftUI views using `XCTest` + `ViewImageSnapshot`.
- Reuse existing unit tests; add new tests for view models (async behavior, OCR pipeline).
- Set up UI previews guarded by `#if DEBUG` to match design system colors/typography.

---

## 📋 Immediate Next Actions

1. Introduce `ReaderApp.swift` and convert `AppDelegate` to be delegate-only (remove `@UIApplicationMain`). ✅
2. Scaffold `RootContainerView` + `RootCoordinator` (ObservableObject) with temporary wrapper for `InputTextController`. ✅
3. Begin MVVM extraction for input screen (`InputTextViewModel`) to enable SwiftUI rewrite. ✅
4. Replace Reading Choices UI with SwiftUI (`ReadingChoicesView` + view model) and bridge legacy reading modes. ⏳ In Progress
5. Migrate speech, speed read, and scroll reading experiences to SwiftUI-native implementations. 🔜

---

## ✅ Progress Update (Nov 3, 2025)

- SwiftUI app entry point (`ReaderApp`) now ships with the Input workflow fully rewritten in SwiftUI.
- New `ReadingChoicesView` + `ReadingChoicesViewModel` deliver the choice experience with modern styling, interstitial ad parity, and SwiftUI navigation.
- Legacy reading modes (speech, speed, scroll) are bridged via `UIViewControllerRepresentable` while their UIKit implementations are refactored for delegation-friendly interoperability.

---

## 📚 References

- Phase 1 SPM migration notes → `PHASE1_SPM_MIGRATION.md`
- Existing UIKit controllers → `Reader/Controllers`
- Shared services/utilities → `Reader/Managers`, `Reader/Utilities`

---

> This plan treats SwiftUI migration as an incremental refactor, ensuring the app stays releasable at each milestone. Update this document as milestones complete.
