require "csv"
require "roo"

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
      questions = create_survey_questions(survey, headers)
      # create a submission for each row
      create_submission_and_answers(survey, questions)
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
    questions = []
    headers.each do |header|
      questions << create_survey_question(survey, header)
    end
    questions
  end

  def create_survey_question(survey, question)
    survey_question = SurveyQuestion.new(survey: survey, question: question)
    if survey_question.save!
      survey_question
    else
      @errors << survey_question.errors.messages
    end
  end

  def create_submission_and_answers(survey, questions) # rubocop:disable Metrics/MethodLength
    submission = nil

    @csv.each do |row|
      q_a_pairs = []

      questions.each do |sq|
        answer = row.fetch(sq.question)
        next if answer.nil?

        q_a_pairs << { answer: answer, survey_question: sq }
      end

      submission = create_submission(survey)

      q_a_pairs.each do |pair|
        create_survey_answer(pair[:answer], pair[:survey_question], submission)
      end

      submission.concatenate_answers
    end
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

  def csv
    if @file.content_type == "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      csv_filepath = xlsx_to_csv(@file)
      @csv ||= CSV.read(csv_filepath, headers: true)
    end

    @csv ||= CSV.read(@file.open, headers: true)
  end

  def xlsx_to_csv(file)
    csv_filename = File.basename(file.original_filename, File.extname(file))

    xlsx = Roo::Spreadsheet.open(file)
    xlsx.parse(clean: true)
    xlsx.to_csv("./tmp/#{csv_filename}.csv")

    Rails.root.join("tmp/#{csv_filename}.csv")
  end
end
