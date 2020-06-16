class SurveysController < ApplicationController
  before_action :consultation, only: %i[create]

  # POST /surveys
  def create
    authorize @consultation, :consultation_write_access?

    @survey_import = SurveyImport.create(consultation: @consultation)
    @survey_import.file.attach(file_upload_params)

    SurveyImportJob.perform_later(@survey_import)

    notice = "Survey uploaded successfully, awaiting processing"
    redirect_to consultation_submissions_url(@consultation), notice: notice
  end

  private

  def consultation
    @consultation ||= Consultation.find(params[:consultation_id])
  end

  # Only allow a trusted parameter "white list" through.
  def create_survey_params
    params.require(:survey).permit(%i[file])
          .merge(consultation: consultation)
  end

  def file_upload_params
    params[:survey][:file]
  end
end
