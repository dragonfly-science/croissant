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
    @files.each do |file|
      create_one(file)
    end
    @notice = message_for_multiple_submissions
  end

  private

  def create_one(file)
    submission = Submission.new(@create_params)
    submission.file.attach(file)
    if submission.save
      @successful << submission
    else
      @unsuccessful << submission
      @errors[file.original_filename] = submission.errors.full_messages.join(", ")
    end
  end

  def message_for_multiple_submissions
    notice = ""
    notice += "Successfully created #{pluralize(successful.length, "submission")}." if @successful.any?
    notice += "Failed creating #{pluralize(unsuccessful.length, "submission")}:" if @unsuccessful.any?
    errors.each do |key, value|
      notice += "#{key}: #{value} "
    end
    notice
  end
end
