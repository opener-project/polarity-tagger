Given(/^the fixture file "(.*?)"$/) do |filename|
  @input    = fixture_file(filename)
  @filename = filename
end

Given(/^I put it through the kernel$/) do
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

Then(/^the output should match the fixture "(.*?)"$/) do |filename|
  output  = Nokogiri::XML File.read @output
  fixture = Nokogiri::XML File.read fixture_file(filename)

  expect(output.css(:lp).last.attributes).to eq fixture.css(:lp).last.attributes

  output_terms = output.css('term').each.with_object({}) do |t, h|
    h[t.attr(:lemma)] = t
  end
  fixture_terms = fixture.css('term').each.with_object({}) do |t, h|
    h[t.attr(:lemma)] = t
  end

  check_terms output_terms, fixture_terms

end

def check_terms output_terms, fixture_terms
  output_terms.each do |lemma, ot|
    ft = fixture_terms[lemma]

    expect(ot).to_not eq nil
    expect(ft).to_not eq nil

    fs = ft.at(:sentiment)
    os = ot.at(:sentiment)
    next if os.nil? and fs.nil?
    #next puts "\n#{lemma}: extra sentiment found: #{fs.inspect}\n" if os.nil? and !fs.nil?

    log 'missing fs:' if fs.nil?
    log ft.attr(:lemma).to_s if fs.nil?

    next expect(fs).to eq nil if os.nil?
    next expect(os).to eq nil if fs.nil?

    expect(fs.attr(:pos)).to      eq os.attr(:pos)
    expect(fs.attr(:polarity)).to eq os.attr(:polarity)
  end
end

def fixture_file(filename)
  File.expand_path("../../../features/fixtures/#{filename}", __FILE__)
end

def tmp_file(filename)
  File.expand_path("../../../tmp/#{filename}", __FILE__)
end
