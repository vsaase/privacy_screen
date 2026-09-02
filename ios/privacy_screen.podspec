#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint privacy_screen.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'privacy_screen'
  s.version          = '0.0.8'
  s.summary          = 'Flutter privacy screen and native lifecycle plugin.'
  s.description      = <<-DESC
Provides a native privacy overlay, screenshot protection, and lifecycle-based
automatic lock triggers for Flutter applications.
                       DESC
  s.homepage         = 'https://github.com/eddyuan/privacy_screen'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = 'eddyuan'
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*', 'privacy_screen/Sources/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
