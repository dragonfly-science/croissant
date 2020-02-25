module Admin
  class ConsultationsController < AdminController
    before_action :find_consultation, only: %i[edit update archive restore]
    breadcrumb "Admin", :root_path
    breadcrumb "Consultations", :admin_consultations_path, match: :exclusive

    def index
      @consultations = UserConsultationsService.admin_consultations(current_user, params[:order])
      authorize Consultation
    end

    def edit
      authorize @consultation
    end

    def update
      authorize @consultation
      @consultation.update(update_consultation_params)
      if @consultation.save
        redirect_to edit_admin_consultation_url(@consultation), notice: "Consultation was updated"
      else
        render :edit
      end
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

    def update_consultation_params
      params.require(:consultation)
            .permit(:name, :consultation_type, :description)
    end
  end
end
