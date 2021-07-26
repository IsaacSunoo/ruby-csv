require 'csv'

class CirrusRubyCsv
  def initialize(csv_path, report)
    @csv_path = csv_path
    @report = report
  end

  def create_csv
    CsvFormatter.format(@csv_path)
  end
end

module CsvFormatter

  def self.format(csv_path = 'data/input.csv')
    data_array = CSV.parse(File.read(csv_path), headers: true)
    data_array.map { |data| coerce_data(data) }
  end

  def self.coerce_data(data)
    formatted_hash = {}
    data.each do |key, value|
      v = nil_whitespace_cleaner(value)

      formatted_hash[key] = if key == 'phone_number'
                              phone_number_formatter(v)
                            elsif %w(dob effective_date expiry_date).include?(key)
                              date_formatter(v)
                            else
                              v
                            end
    end
    formatted_hash
  end

  def self.nil_whitespace_cleaner(value)
    # Set all nil and whitespace values to an empty string
    value.nil? ? '' : value.gsub(/ /, '')
  end

  def self.phone_number_formatter(phone_number)
    return 'Invalid Number' if phone_number == ''
    formatted_number = phone_number.gsub(/[^0-9]/, '').split('').last(10).join('').to_s
    '1+'.concat(formatted_number)
  end

  def self.date_formatter(date_string)
    return 'No Date Provided' if date_string == ''
    if date_string.include?('/')
      return Date.strptime(date_string, '%m/%d/%Y').to_s if date_string.split('/').last.length == 4
      return Date.strptime(date_string, '%m/%d/%y').to_s
    end

    if date_string.include?('-')
      return Date.strptime(date_string, '%Y-%m-%d').to_s if date_string.split('-').first.length == 4
      Date.strptime(date_string, '%m-%d-%y').to_s
    end

  end

end
