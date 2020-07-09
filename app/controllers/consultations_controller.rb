class ConsultationsController < ApplicationController
  before_action :consultation, only: %i[show export]
  breadcrumb "Consultations", :consultations_path, match: :exclusive

  def index
    authorize Consultation
    @consultations = UserConsultationsService.consultations(current_user)
    respond_to do |format|
      format.json { render json: {consultations: @consultations} }
      format.html
    end
  end

  def show
    authorize @consultation
    respond_to do |format|
      format.json do
        render json: {
                 consultation: @consultation,
                 taxonomy: @consultation.taxonomy,
                 tags: @consultation.taxonomy.tags
               }
      end
      format.html do
        breadcrumb @consultation.name, :consultation_path
      end
    end
  end

  def new
    @consultation = Consultation.new
    authorize @consultation
  end

  def create
    @consultation = Consultation.new(consultation_params)
    @consultation.consultation_users.build(user: current_user, role: "admin")
    authorize @consultation
    if @consultation.save
      redirect_to consultation_submissions_path(@consultation)
    else
      flash.now[:alert] = t("consultation.create.failure")
      render :new
    end
  end

  def export # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    authorize @consultation
    respond_to do |format|
      format.csv do
        case params[:type]
        when "taxonomy"
          exporter = TaxonomyExporter.new(@consultation.taxonomy)
        when "tags"
          exporter = SubmissionTagExporter.new(@consultation)
        when "submissions"
          exporter = SubmissionMetadataExporter.new(@consultation)
        when "survey_questions"
          exporter = SurveyQuestionExporter.new(@consultation)
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
          .permit(:name, :consultation_type, :description)
  end
end
