platform :ios, '13.0'

source "https://github.com/CocoaPods/Specs.git"

target 'VBotPhoneSDK-Example' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'VBotPhoneSDKiOS-Public', :git => 'https://github.com/VBotDevTeam/VBotPhoneSDKiOS-Public.git', :tag => '1.1.11'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
   target.build_configurations.each do |config|
     # Bắt buộc
     config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end
