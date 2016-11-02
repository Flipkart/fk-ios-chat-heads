#
# Be sure to run `pod lib lint FCChatHeads.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "FCChatHeads"
  s.version          = "1.0.1"
  s.summary          = "Library to use chat heads within your iOS app."
  s.description      = <<-DESC
                        Library to use chat heads within your iOS app with complete physics and animations which drive multi user chat behaviour to support collapsed/stacked or expanded states.
                        DESC
  s.homepage         = "git@github.com:Flipkart/fk-ios-chat-heads"
  s.license          = 'Apache License Version 2.0'
  s.author           = { "Rajat Gupta" => "rajat.g@flipkart.com" }
  s.source           = { :git => "https://github.com/Flipkart/fk-ios-chat-heads.git", :tag => s.version.to_s }

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'FCChatHeads' => ['Pod/Assets/*.png']
  }

  s.frameworks = 'UIKit'
  s.dependency 'pop', '~> 1.0'
  s.dependency 'CMPopTipView'

end
