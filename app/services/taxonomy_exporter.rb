class TaxonomyExporter < CsvExportService
  def initialize(taxonomy)
    @taxonomy = taxonomy
    @consultation_name = @taxonomy.consultation.name.parameterize
  end

  def items
    @taxonomy.tags.number_order
  end

  def columns
    [
      CsvExportColumn.new(:tag_id, :id),
      CsvExportColumn.new(:number, :full_number),
      CsvExportColumn.new(:name, :name)
    ]
  end

  def filename
    "#{Time.zone.today.iso8601}-#{@consultation_name}-taxonomy.csv"
  end
end
