RSpec.describe CirrusRubyCsv do
  before(:each) do
    @report_output_path = 'data/test-report.txt'
    @csv_output_path = 'data/test-output.csv'
    @test_csv_path = 'spec/test_data/test_csv.csv'
  end

  after(:each) do
    report_output_exists = File.exist?(@report_output_path)
    csv_output_exists = File.exist?(@csv_output_path)
    csv_test_path_exists = File.exist?(@test_csv_path)

    File.delete(@report_output_path) if report_output_exists
    File.delete(@csv_output_path) if csv_output_exists
    File.delete(@test_csv_path) if csv_test_path_exists
  end

  it "cleans all white space and nil values to empty strings" do
    nil_value = CsvFormatter.nil_whitespace_cleaner(nil)
    whitespace_value = CsvFormatter.nil_whitespace_cleaner(' ')
    expect(nil_value).to eq('')
    expect(whitespace_value).to eq('')
  end

  it "formats numbers according to E.164 compliant (country code + 10 numeric digits)" do
    number = PhoneNumber.send(:phone_number_formatter, 'asd3o0355512p3o4')
    expect(number).to eq('1+3035551234')

    number = PhoneNumber.send(:phone_number_formatter, '13039873345')
    expect(number).to eq('1+3039873345')

    number = PhoneNumber.send(:phone_number_formatter, '444-555-9880')
    expect(number).to eq('1+4445559880')

  end

  it "Transform ALL dates to ISO8601 format (YYYY-MM-DD)" do
    date = DateHelpers.send(:date_formatter, '12/12/2010')
    expect(date).to eq('2010-12-12')

    date = DateHelpers.send(:date_formatter, '2/2/1966')
    expect(date).to eq('1966-02-02')

    date = DateHelpers.send(:date_formatter, '6/6/99')
    expect(date).to eq('1999-06-06')

    date = DateHelpers.send(:date_formatter, '1988-02-12')
    expect(date).to eq('1988-02-12')

    date = DateHelpers.send(:date_formatter, '1-11-88')
    expect(date).to eq('1988-01-11')
  end

  it 'creates a csv out and report file from csv input path' do
    ruby_csv = CirrusRubyCsv.new('data/input.csv', @report_output_path, @csv_output_path)
    ruby_csv.create_csv_and_report

    data = [{
          'first_name' => 'Jeff',
          'last_name' => 'Bezos',
          'dob' => '3000-10-11',
          'member_id' => '911',
          'effective_date' => '2021-07-26',
          'expiry_date' => '2022-11-17',
          'phone_number' => '+13035551234'
        }]

    report_output_exists = File.exist?(@report_output_path)
    expect(report_output_exists).to eq(true)

    csv_output_exists = File.exist?(@csv_output_path)
    expect(csv_output_exists).to eq(true)
  end

  it 'formats data from given csv file input path' do
    test_data = [
                  {
                    'first_name' => 'Jeff',
                    'last_name' => 'Bezos',
                    'dob' => '3000-10-11',
                    'member_id' => '911',
                    'effective_date' => '2021-07-26',
                    'expiry_date' => '2022-11-17',
                    'phone_number' => '+13035551234'
                  },
                  {
                    'first_name' => 'Paul',
                    'last_name' => 'Rudd',
                    'dob' => '1-1-1990',
                    'member_id' => 'asd911',
                    'effective_date' => '2021-07-26',
                    'expiry_date' => '2022-11-17',
                    'phone_number' => '3033333333'
                  },
                ]

    expected_data = [
                  {
                    'first_name' => 'Jeff',
                    'last_name' => 'Bezos',
                    'dob' => '3000-10-11',
                    'member_id' => '911',
                    'effective_date' => '2021-07-26',
                    'expiry_date' => '2022-11-17',
                    'phone_number' => '1+3035551234'
                  },
                  {
                    'first_name' => 'Paul',
                    'last_name' => 'Rudd',
                    'dob' => '2019-01-01',
                    'member_id' => 'asd911',
                    'effective_date' => '2021-07-26',
                    'expiry_date' => '2022-11-17',
                    'phone_number' => '1+3033333333'
                  },
                ]



    CSV.open(@test_csv_path, 'wb') do |csv|
      csv << test_data.first.keys
      test_data.each { |hash| csv << hash.values }
    end

    formatted_data = CsvFormatter.send(:format, @test_csv_path)
    expect(formatted_data).to eq(expected_data)
  end

  it 'Cleans and coerces data' do
    test_data = {
                  'first_name' => ' Jeff',
                  'last_name' => 'Bezos ',
                  'dob' => '8/4/16',
                  'member_id' => '911',
                  'effective_date' => '2021-07-26',
                  'expiry_date' => '2022-11-17',
                  'phone_number' => '1213035551234'
                }

    expected_data = {
                      'first_name' => 'Jeff',
                      'last_name' => 'Bezos',
                      'dob' => '2016-08-04',
                      'member_id' => '911',
                      'effective_date' => '2021-07-26',
                      'expiry_date' => '2022-11-17',
                      'phone_number' => '1+3035551234'
                    }

    cleaned_data = CsvFormatter.send(:coerce_data, test_data)

    expect(cleaned_data).to eq(expected_data)
  end
end
