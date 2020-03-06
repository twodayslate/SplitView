#
# Be sure to run `pod lib lint SplitViewTest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SplitView'
  s.version          = '2.0.1'
  s.summary          = 'A resizable Split View'
  s.swift_versions   = ['4.2', '5.0', '5.1']

  s.description      = <<-DESC
A resizable Split View inspired by Apple's Split View for iPadOS
                       DESC

  s.homepage         = 'https://github.com/twodayslate/SplitView'
  s.screenshots     = 'https://github.com/twodayslate/SplitView/raw/master/images/horizontal.png', 'https://github.com/twodayslate/SplitView/raw/master/images/vertical.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'twodayslate' => 'zac@gorak.us' }
  s.source           = { :git => 'https://github.com/twodayslate/SplitView.git', :tag => "v#{s.version}" }
  s.social_media_url = 'https://twitter.com/twodayslate'

  s.ios.deployment_target = '11.0'
  #s.osx.deployment_target = '10.15'

  s.source_files = 'SplitView/*'
  s.exclude_files = [ 'SplitView/Info.plist']

  s.public_header_files = 'splitview/*.h'
  s.frameworks = 'UIKit'
end
