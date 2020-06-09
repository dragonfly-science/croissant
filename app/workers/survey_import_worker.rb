class SurveyImportWorker
  include Sidekiq::Worker

  def perform(file_path, consultation_id)
    consultation = Consultation.find(consultation_id)
    file = File.open(file_path)
    SurveyImportService.new(file, consultation).import!
  end
end
