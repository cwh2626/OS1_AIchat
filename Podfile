# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'chat_AI' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for chat_AI
  pod 'lottie-ios'
  pod 'FMDB'
  pod 'RxSwift', '~> 6.0'
  pod 'RxCocoa', '~> 6.0'
  pod 'Google-Mobile-Ads-SDK'
  pod 'SnapKit', '~> 5.0'



  target 'chat_AITests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'chat_AIUITests' do
    # Pods for testing
  end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end
  
  
end


