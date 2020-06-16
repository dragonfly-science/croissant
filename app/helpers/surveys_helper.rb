module SurveysHelper
  def survey_upload_file_types
    Survey::SURVEY_FILE_TYPES.join(",")
  end
end
