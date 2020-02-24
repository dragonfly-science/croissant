module Admin
  class ConsultationsController < ApplicationController
    before_action :find_consultation, only: %i[archive restore]
    breadcrumb "Admin", :root_path
    breadcrumb "Consultations", :admin_consultations_path, match: :exclusive

    def index
      @consultations = Consultation.all.order(consultation_order)
      authorize @consultations
    end

    def archive
      authorize @consultation
      if @consultation.archive!
        redirect_to admin_consultations_url(notice: "#{@consultation.name} was archived")
      else
        redirect_back(notice: "Failed to archive #{@consultation.name}")
      end
    end

    def restore
      authorize @consultation
      if @consultation.restore!
        redirect_to admin_consultations_url(notice: "#{@consultation.name} was restored")
      else
        redirect_back(notice: "Failed to restore #{@consultation.name}")
      end
    end

    private

    def find_consultation
      @consultation = Consultation.find(params[:id])
    end

    def consultation_order
      return params[:order] if params[:order]

      "name ASC"
    end
  end
end
