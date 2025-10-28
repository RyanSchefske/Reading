# Phase 1: Swift Package Manager Migration

**Branch:** `feature/modernization-phase1-spm`
**Status:** In Progress
**Created:** 2025-10-27

---

## 📊 Dependency Audit Results

### Current CocoaPods Dependencies (from Podfile.lock)

| Dependency | Version | SPM Available? | Action | SPM URL/Notes |
|------------|---------|----------------|--------|---------------|
| **Firebase/Core** | 6.5.0 → 11.x | ✅ Yes | Update & Migrate | `https://github.com/firebase/firebase-ios-sdk` |
| **Firebase/Analytics** | 6.5.0 → 11.x | ✅ Yes | Update & Migrate | Part of Firebase SDK |
| **Firebase/AdMob** | 6.5.0 | ✅ Yes (now separate) | Update & Migrate | Use GoogleMobileAds SPM |
| **Firebase/MLVision** | 0.17.0 | ❌ **DEPRECATED** | **REPLACE** | Use Apple Vision Framework (native) |
| **Firebase/MLVisionTextModel** | 0.17.0 | ❌ **DEPRECATED** | **REPLACE** | Use Apple Vision Framework (native) |
| **Google-Mobile-Ads-SDK** | 7.51.0 → 11.x | ✅ Yes | Update & Migrate | `https://github.com/googleads/swift-package-manager-google-mobile-ads` |
| **WeScan** | 1.1.0 → 2.0+ | ✅ Yes | Update & Migrate | `https://github.com/WeTransfer/WeScan` |
| **MarqueeLabel** | 4.0.0 | ✅ Yes | **REMOVE** | Not used in codebase (dead dependency) |

### Import Statement Locations

**Files requiring import updates:**

1. **AppDelegate.swift:10** - `import Firebase`
   - Change to: `import FirebaseCore`, `import FirebaseAnalytics`

2. **InputTextController.swift:10** - `import FirebaseMLVision`
   - Change to: `import Vision` (Apple's native framework)

3. **ScanViewController.swift:10** - `import WeScan`
   - No change needed (SPM uses same import)

4. **AdMob imports (6 files):**
   - UIView+Ads.swift:9
   - SpeechRecognizerViewController.swift:11
   - SpeechViewController.swift:11
   - SpeedReadViewController.swift:10
   - ReadViewController.swift:10
   - ReadingChoicesViewController.swift:10
   - InputTextController.swift:12
   - Change to: `import GoogleMobileAds` (same name in SPM)

---

## 🎯 Migration Strategy

### Step 1: Remove CocoaPods Infrastructure

```bash
# 1. Remove CocoaPods files
rm -rf Pods/
rm Podfile
rm Podfile.lock
rm -rf Reader.xcworkspace

# 2. Open the .xcodeproj directly (not workspace)
open Reader.xcodeproj
```

### Step 2: Clean Xcode Project

**In Xcode:**
1. Select Reader project in navigator
2. Select Reader target
3. Go to "Build Phases"
4. Remove these CocoaPods-added phases:
   - `[CP] Check Pods Manifest.lock`
   - `[CP] Embed Pods Frameworks`
   - `[CP] Copy Pods Resources`
5. Go to "Build Settings"
   - Search for "Framework Search Paths"
   - Remove any Pods-related paths
6. Go to "General" → "Frameworks, Libraries, and Embedded Content"
   - Remove all Pods.framework entries

### Step 3: Add SPM Dependencies

**File → Add Package Dependencies...**

Add these packages in order:

#### 1. Firebase (11.x)
```
URL: https://github.com/firebase/firebase-ios-sdk
Version: 11.5.0 (or latest)
Products to add:
  - FirebaseCore
  - FirebaseAnalytics
  - FirebaseCrashlytics (NEW - add for crash reporting)
```

#### 2. Google Mobile Ads (11.x)
```
URL: https://github.com/googleads/swift-package-manager-google-mobile-ads
Version: 11.0.0 (or latest)
Products to add:
  - GoogleMobileAds
```

#### 3. WeScan (2.x)
```
URL: https://github.com/WeTransfer/WeScan
Version: 2.0.0 (or latest - check for latest tag)
Products to add:
  - WeScan
```

**Note:** MarqueeLabel will NOT be added - it's unused dead code.

### Step 4: Update Import Statements

#### AppDelegate.swift
```swift
// OLD:
import Firebase

// NEW:
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics  // NEW - for crash reporting
```

**Also update Firebase configuration in AppDelegate:**
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Configure Firebase
    FirebaseApp.configure()

    // Optional: Enable analytics
    Analytics.setAnalyticsCollectionEnabled(true)

    // ... rest of code
}
```

#### InputTextController.swift
```swift
// OLD:
import FirebaseMLVision

// NEW:
import Vision  // Apple's native Vision framework
```

**Code changes required for Vision framework:**
See "Vision Framework Migration" section below for detailed code changes.

#### AdMob Imports (7 files)
```swift
// NO CHANGE NEEDED - already correct:
import GoogleMobileAds
```

**However, AdMob API changes required:**
See "AdMob Migration" section below for API update details.

---

## 🔄 Critical Code Migrations

### 1. Vision Framework Migration (InputTextController.swift)

**Current code location:** InputTextController.swift:250-280 (approximately)

#### OLD CODE (Firebase ML Vision):
```swift
import FirebaseMLVision

class InputTextController {
    func detectText(in image: UIImage) {
        let vision = Vision.vision()
        let textRecognizer = vision.onDeviceTextRecognizer()
        let visionImage = VisionImage(image: image)

        textRecognizer.process(visionImage) { result, error in
            guard error == nil, let result = result else {
                print("Error: \(error?.localizedDescription ?? "unknown")")
                return
            }

            let resultText = result.text
            // Use resultText
        }
    }
}
```

#### NEW CODE (Apple Vision Framework):
```swift
import Vision
import UIKit

class InputTextController {
    func detectText(in image: UIImage) {
        guard let cgImage = image.cgImage else {
            self.showError(AppError.textRecognitionFailed)
            return
        }

        // Create text recognition request
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }

            if let error = error {
                print("Text recognition error: \(error.localizedDescription)")
                self.showError(AppError.textRecognitionFailed)
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                self.showError(AppError.textRecognitionFailed)
                return
            }

            // Extract text from observations
            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")

            // Update UI on main thread
            DispatchQueue.main.async {
                self.textView.text = recognizedText
                // Or whatever you do with the text
            }
        }

        // Configure request for best accuracy
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en-US"]

        // Perform request
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform text recognition: \(error)")
                DispatchQueue.main.async {
                    self.showError(AppError.textRecognitionFailed)
                }
            }
        }
    }

    // Helper method for error display
    private func showError(_ error: AppError) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// Add error type (create new file: Utilities/AppError.swift)
enum AppError: LocalizedError {
    case textRecognitionFailed
    case imageProcessingFailed

    var errorDescription: String? {
        switch self {
        case .textRecognitionFailed:
            return "Unable to recognize text in the image. Please try again with a clearer image."
        case .imageProcessingFailed:
            return "Unable to process the image. Please try again."
        }
    }
}
```

**Search for all Firebase ML Vision usage:**
```bash
grep -r "VisionImage\|VisionText\|TextRecognizer" Reader --include="*.swift"
```

### 2. AdMob Migration (UIView+Ads.swift and 6 ViewControllers)

#### Current Issue: UIView Extension Conformance

**File:** Extensions/UIView+Ads.swift:12

**MAJOR PROBLEM - Current code:**
```swift
import GoogleMobileAds

extension UIView: GADBannerViewDelegate {
    // This makes ALL UIViews conform to GADBannerViewDelegate!
    // This is a code smell and should be fixed
}
```

**Solution: Create AdManager**

**NEW FILE: Managers/AdManager.swift**
```swift
import GoogleMobileAds
import UIKit

/// Centralized manager for Google AdMob integration
final class AdManager: NSObject {

    static let shared = AdManager()

    // Ad Unit IDs (from Info.plist)
    private let bannerAdUnitID = "ca-app-pub-2392719817363402~9276402219"
    private let interstitialAdUnitID = "ca-app-pub-2392719817363402~6341211139"

    #if DEBUG
    // Use test ads in debug mode
    private let testMode = true
    #else
    private let testMode = false
    #endif

    private var interstitialAd: GADInterstitialAd?

    private override init() {
        super.init()
    }

    // MARK: - Banner Ads

    /// Creates and configures a banner ad view
    func createBannerView(
        for viewController: UIViewController,
        delegate: GADBannerViewDelegate? = nil
    ) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = testMode ? "ca-app-pub-3940256099942544/2934735716" : bannerAdUnitID
        bannerView.rootViewController = viewController
        bannerView.delegate = delegate ?? self
        return bannerView
    }

    /// Adds a banner ad to the bottom of a view
    func addBannerToView(
        _ view: UIView,
        viewController: UIViewController,
        delegate: GADBannerViewDelegate? = nil
    ) {
        let bannerView = createBannerView(for: viewController, delegate: delegate)

        view.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bannerView.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Load ad
        bannerView.load(GADRequest())
    }

    // MARK: - Interstitial Ads

    /// Loads an interstitial ad
    func loadInterstitial(completion: ((Bool) -> Void)? = nil) {
        let adUnitID = testMode
            ? "ca-app-pub-3940256099942544/4411468910"  // Test ad unit
            : interstitialAdUnitID

        GADInterstitialAd.load(
            withAdUnitID: adUnitID,
            request: GADRequest()
        ) { [weak self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad: \(error.localizedDescription)")
                completion?(false)
                return
            }

            self?.interstitialAd = ad
            completion?(true)
        }
    }

    /// Shows the loaded interstitial ad
    func showInterstitial(from viewController: UIViewController) {
        guard let interstitialAd = interstitialAd else {
            print("Interstitial ad not loaded")
            // Optionally reload for next time
            loadInterstitial()
            return
        }

        interstitialAd.present(fromRootViewController: viewController)

        // Reload for next time
        loadInterstitial()
    }
}

// MARK: - GADBannerViewDelegate

extension AdManager: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("✅ Banner ad loaded successfully")
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("❌ Banner ad failed to load: \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("📊 Banner ad impression recorded")
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("Banner ad will present screen")
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("Banner ad will dismiss screen")
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("Banner ad dismissed screen")
    }
}
```

#### Update ViewControllers to use AdManager

**Example: InputTextController.swift**

**OLD CODE:**
```swift
import GoogleMobileAds

class InputTextController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Old way - creating banner directly
        let banner = GADBannerView(adSize: kGADAdSizeBanner)
        banner.adUnitID = "ca-app-pub-2392719817363402~9276402219"
        banner.rootViewController = self
        banner.load(GADRequest())
        view.addSubview(banner)
        // ... layout code
    }
}
```

**NEW CODE:**
```swift
import GoogleMobileAds

class InputTextController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // New way - using AdManager
        AdManager.shared.addBannerToView(view, viewController: self)
    }
}
```

**For Interstitial Ads (ReadingChoicesViewController):**

```swift
class ReadingChoicesViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load interstitial ad on view load
        AdManager.shared.loadInterstitial()
    }

    func someAction() {
        // Show interstitial when appropriate
        AdManager.shared.showInterstitial(from: self)
    }
}
```

**Files requiring AdMob updates:**
1. ✅ UIView+Ads.swift - **DELETE THIS FILE** (replaced by AdManager)
2. ✅ InputTextController.swift
3. ✅ SpeechRecognizerViewController.swift
4. ✅ SpeechViewController.swift
5. ✅ SpeedReadViewController.swift
6. ✅ ReadViewController.swift
7. ✅ ReadingChoicesViewController.swift

---

## 📝 Updated .gitignore

**Add SPM-specific entries, remove CocoaPods:**

```gitignore
# Xcode
*.xcodeproj/*
!*.xcodeproj/project.pbxproj
!*.xcodeproj/xcshareddata/
!*.xcworkspace/contents.xcworkspacedata
*.xcworkspace/*
!*.xcworkspace/xcshareddata/
*.xcworkspace/xcshareddata/swiftpm/
xcuserdata/
*.xcuserstate
.swiftpm/

# Swift Package Manager
.build/
.swiftpm/
Package.resolved

# CocoaPods (REMOVED - no longer needed)
# Pods/
# Podfile.lock

# Build artifacts
build/
DerivedData/

# macOS
.DS_Store

# App packaging
*.ipa
*.dSYM.zip
*.dSYM

# Fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output

# Firebase
GoogleService-Info.plist
```

---

## 🏗️ Xcode Project Settings Updates

### Recommended Settings (Xcode 15+)

**Build Settings to update:**

1. **iOS Deployment Target**
   - Current: 13.0
   - New: 15.0
   - Rationale: Modern iOS features, removes legacy code

2. **Swift Language Version**
   - Current: Swift 5
   - New: Swift 5.10 (or latest)

3. **Enable Strict Concurrency**
   - Setting: `SWIFT_STRICT_CONCURRENCY`
   - Value: `complete`
   - Prepares for Swift 6

4. **Enable Complete Strict Concurrency Checking**
   - Setting: Build Settings → Swift Compiler
   - Enable all warnings as errors

5. **Disable Bitcode**
   - Setting: `ENABLE_BITCODE`
   - Value: `NO`
   - Rationale: Deprecated by Apple

6. **Update Build System**
   - File → Project Settings → Build System
   - Use: "New Build System" (default in Xcode 14+)

7. **Enable Thread Sanitizer (Debug)**
   - Edit Scheme → Run → Diagnostics
   - Enable: Thread Sanitizer
   - Helps catch threading issues

8. **Enable Address Sanitizer (Debug)**
   - Edit Scheme → Run → Diagnostics
   - Enable: Address Sanitizer
   - Helps catch memory issues

---

## ✅ Testing Checklist

### After SPM Migration:

- [ ] **Clean build succeeds**
  ```bash
  # In Xcode: Cmd+Shift+K (Clean Build Folder)
  # Then: Cmd+B (Build)
  ```

- [ ] **No import errors**
  - All Firebase imports resolved
  - All AdMob imports resolved
  - WeScan import resolved
  - Vision framework import resolved

- [ ] **Test on simulator**
  - iPhone 15 Pro (iOS 17.x)
  - iPhone 15 (iOS 17.x)
  - iPad Pro (iOS 17.x)

- [ ] **Test core features:**
  - [ ] Text input works
  - [ ] Document scanning works (camera permission)
  - [ ] OCR text recognition works (with Vision framework)
  - [ ] Speech-to-text works (microphone permission)
  - [ ] Text-to-speech works
  - [ ] Speed reading mode works
  - [ ] Scrolling reading mode works
  - [ ] Banner ads display (in test mode)
  - [ ] Interstitial ads display (in test mode)

- [ ] **Firebase Analytics working**
  - Check Firebase Console for events
  - Test event logging

- [ ] **No memory leaks**
  - Run with Instruments → Leaks
  - Check for retain cycles

- [ ] **No warnings**
  - Zero compiler warnings
  - Zero linker warnings

---

## 📋 Step-by-Step Execution Plan

### Day 1: Setup & Cleanup (2-3 hours)

1. ✅ **Create branch** (DONE)
   ```bash
   git checkout -b feature/modernization-phase1-spm
   ```

2. **Backup workspace**
   ```bash
   git add -A
   git commit -m "Backup: Pre-SPM migration state"
   ```

3. **Update .gitignore**
   - Add SPM entries
   - Remove CocoaPods entries
   ```bash
   git add .gitignore
   git commit -m "Update .gitignore for SPM"
   ```

4. **Close Xcode**
   - Save all work
   - Quit Xcode completely

5. **Remove CocoaPods**
   ```bash
   cd /Users/ryanschefske/Developer/Reading
   rm -rf Pods/
   rm Podfile
   rm Podfile.lock
   rm -rf Reader.xcworkspace
   git add -A
   git commit -m "Remove CocoaPods infrastructure"
   ```

6. **Open .xcodeproj**
   ```bash
   open Reader.xcodeproj
   ```

7. **Clean CocoaPods Build Phases**
   - In Xcode project navigator → Reader target → Build Phases
   - Delete: `[CP] Check Pods Manifest.lock`
   - Delete: `[CP] Embed Pods Frameworks`
   - Delete: `[CP] Copy Pods Resources`
   - Commit:
   ```bash
   git add -A
   git commit -m "Remove CocoaPods build phases"
   ```

### Day 2: Add SPM Dependencies (2-3 hours)

8. **Add Firebase SDK**
   - File → Add Package Dependencies
   - URL: `https://github.com/firebase/firebase-ios-sdk`
   - Version: 11.5.0 (or latest)
   - Select products: FirebaseCore, FirebaseAnalytics, FirebaseCrashlytics
   - Wait for resolution (may take 5-10 minutes)

9. **Add Google Mobile Ads**
   - File → Add Package Dependencies
   - URL: `https://github.com/googleads/swift-package-manager-google-mobile-ads`
   - Version: 11.0.0 (or latest)
   - Select product: GoogleMobileAds

10. **Add WeScan**
    - File → Add Package Dependencies
    - URL: `https://github.com/WeTransfer/WeScan`
    - Version: 2.0.0+ (check for latest release)
    - Select product: WeScan

11. **Commit SPM dependencies**
    ```bash
    git add Reader.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
    git add Reader.xcodeproj/project.pbxproj
    git commit -m "Add SPM dependencies: Firebase 11.x, GoogleMobileAds 11.x, WeScan 2.x"
    ```

### Day 3: Update Code (3-4 hours)

12. **Create AdManager**
    - Create file: `Reader/Managers/AdManager.swift`
    - Copy code from "AdMob Migration" section above
    - Commit:
    ```bash
    git add Reader/Managers/AdManager.swift
    git commit -m "Add AdManager to centralize AdMob integration"
    ```

13. **Create AppError**
    - Create file: `Reader/Utilities/AppError.swift`
    - Copy code from "Vision Framework Migration" section above
    - Commit:
    ```bash
    git add Reader/Utilities/AppError.swift
    git commit -m "Add AppError enum for error handling"
    ```

14. **Update AppDelegate**
    - Update imports
    - Update Firebase initialization
    - Test build
    - Commit:
    ```bash
    git add Reader/SupportFiles/AppDelegate.swift
    git commit -m "Update AppDelegate for Firebase 11.x"
    ```

15. **Update InputTextController (Vision Framework)**
    - Replace Firebase ML Vision with Apple Vision
    - Update text recognition code
    - Update AdMob usage to use AdManager
    - Test OCR functionality
    - Commit:
    ```bash
    git add Reader/Controllers/InputTextController.swift
    git commit -m "Migrate to Apple Vision framework, use AdManager"
    ```

16. **Update remaining ViewControllers (AdMob)**
    - SpeechRecognizerViewController.swift
    - SpeechViewController.swift
    - SpeedReadViewController.swift
    - ReadViewController.swift
    - ReadingChoicesViewController.swift
    - Replace direct AdMob calls with AdManager
    - Commit each file or commit all together:
    ```bash
    git add Reader/Controllers/*.swift
    git commit -m "Update all view controllers to use AdManager"
    ```

17. **Delete UIView+Ads.swift**
    ```bash
    git rm Reader/Extensions/UIView+Ads.swift
    git commit -m "Remove UIView+Ads extension (replaced by AdManager)"
    ```

### Day 4: Testing & Fixes (2-4 hours)

18. **Clean Build**
    - Cmd+Shift+K (Clean Build Folder)
    - Cmd+B (Build)
    - Fix any compiler errors

19. **Run on Simulator**
    - iPhone 15 Pro (iOS 17)
    - Test all features from checklist

20. **Fix Issues**
    - Address any runtime errors
    - Test OCR thoroughly
    - Test ads (use test mode)
    - Check Firebase Analytics in console

21. **Update Project Settings**
    - Set iOS deployment target to 15.0
    - Enable strict concurrency checking
    - Update Swift language version
    - Commit:
    ```bash
    git add Reader.xcodeproj/project.pbxproj
    git commit -m "Update Xcode project settings: iOS 15.0, Swift 5.10"
    ```

22. **Final Testing**
    - Run full test pass
    - Check for memory leaks with Instruments
    - Verify no warnings

23. **Merge to main**
    ```bash
    git checkout master
    git merge feature/modernization-phase1-spm
    git push origin master
    ```

---

## 🎯 Success Criteria

Phase 1 is complete when:

- ✅ All CocoaPods infrastructure removed
- ✅ All dependencies managed by SPM
- ✅ Firebase 11.x integrated and working
- ✅ Google Mobile Ads 11.x integrated and working
- ✅ WeScan 2.x integrated and working
- ✅ Firebase ML Vision replaced with Apple Vision framework
- ✅ AdManager created and implemented
- ✅ Zero compiler warnings
- ✅ All features tested and working
- ✅ iOS deployment target updated to 15.0
- ✅ Project settings modernized
- ✅ Changes committed and merged

---

## 📞 Next Steps (Phase 2+)

After Phase 1 is complete, proceed to:

- **Phase 2:** iOS Modernization
  - Scene Delegate implementation
  - Dark Mode support
  - Fix deprecated APIs
  - Async/await migration

- **Phase 3:** Code Quality
  - SwiftLint integration
  - Memory leak fixes
  - Error handling improvements
  - MVVM refactoring

- **Phase 4:** Testing Infrastructure
  - Unit tests
  - UI tests
  - CI/CD pipeline

---

## 🐛 Known Issues & Troubleshooting

### Issue: SPM package resolution fails

**Solution:**
```bash
# Clear SPM cache
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/Library/org.swift.swiftpm

# In Xcode: File → Packages → Reset Package Caches
```

### Issue: Firebase not initializing

**Solution:**
- Verify `GoogleService-Info.plist` is in project
- Verify it's added to target membership
- Check Firebase console for correct project

### Issue: AdMob ads not showing

**Solution:**
- Verify test ad units are used in DEBUG mode
- Check network connection
- Check ad unit IDs match Firebase Console
- Wait 24 hours after creating new ad units

### Issue: Vision framework not recognizing text

**Solution:**
- Check image quality
- Try different `recognitionLevel` (.fast vs .accurate)
- Check for proper error handling
- Verify camera permission granted

### Issue: Build errors after SPM migration

**Solution:**
```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# In Xcode:
# Product → Clean Build Folder (Cmd+Shift+K)
# File → Packages → Reset Package Caches
# Quit Xcode, reopen, build again
```

---

## 📚 References

- [Firebase iOS SDK (SPM)](https://github.com/firebase/firebase-ios-sdk)
- [Google Mobile Ads SPM](https://github.com/googleads/swift-package-manager-google-mobile-ads)
- [WeScan GitHub](https://github.com/WeTransfer/WeScan)
- [Apple Vision Framework Docs](https://developer.apple.com/documentation/vision)
- [Firebase Migration Guide](https://firebase.google.com/docs/ios/migration)
- [AdMob iOS Migration Guide](https://developers.google.com/admob/ios/migration)

---

**Last Updated:** 2025-10-27
**Author:** Claude Code Assistant
**Status:** Ready for execution
