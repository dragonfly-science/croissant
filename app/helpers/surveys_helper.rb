module SurveysHelper
  def survey_upload_file_types
    Survey::SURVEY_FILE_TYPES.join(",")
  end

  def tagged_survey_answer(marked_up_sa_array, survey_answer)
    marked_up_sa_array.detect { |sa| sa[:taggable_id] == survey_answer.id }[:text].to_s
  end
end
