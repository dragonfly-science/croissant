class SubmissionTagExporter < CsvExportService
  def initialize(consultation)
    @consultation = consultation
    @name = consultation.name.parameterize
  end

  def items
    SubmissionTag.joins("left outer join submissions on submissions.id = submission_tags.taggable_id "\
       "and submission_tags.taggable_type='Submission'")
                 .joins("left outer join survey_answers on survey_answers.id = submission_tags.taggable_id "\
                    "and submission_tags.taggable_type='SurveyAnswer'")
                 .joins("left outer join public.submissions answer_submissions "\
                   "on answer_submissions.id = survey_answers.submission_id")
                 .where("submissions.consultation_id = ? and submissions.state !='archived'"\
                   " OR answer_submissions.consultation_id = ? and answer_submissions.state !='archived'",
                        @consultation.id, @consultation.id)
                 .all
  end

  def columns # rubocop:disable Metrics/MethodLength
    [
      CsvExportColumn.new(:submission_id, :submission_id),
      CsvExportColumn.new(:tag_id, :id),
      CsvExportColumn.new(:submission_filename, :filename),
      CsvExportColumn.new(:survey_question_token, :survey_question_token),
      CsvExportColumn.new(:tag_name, :name),
      CsvExportColumn.new(:tag_number, :full_number),
      CsvExportColumn.new(:quote, :text),
      CsvExportColumn.new(:start_char, :start_char),
      CsvExportColumn.new(:end_char, :end_char),
      CsvExportColumn.new(:tagger, :tagger_email),
      CsvExportColumn.new(:tagtime, :created_at)
    ]
  end

  def filename
    "#{Time.zone.today.iso8601}-#{@name}-tags.csv"
  end
end
