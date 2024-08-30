# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

# ignore all warnings from all pods
inhibit_all_warnings!

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      if config.name == 'Debug'
        config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
    end
  end
end

target 'Meme' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'Moya/RxSwift', '~> 15.0'
  pod 'RxSwift', '6.7.1'
  pod 'RxCocoa', '6.7.1'
  pod 'Kingfisher', '~> 7.0'
  pod "RxGesture", '4.0.4'
  pod 'SVProgressHUD'
  pod 'SnapKit', '~> 5.7.0'


  target 'MemeTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MemeUITests' do
    # Pods for testing
  end

end
