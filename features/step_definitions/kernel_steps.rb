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
  i = Nokogiri::XML File.read @output
  o = Nokogiri::XML File.read fixture_file(filename)

  expect(i.css(:lp).last.attributes).to eq o.css(:lp).last.attributes

  iterms = i.css('term').each.with_object({}) do |t, h|
    h[t.attr(:lemma)] = t
  end
  oterms = o.css('term').each.with_object({}) do |t, h|
    h[t.attr(:lemma)] = t
  end

  oterms.each do |lemma, ot|
    it = iterms[lemma]
    expect(ot).to_not eq nil

    is = it.at(:sentiment)
    os = ot.at(:sentiment)
    next puts "\n#{lemma}: extra sentiment found: #{is.inspect}\n" if os.nil? and !is.nil?
    next expect(is).to eq nil if os.nil?
    expect(is.attr(:pos)).to      eq os.attr(:pos)
    expect(is.attr(:polarity)).to eq os.attr(:polarity)
  end
end

def fixture_file(filename)
  File.expand_path("../../../features/fixtures/#{filename}", __FILE__)
end

def tmp_file(filename)
  File.expand_path("../../../tmp/#{filename}", __FILE__)
end
