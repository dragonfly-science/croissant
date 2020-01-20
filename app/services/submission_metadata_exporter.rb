class SubmissionMetadataExporter < CsvExportService
  def initialize(consultation, character_limit: 32_000)
    @consultation = consultation
    @name = consultation.name
    @submissions = @consultation.submissions
    @character_limit = character_limit
  end

  def items
    @items ||= separate_submissions
  end

  def columns
    metadata_columns = Submission::METADATA_FIELDS.map { |e| CsvExportColumn.new(e, e) }
    [
      CsvExportColumn.new(:submission_id, :id),
      CsvExportColumn.new(:filename, :filename),
      CsvExportColumn.new(:part_number, :part_number),
      CsvExportColumn.new(:text, :text),
      CsvExportColumn.new(:state, :state),
      CsvExportColumn.new(:loaded_by, "")
    ].concat(metadata_columns)
  end

  def filename
    "#{Time.zone.today.iso8601}-#{@name.parameterize}-submissions.csv"
  end

  private

  def separate_submissions
    all_parts = []

    @submissions.each do |submission|
      separator = SubmissionSeparator.new(submission, character_limit: @character_limit)
      all_parts.concat(separator.parts)
    end

    all_parts
  end
end
