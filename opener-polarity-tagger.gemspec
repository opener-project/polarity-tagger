require File.expand_path('../lib/opener/polarity_tagger/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'opener-polarity-tagger'
  gem.version     = Opener::PolarityTagger::VERSION
  gem.authors     = ['development@olery.com']
  gem.summary     = 'Polarity tagger for various languages.'
  gem.description = gem.summary
  gem.homepage    = 'http://opener-project.github.com/'
  gem.extensions  = ['ext/hack/Rakefile']

  gem.required_ruby_version = '>= 1.9.2'

  gem.files = Dir.glob([
    'core/site-packages/pre_build/**/*',
    'core/*',
    'ext/**/*',
    'lib/**/*',
    'config.ru',
    '*.gemspec',
    '*_requirements.txt',
    'README.md'
  ]).select { |file| File.file?(file) }

  gem.executables = Dir.glob('bin/*').map { |file| File.basename(file) }

  gem.add_dependency 'opener-build-tools', ['>= 0.2.7']
  gem.add_dependency 'rake'
  gem.add_dependency 'sinatra'
  gem.add_dependency 'httpclient'
  gem.add_dependency 'puma'
  gem.add_dependency 'opener-webservice'
  gem.add_dependency 'opener-core'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'cucumber'
end
