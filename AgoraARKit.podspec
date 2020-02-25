#
#  Be sure to run `pod spec lint AgoraARKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name               = "AgoraARKit"
  spec.version            = "1.0.2"
  spec.summary            = "AgoraARKit provides extendable implemention of the Agora.io Video SDK with ARKit."
  spec.description        = <<-DESC
                              AgoraARKit provides a bare bones implementation of the Agora.io Video SDK using ARKit as the video source. This framework uses a custom renderer (ARVideoKit) to generate a rendered video buffer of the ARSession, which is passed to the active Agora video stream.
                              DESC
  spec.homepage           = "https://github.com/AgoraIO-Community/Agora-ARKit"
  # spec.screenshots      = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  spec.license            = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "Hermes" => "hermes@agora.io" }
  spec.social_media_url   = "https://github.com/digitallysavvy"
  spec.platform           = :ios, "12.2"
  spec.swift_version      = "4.2"
  spec.requires_arc       = true
  spec.static_framework = true
  spec.source             = { :git => "https://github.com/AgoraIO-Community/Agora-ARKit.git", :tag => "#{spec.version}" }
  spec.source_files       = 'AgoraARKit/**/*.{swift}' 
  spec.frameworks         = [
                              'ARKit',
                              'SceneKit',
                              'UIKit',
                              'CoreGraphics',
                              'Foundation',
                              # 'AgoraRtcEngine_iOS' 
                            ]
  spec.dependency 'AgoraRtcEngine_iOS' 
  spec.dependency 'ARVideoKit','~> 1.51' 
  
  # spec.framework = "AgoraRtcEngine_iOS"                      
end
