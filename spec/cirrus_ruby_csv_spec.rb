RSpec.describe CirrusRubyCsv do
  skip "has a version number" do
    expect(CirrusRubyCsv::VERSION).not_to be nil
  end

  it "cleans all white space and nil values to empty strings" do
    nil_value = CsvFormatter.nil_whitespace_cleaner(nil)
    whitespace_value = CsvFormatter.nil_whitespace_cleaner(' ')
    expect(nil_value).to eq('')
    expect(whitespace_value).to eq('')
  end

  it "formats numbers according to E.164 compliant (country code + 10 numeric digits)" do
    invalid_number = CsvFormatter.phone_number_formatter('')
    expect(invalid_number).to eq('Invalid Number')
    phone_number_input = 'asd3o0355512p3o4'
    converted_number = CsvFormatter.phone_number_formatter(phone_number_input)
    expect(converted_number).to eq('1+3035551234')
  end

end
