Given /^the fixture file "(.*?)"$/ do |filename|
  @input    = fixture_file(filename)
  @filename = filename
end

Given /^I put it through the kernel$/ do
  @tmp_filename = "output_#{rand(1000)}_#{@filename}"
  @output       = tmp_file(@tmp_filename)
  input         = File.read(@input)
  output, *_    = kernel.run(input)

  File.open(@output, 'w') do |handle|
    handle.write(output)
  end
end

class Nokogiri::XML::Attr
  def == other
    value == other.value
  end
end

Then /^the output should match the fixture "(.*?)"$/ do |filename|
  fo = Nokogiri::XML File.read(fixture_file(filename))
  go = Nokogiri::XML File.read(@output)

  expect(go.css(:lp).last.attributes).to eq fo.css(:lp).last.attributes

  go.css('term sentiment').zip(fo.css('term sentiment')).each do |gs, fs|
    expect(gs.attr(:lemma)).to    eq fs.attr(:lemma)
    expect(gs.attr(:pos)).to      eq fs.attr(:pos)
    expect(gs.attr(:polarity)).to eq fs.attr(:polarity)
  end
end

def fixture_file(filename)
  File.expand_path("../../../features/fixtures/#{filename}", __FILE__)
end

def tmp_file(filename)
  File.expand_path("../../../tmp/#{filename}", __FILE__)
end
