class ConsultationsController < ApplicationController
  def index
    @consultations = Consultation.alphabetical_order
  end

  def show
    @consultation = find_consultation
  end

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

  private

  def find_consultation
    Consultation.find(params[:id])
  end

  def consultation_params
    params.require(:consultation)
          .permit(:name, :consultation_type)
  end
end
