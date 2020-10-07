# Uncomment the next line to define a global platform for your project
 platform :ios, '12.0'

target 'Le Frame' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Le Frame
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'Google-Mobile-Ads-SDK'
pod 'ShowTime'
pod 'Instructions', '~> 2.0.0'
pod 'lottie-ios'

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
  end
end

end
