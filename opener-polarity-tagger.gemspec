require File.expand_path('../lib/opener/polarity_tagger/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'opener-polarity-tagger'
  gem.version     = Opener::PolarityTagger::VERSION
  gem.authors     = ['development@olery.com']
  gem.summary     = 'Polarity tagger for various languages.'
  gem.description = gem.summary
  gem.homepage    = 'http://opener-project.github.com/'
  gem.extensions  = ['ext/hack/Rakefile']

  gem.license = 'Apache 2.0'

  gem.required_ruby_version = '>= 1.9.2'

  gem.files = Dir.glob([
    'core/*.py',
    'core/general-lexicons/**/*',
    'ext/**/*',
    'lib/**/*',
    'config.ru',
    '*.gemspec',
    '*_requirements.txt',
    'README.md',
    'LICENSE.txt',
    'exec/**/*',
    'task/*'
  ]).select { |file| File.file?(file) }

  gem.executables = Dir.glob('bin/*').map { |file| File.basename(file) }

  gem.add_dependency 'opener-daemons', '~> 2.2'
  gem.add_dependency 'opener-webservice', '~> 2.1'
  gem.add_dependency 'opener-core', '~> 2.2'

  gem.add_dependency 'rake'
  gem.add_dependency 'nokogiri'
  gem.add_dependency 'cliver'
  gem.add_dependency 'slop', '~> 3.5'

  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'cucumber'
end
