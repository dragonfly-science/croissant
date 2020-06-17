require "csv"
require "roo"

class SurveyImportService < CsvImportService # rubocop:disable Metrics/ClassLength
  attr_accessor :notice

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
    begin
      ActiveRecord::Base.transaction do
        # create a survey for the file
        survey = create_survey
        # create a survey question for each header
        questions = create_survey_questions(survey, headers)
        # create a submission for each row
        create_submission_and_answers(survey, questions)
      end
    rescue ActiveRecord::RecordInvalid => e
      @errors << e.message
    end

    @notice = message_for_result
  end

  private

  def create_survey
    survey = Survey.new(consultation: @consultation)

    survey.original_file.attach(@file.blob)
    if survey.save!
      survey
    else
      @errors << survey.errors.messages
    end
  end

  def create_survey_questions(survey, headers)
    questions = []

    headers = combine_survey_monkey_headers(@csv.first) if survey_monkey?

    create_questions_from_headers(headers, questions, survey)
  end

  def create_questions_from_headers(headers, questions, survey)
    headers.reject(&:nil?).each do |header|
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

  def create_submission_and_answers(survey, questions)
    @csv.each_with_index do |row, index|
      q_a_pairs = []
      next if survey_monkey? && index == 0

      populate_q_a_pairs(row, questions, q_a_pairs)

      submission = create_submission(survey)

      q_a_pairs.each do |pair|
        create_survey_answer(pair[:answer], pair[:survey_question], submission)
      end

      submission.concatenate_answers
    end
  end

  def populate_q_a_pairs(row, questions, q_a_pairs)
    questions.each_with_index do |sq, sq_index|
      answer = row.values_at(sq_index).first
      next if answer.nil?

      q_a_pairs << { answer: answer, survey_question: sq }
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

  def survey_monkey?
    headers.include?("Respondent ID" && "Collector ID")
  end

  def combine_survey_monkey_headers(first_row_object)
    current_header = ""

    first_row_object.map do |col|
      current_header = col.first if col.first
      current_header = value_encode(current_header)

      if col.last
        second_header = col.last
        second_header = value_encode(second_header)
        "#{current_header} - #{second_header}"
      else
        current_header
      end
    end
  end

  def value_encode(value)
    value.encode("UTF-8", "binary", invalid: :replace, undef: :replace, replace: "").force_encoding("utf-8")
  end

  def csv
    if @file.content_type == "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      csv_filepath = xlsx_to_csv(@file)
      @csv = CSV.read(csv_filepath, headers: true)
    else
      @csv = CSV.parse(@file.download, headers: true)
    end
  end

  def xlsx_to_csv(file)
    csv_filename = File.basename(file.filename.to_s, File.extname(file.filename.to_s))

    path = ActiveStorage::Blob.service.send(:path_for, file.key)
    xlsx = Roo::Spreadsheet.open(path, extension: "xlsx")
    xlsx.parse(clean: true)
    xlsx.to_csv("./tmp/#{csv_filename}.csv")

    Rails.root.join("tmp/#{csv_filename}.csv")
  end

  def message_for_result
    @notice = if @errors.empty?
                "Successfully uploaded survey"
              else
                @errors
              end
  end
end
