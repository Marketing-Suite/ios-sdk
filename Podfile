platform :ios, '10.0'
inhibit_all_warnings!
use_frameworks!
source 'https://github.com/CocoaPods/Specs.git'

def development_pod
  pod 'Alamofire', '4.9.1'
end

target 'EMSMobileSDK' do
  development_pod
  target 'EMSMobileSDKTests' do
    inherit! :search_paths
    development_pod
  end
end
