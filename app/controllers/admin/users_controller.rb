module Admin
  class UsersController < ApplicationController
    before_action :find_user, except: %i[index]

    def index
      @users = User.all.order(:state)
      authorize @users
    end

    def edit
      authorize @user
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

    private

    def find_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:role)
    end
  end
end
