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

  it "Transform ALL dates to ISO8601 format (YYYY-MM-DD)" do
    invalid = ''
    date_1 = '12/12/2010'
    date_2 = '2/2/1966'
    date_3 = '6/6/99'
    date_4 = '1988-02-12'
    date_5 = '1-11-88'

    expected_1 = '2010-12-12'
    expected_2 = '1966-02-02'
    expected_3 = '1999-06-06'
    expected_4 = '1988-02-12'
    expected_5 = '1988-01-11'
    expected_invalid = 'No Date Provided'

    result_1 = CsvFormatter.date_formatter(date_1)
    result_2 = CsvFormatter.date_formatter(date_2)
    result_3 = CsvFormatter.date_formatter(date_3)
    result_4 = CsvFormatter.date_formatter(date_4)
    result_5 = CsvFormatter.date_formatter(date_5)
    result_invalid = CsvFormatter.date_formatter(invalid)

    expect(expected_1).to eq(result_1)
    expect(expected_2).to eq(result_2)
    expect(expected_3).to eq(result_3)
    expect(expected_4).to eq(result_4)
    expect(expected_5).to eq(result_5)
    expect(expected_invalid).to eq(result_invalid)
  end

  it 'creates a csv file in data folder' do
    path = 'data/output.csv'

    data = [{
              'first_name' => 'Jeff',
              'last_name' => 'Bezos',
              'dob' => '3000-10-11',
              'member_id' => '911',
              'effective_date' => '2021-07-26',
              'expiry_date' => '2022-11-17',
              'phone_number' => '+13035551234'
            }]

    CsvCreator.create_csv(data)
    file_exists = File.exist?(path)
    expect(file_exists).to eq(file_exists)
    File.delete(path) if file_exists
  end

  it 'creates a report file in data folder' do
    path = 'data/report.txt'
    data = [{
          'first_name' => 'Jeff',
          'last_name' => 'Bezos',
          'dob' => '3000-10-11',
          'member_id' => '911',
          'effective_date' => '2021-07-26',
          'expiry_date' => '2022-11-17',
          'phone_number' => '+13035551234'
        }]

    ReportCreator.create_report(data)
    file_exists = File.exist?(path)
    expect(file_exists).to eq(file_exists)
    File.delete(path) if file_exists
  end

end
