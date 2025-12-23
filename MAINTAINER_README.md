# Match Stats SDK – Maintainer Guide (updated)

Short, current process for producing and shipping the SDK (MatchStatsSDK + UnityFramework) for CocoaPods distribution.

## Prereqs
- Unity 2021.3+ (iOS, IL2CPP, arm64)
- Xcode 15/16 (iOS device + simulator SDKs)
- macOS with CocoaPods

## Build pipeline (high level)
1) Export Unity project for iOS (device, arm64).  
2) In the generated Xcode project, remove the legacy `-ld64` flag from **UnityFramework** target → Build Settings → Other Linker Flags.  
3) Add the Unity `Data` folder to **UnityFramework** target membership (Copy Bundle Resources).  
4) Create a new iOS Framework target `MatchStatsSDK`; add `MatchStatsSDK.h`, `MatchStatsSDK.mm`, and `module.modulemap` to that target.  
5) Link `UnityFramework.framework` to `MatchStatsSDK` (Build Phases → Embeded Frameworks).
6) Link `UIKitFramework.framework` to `MatchStatsSDK` (Build Phases → Link Binary With Libraries)
7) Build device for both frameworks; create xcframeworks; strip signatures.  
8) Package for CocoaPods (podspec + zip or local path).  
9) Validate with a sample app (`use_frameworks!`, embed & sign both).

## Detailed steps

### 1. Export from Unity
- Platform: iOS, Architecture: arm64, Scripting Backend: IL2CPP.
- Build → Xcode project (not workspace). Keep the Data folder in the output.

### 2. Fix UnityFramework linker flag
- Open the generated Xcode project.
- Target: **UnityFramework** → Build Settings → Other Linker Flags → remove `-ld64` (Xcode 16 no longer supports it).

### 3. Add Data folder to UnityFramework
- In Project Navigator, select `Data` folder → File Inspector → Target Membership: check **UnityFramework** (uncheck Unity-iPhone).
- Verify: UnityFramework → Build Phases → Copy Bundle Resources contains `Data`.

### 4. Create the MatchStatsSDK target
- Add new target: iOS Framework, name `MatchStatsSDK`, ObjC.
- Add files to the target: `SDK/MatchStatsSDK.h`, `SDK/MatchStatsSDK.mm`, `SDK/module.modulemap`.
- Build settings: Defines Module = YES; iOS Deployment Target >= 13.

### 5. Link UnityFramework (no nesting)
- MatchStatsSDK target → Build Phases → Embeded Frameworks: add `UnityFramework.framework`.
- Framework Search Paths: include `$(BUILT_PRODUCTS_DIR)`.
- Do **not** add `-framework UnityFramework` to Other Linker Flags.
- The SDK code now prefers `App.app/Frameworks/UnityFramework.framework`, falling back to SDK-nested locations.

### 6. Link UIKitFramework
- MatchStatsSDK target → Build Phases → Link Binary With Libraries: add `UIKitFramework.framework`.

### 7. Build artifacts
- Build UnityFramework (device).
- Build MatchStatsSDK (device).
- Create xcframeworks:
  - `MatchStatsSDK.xcframework` from the two MatchStatsSDK builds.
  - `UnityFramework.xcframework` from the two UnityFramework builds.

### 8. Pod packaging
- Layout for distribution zip:
  - `MatchStatsSDK.xcframework`
  - `UnityFramework.xcframework`
  - `MatchStatsSDK.podspec`
  - `LICENSE` (if required)
- Example podspec (local dev uses `:path => './'`; hosted uses `:http` zip):
```ruby
Pod::Spec.new do |s|
  s.name             = 'MatchStatsSDK'
  s.version          = '1.0.1'
  s.summary          = 'Match Stats SDK'
  s.description      = 'Unity-based Match Stats SDK.'
  s.homepage         = 'https://github.com/razitiwana/match-stats-ios-sdk'
  s.author           = { 'razitiwana' => 'mrazullah111@gmail.com' }
  
  # Use the current repo as the source when developing locally.
  #s.source           = { :path => './' }
  s.source           = {
    :git => 'https://github.com/razitiwana/match-stats-ios-sdk.git',
    :tag => s.version.to_s
  }

  s.platform     = :ios, '13.0'
  s.requires_arc = true
  s.static_framework = false # UnityFramework must stay dynamic
  
  # Exclude simulator architectures - only support arm64 devices
  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 x86_64'
  }
  s.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 x86_64'
  }

  # Point at the actual prebuilt frameworks in the repo.
  s.vendored_frameworks = 'MatchStatsSDK.framework', 'UnityFramework.framework'
end
```

### 9. Pod validation and publish
- Local consume: `pod install` with `pod 'MatchStatsSDK', :path => '../relative/path'`
- Lint: `pod lib lint MatchStatsSDK.podspec --skip-tests --allow-warnings`
- Publish to private spec repo: `pod repo push <spec-repo> MatchStatsSDK.podspec --skip-tests --allow-warnings`
- Hosted zip: upload xcframework zip; update `s.source` to `:http`.

### 10. Quick consume checklist
- Podfile: `platform :ios, '13.0'`, `use_frameworks!`
- After `pod install`, verify in Xcode:
  - `MatchStatsSDK.framework` → Embed & Sign
  - `UnityFramework.framework` → Embed & Sign
- Ensure app Info.plist has `NSCameraUsageDescription` (SDK uses camera).
- Supported orientations must overlap Unity’s (see developer README for fix).

## Troubleshooting (maintainer-side)
- `-ld64` build failure: remove flag from UnityFramework Other Linker Flags.
- UnityFramework not found at runtime: confirm it’s embedded at `App.app/Frameworks/UnityFramework.framework`.
- Data folder missing: ensure target membership + Copy Bundle Resources on UnityFramework.
- Orientation crash in sample app: align supported orientations between app and Unity (details in developer README).

## Files to keep in repo
- `SDK/MatchStatsSDK.h`
- `SDK/MatchStatsSDK.mm`
- `SDK/module.modulemap`
- `MatchStatsSDK.podspec` (when ready)
- Built frameworks/xcframeworks (or placeholders ignored in git if large)

