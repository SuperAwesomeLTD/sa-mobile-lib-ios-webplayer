# Be sure to run `pod lib lint SAWebPlayer.podspec --allow-warnings'
Pod::Spec.new do |s|
  s.name             = "SAWebPlayer"
  s.version          = "1.0.0"
  s.summary          = "The SuperAwesome custom extension of iOS UIWebView - optimised to display rich media ads"
  s.description      = <<-DESC
                       The SuperAwesome custom extension of iOS UIWebView - optimised to display rich media ads
                       DESC
  s.homepage         = "https://github.com/SuperAwesomeLTD/sa-mobile-lib-ios-webplayer"
  s.license          = { :type => "GNU GENERAL PUBLIC LICENSE Version 3", :file => "LICENSE" }
  s.author           = { "Gabriel Coman" => "gabriel.coman@superawesome.tv" }
  s.source           = { :git => "https://github.com/SuperAwesomeLTD/sa-mobile-lib-ios-webplayer.git", :tag => "1.0.0" }
  s.platform     = :ios, '6.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/*'
  s.resource_bundles = {
    'SAWebPlayer' => ['Pod/Assets/*']
  }
end