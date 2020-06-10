class SubmissionCreator
  include ActionView::Helpers::TextHelper
  attr_accessor :successful, :unsuccessful, :errors, :notice

  def initialize(create_submission_params:, file_upload_params:)
    @files = file_upload_params
    @create_params = create_submission_params
    @successful = []
    @unsuccessful = []
    @errors = {}
  end

  def create!
    csv_files.each do |file|
      importer = SubmissionCsvUpload.new(file, @create_params[:consultation])
      importer.import!
      @successful.concat(importer.created_items)
      @unsuccessful.concat(importer.failed_items)
    end

    non_csv_files.each do |file|
      create_one(file)
    end
    @notice = message_for_multiple_submissions
  end

  private

  def csv_files
    @files.select { |file| file.content_type == "text/csv" }
  end

  def non_csv_files
    @files - csv_files
  end

  def create_one(file)
    submission = Submission.new(@create_params)
    submission.file.attach(file)
    if submission.save
      @successful << SubmissionResult.new(:created, submission, file.original_filename)
    else
      @unsuccessful << SubmissionResult.new(:failed, submission, file.original_filename)
    end
  end

  def message_for_multiple_submissions
    notice = ""
    notice += "Successfully created #{pluralize(successful.length, "submission")}." if @successful.any?
    notice += "Failed creating #{pluralize(unsuccessful.length, "submission")}:" if @unsuccessful.any?
    if @unsuccessful.length <= 20
      @unsuccessful.each do |result|
        notice += result.formatted_error_messages
      end
    end
    notice
  end
end
