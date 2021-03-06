require "csv"

class CsvExportService
  def columns
    # define in subclasses
    fail NotImplementedError
  end

  def items
    # define in subclasses
    fail NotImplementedError
  end

  def filename
    # define in subclasses
    fail NotImplementedError
  end

  def export
    CSV.generate(encoding: "UTF-8") do |csv|
      csv << columns.map(&:header)
      items.each do |result|
        row = []
        columns.each do |column|
          value = column.blank? ? "" : result.send(column.call_method).to_s
          row << value
        end
        csv << row
      end
    end
  end
end
