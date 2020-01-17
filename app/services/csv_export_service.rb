require "csv"

class CsvExportService
  def initialize
  end

  def columns
    # define in subclasses
  end

  def items
    # define in subclasses
  end

  def filename
    # define in subclass
  end

  def export
    CSV.generate do |csv|
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
