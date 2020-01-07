platform :ios, '10.0'
inhibit_all_warnings!
source 'https://github.com/CocoaPods/Specs.git'

def development_pod
  pod 'Alamofire', '4.9.1'
end

target 'EMSMobileSDK' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for EMSMobileSDK
  development_pod

  target 'EMSMobileSDKTests' do
  	inherit! :search_paths
  	development_pod
  end

end
