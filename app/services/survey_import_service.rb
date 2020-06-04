require "csv"
class SurveyImportService < CsvImportService
  def initialize(file, consultation)
    @file = file
    @consultation = consultation
    @errors = []
  end

  def import_item_name
    "Survey"
  end

  def validity_errors
    return ["Wrong format"] unless @file && Survey::SURVEY_FILE_TYPES.include?(@file.content_type)

    error_list = []
    error_list << "File empty" if csv.empty?
    error_list
  end

  def import!
    ActiveRecord::Base.transaction do
      # create a survey for the file
      survey = create_survey
      # create a survey question for each header
      create_survey_questions(survey, headers)
      # create a submission for each row
      create_submission_and_answers(survey)
    end
  end

  def create_survey
    survey = Survey.new(consultation: @consultation)
    survey.original_file.attach(@file)
    if survey.save!
      survey
    else
      @errors << survey.errors.messages
    end
  end

  def create_survey_questions(survey, headers)
    headers.each do |header|
      create_survey_question(survey, header)
    end
  end

  def create_survey_question(survey, question)
    survey_question = SurveyQuestion.new(survey: survey, question: question)
    if survey_question.save!
      survey_question
    else
      @errors << survey_question.errors.messages
    end
  end

  def create_submission_and_answers(survey) # rubocop:disable Metrics/MethodLength
    q_a_pairs = []
    submission = nil
    csv.each do |row|
      headers.each do |header|
        answer = row.fetch(header)
        question = survey.survey_questions.find_by(question: header)

        q_a_pairs << { answer: answer, survey_question: question }
      end

      submission = create_submission(survey)
    end

    # create a survey answer for each row and question
    q_a_pairs.each do |pair|
      create_survey_answer(pair[:answer], pair[:survey_question], submission)
    end
    submission.concatenate_answers
  end

  def create_submission(survey)
    submission_params = submission_params(survey)

    submission = @consultation.submissions.new(submission_params)
    if submission.save!
      submission
    else
      @errors << submission.errors.messages
    end
  end

  def submission_params(survey)
    {
      survey: survey,
      state: "ready"
    }
  end

  def create_survey_answer(answer, question, submission)
    survey_answer = SurveyAnswer.new(answer: answer, survey_question: question, submission: submission)
    if survey_answer.save!
      survey_answer
    else
      @errors << survey_answer.errors.messages
    end
  end

  private

  # TODO: convert xlsx files to CSV
  def csv
    @csv ||= CSV.read(@file.open, headers: true)
  end
end
