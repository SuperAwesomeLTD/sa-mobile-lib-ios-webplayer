Pod::Spec.new do |s|
  s.name = 'SAWebPlayer'
  s.version = '1.2.4'
  s.summary = 'The SuperAwesome custom extension of iOS UIWebView'
  s.description = <<-DESC
     The SuperAwesome custom extension of iOS UIWebView - optimised to display rich media ads
                       DESC
  s.homepage = 'https://github.com/SuperAwesomeLTD/sa-mobile-lib-ios-webplayer'
  s.license = { 
	:type => 'GNU GENERAL PUBLIC LICENSE Version 3', 
	:file => 'LICENSE' 
  }
  s.author = { 
	'Gabriel Coman' => 'gabriel.coman@superawesome.tv' 
  }
  s.source = { 
	:git => 'https://github.com/SuperAwesomeLTD/sa-mobile-lib-ios-webplayer.git', 
	:branch => 'master',
	:tag => '1.2.4' 
  }
  s.platform = :ios, '8.0'
  s.requires_arc = true
  s.dependency 'SANetworking', '1.0.0'
  s.source_files = 'Pod/Classes/**/*'
end
