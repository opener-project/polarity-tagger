require 'spec_helper'

describe Opener::PolarityTagger::LexiconMap do

  before do
    @lexicons = [
      @bad = Hashie::Mash.new(
        lemma:     'bad',
        pos:       nil,
        polarity: 'negative',
      ),
      @good = Hashie::Mash.new(
        lemma:     'good',
        pos:       nil,
        polarity: 'positive',
      ),
    ]
    @map = described_class.new lang: 'en', lexicons: @lexicons
  end

  it 'matches without pos' do
    expect(@map.by_polarity @bad.lemma, 'O').to eq [@bad, 'O']
  end

end
