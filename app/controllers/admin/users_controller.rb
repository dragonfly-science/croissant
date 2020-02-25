module Admin
  class UsersController < AdminController
    before_action :find_user, except: %i[index search]
    breadcrumb "Admin", :root_path
    breadcrumb "Users", :admin_users_path, match: :exclusive

    def index
      @users = User.all.order(:state)
      authorize @users
    end

    def edit
      authorize @user
      breadcrumb @user.email.to_s, :edit_admin_user_path, match: :exclusive
    end

    def update
      authorize @user
      if @user.update(user_params)
        redirect_to admin_users_path
      else
        flash.now[:alert] = I18n.t("user.update.failure")
        render :edit
      end
    end

    # PUT /users/:id/approve
    def approve
      authorize @user
      if @user.approve!
        redirect_to admin_users_url(@user, notice: "#{@user.email} was approved")
      else
        redirect_back(notice: "Failed to approve #{@user.email}")
      end
    end

    # PUT /users/:id/approve
    def suspend
      authorize @user
      if @user.suspend!
        redirect_to admin_users_url(@user, notice: "#{@user.email} was suspended")
      else
        redirect_back(notice: "Failed to suspend #{@user.email}")
      end
    end

    # PUT /users/:id/approve
    def reactivate
      authorize @user
      if @user.reactivate!
        redirect_to admin_users_url(@user, notice: "#{@user.email} was reactivated")
      else
        redirect_back(notice: "Failed to reactivated #{@user.email}")
      end
    end

    def search
      authorize User
      @consultation = Consultation.find(params[:consultation_id])
      @users = User.search_by_email(params[:search]) - @consultation.users
      respond_to do |format|
        format.js
      end
    end

    private

    def find_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:role)
    end
  end
end
