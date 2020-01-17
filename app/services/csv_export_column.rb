CsvExportColumn = Struct.new(:header, :call_method) do
  delegate :blank?, to: :call_method
end
