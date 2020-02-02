Pod::Spec.new do |s|
  s.name             = 'SemanticString'
  s.version          = '0.22.0'
  s.summary          = 'String abstraction for easy text localization and stylization'
  s.description      = <<-DESC
  SemanticString allows mark some text regions with desired styles, for example, "bold".
  Also, it provides a way to create language-independent strings, that can be used in apps that supports change language dynamically.
                       DESC
  s.homepage         = 'https://github.com/BlowMindStyle/SemanticString'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Gotyanov' => 'Aleksey.Gotyanov@gmail.com' }
  s.source           = { :git => 'https://github.com/BlowMindStyle/SemanticString.git', :tag => s.version.to_s }

  s.requires_arc          = true

  s.ios.deployment_target = '10.0'

  s.source_files = 'Sources/SemanticString/**/*.swift'
  s.swift_version = '5.1'
end
