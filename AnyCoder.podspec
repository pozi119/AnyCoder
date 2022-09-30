
Pod::Spec.new do |s|
  s.name             = 'AnyCoder'
  s.version          = '0.1.3'
  s.summary          = 'A short description of AnyCoder.'

  s.description      = <<-DESC
                       encode & decode any object.
                       DESC

  s.homepage         = 'https://github.com/pozi119/AnyCoder'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pozi119' => 'pozi119@163.com' }
  s.source           = { :git => 'https://github.com/pozi119/AnyCoder.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.watchos.deployment_target = '3.0'

  s.source_files = 'AnyCoder/Classes/**/*'
  s.dependency 'Runtime'

end
