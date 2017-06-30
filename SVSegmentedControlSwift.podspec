#
# Be sure to run `pod lib lint SVSegmentedControlSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SVSegmentedControlSwift'
  s.version          = '0.1.0'
  s.summary          = 'UISegmentedControl replacement which provides more accurate segments width management'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/svilon/SVSegmentedControlSwift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Eugene Shevtsov' => 'i.i.shevtsov@gmail.com' }
  s.source           = { :git => 'https://github.com/svilon/SVSegmentedControlSwift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.module_name  = 'SVSegmentedControl'

  s.source_files = 'SVSegmentedControlSwift/Classes/**/*'
  
  s.frameworks = 'UIKit'
end
