require_relative "cirrus_ruby_csv/version"

class CirrusRubyCsv
  def initialize(csv_path, report)
    @csv_path = csv_path
    @report = report
  end
end
