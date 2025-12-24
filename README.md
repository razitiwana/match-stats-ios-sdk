# MatchStatsSDK – App Integration (Pods)

Use this guide when integrating the SDK into an iOS app via CocoaPods.

## Install via CocoaPods
- Podfile:
```ruby
platform :ios, '13.0'
use_frameworks!

target 'YourApp' do
  pod 'MatchStatsSDK', :git => 'https://github.com/razitiwana/match-stats-ios-sdk.git', :tag => '1.0.2'
end

```
- Run `pod install` and open the generated `.xcworkspace`.

## 🔄 Updating the SDK

Once the one-time setup is complete, *updating the SDK does NOT require repeating any setup steps*.

To update:
1. Open your `Podfile`
2. Change the version number only in the tag:

```ruby
target 'YourApp' do
  pod 'MatchStatsSDK', :git => 'https://github.com/razitiwana/match-stats-ios-sdk.git', :tag => '1.0.3'
end
```

3. Run `pod install` to update the SDK

**Note:** All other configuration (Info.plist entries, build settings, etc.) remains unchanged when updating versions.

## Required Info.plist entries
- Add a camera usage description (the SDK uses the camera) in Info.plist:
  - Key: `NSCameraUsageDescription`
  - Value: `"Camera access is required for match stats."`

### Troubleshooting Build Issues

#### Sandbox Permission Errors (Xcode 15+)

If you encounter sandbox permission errors during build, such as:
```
error: Sandbox: rsync(XXXXX) deny(1) file-write-create ...
rsync(XXXXX): error: mkstempat: '...': Operation not permitted
```

**Workaround:** Disable User Script Sandboxing in Xcode:

1. Open your project in Xcode
2. Select your project in the Project Navigator
3. Select your target
4. Go to **Build Settings** tab
5. Search for `ENABLE_USER_SCRIPT_SANDBOXING`
6. Set it to **No** for both Debug and Release configurations

**Note:** Disabling sandboxing reduces security but is required due to CocoaPods' use of `rsync` which creates temporary files that are blocked by Xcode's sandbox. This is a known limitation when using nested frameworks with CocoaPods.

**Alternative steps:**
- Clean build folder: Product → Clean Build Folder (Cmd+Shift+K)
- Run `pod deintegrate && pod install` to regenerate scripts
- Rebuild the project

#### Supported orientations (avoid Unity crash)
- The app and Unity must share at least one supported orientation. If they do not, you can see:
  - `Supported orientations has no common orientation with the application, and [UnityDefaultViewController shouldAutorotate] is returning YES`
- Recommended fixes:
  - Ensure the app target supports `Portrait` and `LandscapeLeft`/`LandscapeRight` (match Unity Player Settings).

## Usage example
```swift
import UIKit
import MatchStatsSDK

class ViewController: UIViewController {
    @IBAction func launchMatchStats() {
        MatchStatsSDKManager.sharedInstance().launchUnity { success in
            print("Unity launch result: \(success)")
        }
    }
}
```

## Limitations

- **Device Only**: The SDK works only on physical iOS devices. It will not work in the iOS Simulator.

## Quick checklist
- Pod installed with `use_frameworks!` (CocoaPods will automatically embed frameworks).
- `NSCameraUsageDescription` present.
- Orientations overlap with Unity (avoid crash).
- Run on device after first install (camera permission prompt). 

## Version

Current version: **1.0.2**
