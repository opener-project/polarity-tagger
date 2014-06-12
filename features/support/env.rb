require_relative '../../lib/opener/polarity_tagger'
require 'rspec'

def kernel
  return Opener::PolarityTagger.new(:args => ['--no-time'])
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
