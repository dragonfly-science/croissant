class SurveyImportJob < ApplicationJob
  queue_as :default

  def perform(survey_import)
    SurveyImportService.new(survey_import.file, survey_import.consultation).import!
  end
end
