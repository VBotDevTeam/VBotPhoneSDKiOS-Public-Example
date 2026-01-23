# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

source "https://github.com/CocoaPods/Specs.git"

target 'VBotPhoneSDK-Example' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'VBotPhoneSDKiOS-Public', '1.1.4'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
   target.build_configurations.each do |config|
     # Bắt buộc
     config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end
