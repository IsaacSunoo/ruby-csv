require 'csv'

class CirrusRubyCsv
  def initialize(csv_input_path, report_output_path, csv_output_path)
    @csv_input_path = csv_input_path
    @report_output_path = report_output_path
    @csv_output_path = csv_output_path
  end

  def create_csv_and_report
    formatted_data = CsvFormatter.format(@csv_input_path)
    CsvFormatter.create_csv(formatted_data, @csv_output_path)
    ReportCreator.create_report(formatted_data, @report_output_path)
  end
end

module PhoneNumber
  def self.phone_number_formatter(phone_number)
    formatted_number = phone_number.gsub(/[^0-9]/, '').split('').last(10).join('').to_s
    '1+'.concat(formatted_number)
  end
end

module DateHelpers
  def self.date_formatter(date_string)
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

module CsvFormatter
  def self.format(csv_path)
    data_array = CSV.parse(File.read(csv_path), headers: true)
    data_array.map_with_index { |data, i| coerce_data(data, i) }
    
  end

  def self.coerce_data(data, index)
    formatted_hash = {}
    invalid_hash = {}

    data.each do |key, value|
      v = nil_whitespace_cleaner(value)

      invalid_hash[key] = if %w(first_name last_name dob member_id effective_date).include?(key) && v == ''
                              "ROW: #{index + 1}"
                              next
                          end

      formatted_hash[key] = if key == 'phone_number'
                              PhoneNumber.phone_number_formatter(v)
                            elsif %w(dob effective_date expiry_date).include?(key)
                              DateHelpers.date_formatter(v)
                            else
                              v
                            end
    end

    { 'formatted_hash' => formatted_hash, 'invalid_hash' => invalid_hash }
  end

  def self.nil_whitespace_cleaner(value)
    # Set all nil and whitespace values to an empty string
    value.nil? ? '' : value.gsub(/ /, '')
  end

  def self.create_csv(data, csv_output_path)
    CSV.open(csv_output_path, 'wb') do |csv|
      csv << data.first.keys
      data.each { |hash| csv << hash.values }
    end
  end
end

module ReportCreator
  def self.create_report(data, report_output_path)
    report_text = ''

    data.each do |hash|

      report_text.concat("#{hash['first_name']} #{hash['last_name']} was born on #{hash['dob']}. #{hash['first_name']} is a member of the Planet Fitness and their id number is: #{hash['member_id']}. They joined on #{hash['effective_date']} and their membership expires on #{hash['expiry_date']}. Call them at #{hash['phone_number']} to have a quick chat or con them into re signing up for pizza mondays! \n")
    end

    File.open(report_output_path, 'w+') { |file| file.write(report_text) }
  end
end