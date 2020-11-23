
Pod::Spec.new do |s|
  s.name             = 'AnyCoder'
  s.version          = '0.1.0'
  s.summary          = 'A short description of AnyCoder.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/pozi119/AnyCoder'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pozi119' => 'pozi119@163.com' }
  s.source           = { :git => 'https://github.com/pozi119/AnyCoder.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'AnyCoder/Classes/**/*'
  
end
