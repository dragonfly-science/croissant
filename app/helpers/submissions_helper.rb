module SubmissionsHelper
  def submission_upload_file_types
    ["text/csv"].concat(Submission::SUBMISSION_FILE_TYPES).join(",")
  end
end
