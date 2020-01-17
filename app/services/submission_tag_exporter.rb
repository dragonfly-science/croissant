class SubmissionTagExporter < CsvExportService
  def initialize(consultation)
    @consultation = consultation
    @name = consultation.name.parameterize
  end

  def items
    SubmissionTag.joins(:submission).where(submissions: { consultation: @consultation }).all
  end

  def columns
    [
      CsvExportColumn.new(:submission_id, :submission_id),
      CsvExportColumn.new(:tag_id, :tag_id),
      CsvExportColumn.new(:submission_filename, :filename),
      CsvExportColumn.new(:tag_name, :name),
      CsvExportColumn.new(:tag_number, :full_number),
      CsvExportColumn.new(:quote, :text),
      CsvExportColumn.new(:start_char, :start_char),
      CsvExportColumn.new(:end_char, :end_char),
      CsvExportColumn.new(:tagger, ""),
      CsvExportColumn.new(:tagtime, :created_at)
    ]
  end

  def filename
    "#{Time.zone.today.iso8601}-#{@name}-tags.csv"
  end
end
