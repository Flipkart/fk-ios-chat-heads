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
  s.version          = "1.0"
  s.summary          = "Chat heads like facebook messanger"
  s.description      = <<-DESC
                        Chat heads implemented for iOS using POP.
                        DESC
  s.homepage         = "https://github.com/Flipkart/fk-ios-chat-heads"
  s.license          = 'MIT'
  s.author           = { "Rajat Gupta" => "rajat.g@flipkart.com" }
  s.source           = { :git => "https://github.com/Flipkart/fk-ios-chat-heads.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'FCChatHeads' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'pop', '~> 1.0'
  s.dependency 'CMPopTipView'

end
