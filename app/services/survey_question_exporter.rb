class SurveyQuestionExporter < CsvExportService
  def initialize(consultation)
    @consultation = consultation
    @name = consultation.name.parameterize
    @surveys = @consultation.surveys
  end

  def items
    @items = separate_survey_questions
  end

  def columns
    [
      CsvExportColumn.new(:survey_id, :survey_id),
      CsvExportColumn.new(:survey_question, :question),
      CsvExportColumn.new(:question_token, :token)
    ]
  end

  def filename
    "#{Time.zone.today.iso8601}-#{@name}-survey-questions.csv"
  end

  private

  def separate_survey_questions
    all_questions = @surveys.map(&:survey_questions)
    all_questions.flatten
  end
end
