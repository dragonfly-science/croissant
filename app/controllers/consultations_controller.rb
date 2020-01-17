class ConsultationsController < ApplicationController
  before_action :consultation, only: %i[show export]

  def index
    @consultations = Consultation.alphabetical_order
  end

  def show; end

  def new
    @consultation = Consultation.new
  end

  def create
    @consultation = Consultation.new(consultation_params)
    if @consultation.save
      redirect_to consultation_submissions_path(@consultation)
    else
      flash.now[:alert] = t("consultation.create.failure")
      render :new
    end
  end

  def export # rubocop:disable Metrics/MethodLength
    respond_to do |format|
      format.csv do
        case params[:type]
        when "taxonomy"
          exporter = TaxonomyExporter.new(@consultation.taxonomy)
        when "tags"
          exporter = SubmissionTagExporter.new(@consultation)
        when "submissions"
          exporter = SubmissionMetadataExporter.new(@consultation)
        else
          fail ActionController::BadRequest
        end
        send_data(exporter.export, filename: exporter.filename)
      end
    end
  end

  private

  def consultation
    @consultation ||= params[:id] ? Consultation.find(params[:id]) : Consultation.find(params[:consultation_id])
  end

  def consultation_params
    params.require(:consultation)
          .permit(:name, :consultation_type)
  end
end
