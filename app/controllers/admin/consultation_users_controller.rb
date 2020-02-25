module Admin
  class ConsultationUsersController < AdminController
    before_action :find_consultation, :find_user, only: %i[create]
    before_action :find_consultation_user, only: %i[destroy]
    def create
      authorize @consultation, :add_user?
      @consultation_user = @consultation.add_user(@user, params[:role])
      respond_to do |format|
        format.js
      end
    end

    def destroy
      find_consultation_user
      authorize @consultation_user
      @consultation_user.destroy
      respond_to do |format|
        format.js
      end
    end

    private

    def find_consultation
      @consultation = Consultation.find(params[:consultation_id])
    end

    def find_user
      @user = User.find(params[:user_id])
    end

    def find_consultation_user
      @consultation_user = ConsultationUser.find(params[:id])
    end
  end
end
