#
# Be sure to run `pod lib lint SplitViewTest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SplitView'
  s.version          = '1.0.0'
  s.summary          = 'A resizable Split View'
  s.swift_versions   = ['5.0']

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

  s.source_files = 'splitview/*'
  s.exclude_files = [ 'splitview/Info.plist']

  s.public_header_files = 'splitview/*.h'
  s.frameworks = 'UIKit'
end
