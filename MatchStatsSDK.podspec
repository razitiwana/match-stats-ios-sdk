# Validation and publishing commands:
# pod lib lint --platforms=ios --skip-import-validation --allow-warnings
# pod trunk push MatchStatsSDK.podspec --platforms=ios --skip-import-validation --allow-warnings

Pod::Spec.new do |s|
  s.name             = 'MatchStatsSDK'
  s.version          = '1.0.2'
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
