Pod::Spec.new do |s|
  s.name             = 'DictionaryCoder'
  s.version          = '1.0.0'
  s.summary          = 'Encode and decode Codable types directly to/from Swift dictionaries'
  s.description      = <<-DESC
    DictionaryCoder provides DictionaryEncoder and DictionaryDecoder to encode and decode
    Codable types directly to/from Swift dictionaries ([String: Any]), without requiring
    JSON serialization. This is useful when working with native Swift dictionaries from
    APIs, databases, or other sources that don't use JSON.
  DESC

  s.homepage         = 'https://github.com/dalemyers/DictionaryCoder'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dale Myers' => 'dale@myers.io' }
  s.source           = { :git => 'https://github.com/dalemyers/DictionaryCoder.git', :tag => "v#{s.version}" }

  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'
  s.tvos.deployment_target = '15.0'
  s.watchos.deployment_target = '8.0'
  s.visionos.deployment_target = '1.0'

  s.swift_versions = ['5.9', '6.0']

  s.source_files = 'Sources/**/*.swift'
  
  s.frameworks = 'Foundation'
end
