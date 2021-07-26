require 'csv'

class CirrusRubyCsv
  def initialize(data)
    @data = data
  end

  def create_csv_and_report
    CsvCreator.create_csv(@data)
    ReportCreator.create_report(@data)
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

module CsvCreator
  def self.create_csv(data, csv_output_path = 'data/output.csv')
    CSV.open(csv_output_path, 'wb') do |csv|
      csv << data.first.keys
      data.each { |hash| csv << hash.values }
    end
  end
end

module ReportCreator
  def self.create_report(data, report_output_path = 'data/report.txt')
    report_text = ''

    data.each do |hash|
      report_text.concat("#{hash['first_name']} #{hash['last_name']} was born on #{hash['dob']}. #{hash['first_name']} is a member of the Planet Fitness and their id number is: #{hash['member_id']}. They joined on #{hash['effective_date']} and their membership expires on #{hash['expiry_date']}. Call them at #{hash['phone_number']} to have a quick chat or con them into re signing up for pizza mondays! \n")
    end

    File.open(report_output_path, 'w+') { |file| file.write(report_text) }
  end
end

module DoIt
  def self.create_csv_and_report
    data = CsvFormatter.format
    ruby_csv = CirrusRubyCsv.new(data)
    ruby_csv.create_csv_and_report
  end
end