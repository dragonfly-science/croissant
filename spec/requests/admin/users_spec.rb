require "rails_helper"

RSpec.describe "Users", type: :request do
  let(:user) { FactoryBot.create(:user, role: "superadmin") }
  before do
    sign_in(user)
  end

  # Admin users index
  describe "GET /admin/users" do
    before { get admin_users_path }

    context "when signed in as an admin or super admin" do
      it "responds with an ok status" do
        expect(response).to have_http_status(:ok)
      end

      it "assigns a collection of user models" do
        expect(assigns(:users)).to be_a_kind_of(ActiveRecord::Relation)
        expect(assigns(:users).first).to be_a_kind_of(User)
      end
    end

    context "when signed in as any other user" do
      before { user.update(role: "viewer") }

      it "responds with a not authorized error" do
        expect { get admin_users_path }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  # Admin users edit
  describe "GET /admin/user/:id/edit" do
    before { get edit_admin_user_path(user) }

    context "when signed in as an admin or super admin" do
      it "responds with an ok status" do
        expect(response).to have_http_status(:ok)
      end

      it "assigns an instance of the user model" do
        expect(assigns(:user)).to be_a_kind_of(User)
      end
    end

    context "when signed in as any other user" do
      before { user.update(role: "viewer") }

      it "responds with a not authorized error" do
        expect { get edit_admin_user_path(user) }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  # Admin users update
  describe "PUT /admin/user/:id" do
    subject { put admin_user_path(user), params: params }

    context "when signed in as an admin or super admin" do
      let(:params) { { user: { role: "admin" } } }

      it "responds with a redirect status" do
        subject
        expect(response).to have_http_status(:redirect)
      end

      context "with valid params" do
        it "updates the user" do
          subject
          expect(user.reload.role).to eq("admin")
        end
      end

      context "with invalid params" do
        before { params[:user].merge!(role: nil) }
        it "re-renders the edit page" do
          subject
          expect(response).to render_template(:edit)
        end
      end
    end

    context "when signed in as any other user" do
      before { user.update(role: "viewer") }

      it "responds with a not authorized error" do
        expect { put admin_user_path(user) }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  # Admin users approve
  describe "PUT /users/:id/approve" do
    let(:update_user) { FactoryBot.create(:user, state: "pending") }
    subject { put admin_approve_user_path(update_user) }

    context "when signed in as an admin or super admin" do
      context "and when approving a currently pending user" do
        it "responds with a redirect status" do
          subject
          expect(response).to have_http_status(:redirect)
        end

        it "updates the users state to active" do
          subject
          expect(update_user.reload.active?).to eq(true)
        end
      end

      context "and when approving a user that is not currently pending" do
        let(:update_user) { FactoryBot.create(:user, state: "inactive") }

        it "responds with a state machine invalid transition notice" do
          expect { put admin_approve_user_path(update_user) }.to raise_error(StateMachines::InvalidTransition)
        end
      end
    end

    context "when signed in as any other user" do
      before { user.update(role: "viewer") }

      it "responds with a not authorized error" do
        expect { put admin_user_path(update_user) }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  # Admin users suspend
  describe "PUT /users/:id/suspend" do
    let(:update_user) { FactoryBot.create(:user) }
    subject { put admin_suspend_user_path(update_user) }

    context "when signed in as an admin or super admin" do
      context "and when suspending a currently approved user" do
        it "responds with a redirect status" do
          subject
          expect(response).to have_http_status(:redirect)
        end

        it "updates the users state to inactive" do
          subject
          expect(update_user.reload.inactive?).to eq(true)
        end
      end

      context "and when suspending a currently pending user" do
        let(:update_user) { FactoryBot.create(:user, state: "pending") }
        it "responds with a redirect status" do
          subject
          expect(response).to have_http_status(:redirect)
        end

        it "updates the users state to on_hold" do
          subject
          expect(update_user.reload.on_hold?).to eq(true)
        end
      end

      context "and when suspending a user that is not currently pending or active" do
        let(:update_user) { FactoryBot.create(:user, state: "inactive") }

        it "responds with a state machine invalid transition notice" do
          expect { put admin_approve_user_path(update_user) }.to raise_error(StateMachines::InvalidTransition)
        end
      end
    end

    context "when signed in as any other user" do
      before { user.update(role: "viewer") }

      it "responds with a not authorized error" do
        expect { put admin_user_path(update_user) }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  # Admin users reactivate
  describe "PUT /users/:id/reactivate" do
    subject { put admin_reactivate_user_path(update_user) }

    context "and when reactivating a currently inactive user" do
      let(:update_user) { FactoryBot.create(:user, state: "inactive") }

      it "responds with a redirect status" do
        subject
        expect(response).to have_http_status(:redirect)
      end

      it "updates the users state to active" do
        subject
        expect(update_user.reload.active?).to eq(true)
      end
    end

    context "and when reactivating a currently on_hold user" do
      let(:update_user) { FactoryBot.create(:user, state: "on_hold") }
      it "responds with a redirect status" do
        subject
        expect(response).to have_http_status(:redirect)
      end

      it "updates the users state to pending" do
        subject
        expect(update_user.reload.pending?).to eq(true)
      end
    end

    context "and when reactivating a user that is not currently inactive" do
      let(:update_user) { FactoryBot.create(:user, state: "active") }

      it "responds with a state machine invalid transition notice" do
        expect { put admin_approve_user_path(update_user) }.to raise_error(StateMachines::InvalidTransition)
      end
    end

    context "when signed in as any other user" do
      before { user.update(role: "viewer") }

      it "responds with a not authorized error" do
        expect { put admin_user_path(user) }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
