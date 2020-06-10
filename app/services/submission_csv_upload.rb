require "csv"

class SubmissionCsvUpload < CsvImportService
  def initialize(file, consultation)
    @file = file
    @consultation = consultation
    @results = []
  end

  def expected_headers
    %w[part_number text]
  end

  def optional_headers
    Submission::METADATA_FIELDS.map(&:to_s)
  end

  def ignored_headers
    %w[submission_id state loaded_by]
  end

  def import!
    @incomplete_rows = []

    csv.each do |row|
      @results << submission_from_rows(@incomplete_rows) if @incomplete_rows.any? && row["part_number"].to_i <= 1
      @incomplete_rows << row
    end
    @results << submission_from_rows(@incomplete_rows)
  end

  def submission_from_rows(rows)
    @incomplete_rows = []
    submission_params = {}
    optional_headers.each do |header|
      submission_params[header] = rows.first[header]
    end
    submission_params[:text] = text_from_rows(rows)
    result_for_submission_params(submission_params)
  end

  def text_from_rows(rows)
    text = ""
    rows.sort_by { |row| row["part_number"] }
    rows.each do |row|
      text += row["text"]
    end
    text
  end

  def result_for_submission_params(submission_params)
    existing_submission = @consultation.submissions.find_by(submission_params)
    return SubmissionResult.new(:no_change, existing_submission) if existing_submission

    submission = @consultation.submissions.new(submission_params)
    if submission.save
      SubmissionResult.new(:created, submission)
    else
      SubmissionResult.new(:failed, submission)
    end
  end
end
