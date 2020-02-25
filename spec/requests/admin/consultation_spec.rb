require "rails_helper"

RSpec.describe "Consultations", type: :request do
  let(:consultation) { FactoryBot.create(:consultation) }
  let(:user) { FactoryBot.create(:user, role: "superadmin") }
  before do
    sign_in(user)
  end

  # Admin consultations index
  describe "GET /admin/consultations" do
    let!(:consultation3) { FactoryBot.create(:consultation, name: "Pancake factory") }
    let!(:consultation1) { FactoryBot.create(:consultation, name: "Iguana farm") }
    let!(:consultation2) { FactoryBot.create(:consultation, name: "Llama lakes", state: "archived") }
    subject { get admin_consultations_path }

    it "responds with an ok status" do
      subject
      expect(response).to have_http_status(:ok)
    end

    context "when signed in as a superadmin" do
      context "with an instance variable assigned for all consultations" do
        it "orders consultations alphabetically by default" do
          subject
          expect(assigns(:consultations).to_a).to eq([consultation1, consultation2, consultation3])
        end

        it "orders consultations by a param if one is provided" do
          get admin_consultations_path(order: "state DESC")
          expect(assigns(:consultations).to_a).to eq([consultation2, consultation3, consultation1])
        end
      end
    end

    context "when signed in as a consultation admin" do
      before do
        user.update(role: "editor")
        ConsultationUser.create(user: user, consultation: consultation1, role: "admin")
        ConsultationUser.create(user: user, consultation: consultation2, role: "admin")
      end

      context "with an instance variable assigned for all consultations" do
        it "orders all consultations alphabetically by default" do
          subject
          expect(assigns(:consultations).to_a).to eq([consultation1, consultation2])
          expect(assigns(:consultations).to_a).not_to include(consultation3)
        end
      end
    end

    context "when signed in as any other user" do
      before { user.update(role: "viewer") }

      it "responds with a not authorized error" do
        expect { get admin_consultations_path }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  # Admin consultations archive
  describe "PUT /admin/consultations/:id/archive" do
    subject { put admin_archive_consultation_path(consultation) }

    context "when signed in as a consultation admin or super admin" do
      context "and when archiving a currently active consultation" do
        it "responds with a redirect status" do
          subject
          expect(response).to have_http_status(:redirect)
        end

        it "updates the users state to active" do
          subject
          expect(consultation.reload.archived?).to eq(true)
        end
      end

      context "and when archiving a consultation that is already archived" do
        before { consultation.archive! }

        it "responds with a state machine invalid transition notice" do
          expect { subject }.to raise_error(StateMachines::InvalidTransition)
        end
      end
    end

    context "when signed in as any other user" do
      before { user.update(role: "viewer") }

      it "responds with a not authorized error" do
        expect { subject }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  # Admin consultations restore
  describe "PUT /admin/consultations/:id/restore" do
    subject { put admin_restore_consultation_path(consultation) }

    context "when signed in as a consultation admin or super admin" do
      context "and when restoring a currently archived consultation" do
        before { consultation.archive! }

        it "responds with a redirect status" do
          subject
          expect(response).to have_http_status(:redirect)
        end

        it "updates the users state to active" do
          subject
          expect(consultation.reload.active?).to eq(true)
        end
      end

      context "and when restoring a consultation that is already active" do
        it "responds with a state machine invalid transition notice" do
          expect { subject }.to raise_error(StateMachines::InvalidTransition)
        end
      end
    end

    context "when signed in as any other user" do
      before { user.update(role: "viewer") }

      it "responds with a not authorized error" do
        expect { subject }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  # Admin consultations edit
  describe "GET /admin/consultations/:id/edit" do
    subject { get edit_admin_consultation_path(consultation) }

    context "when signed in as a consultation admin or super admin" do
      it "responds with an ok status" do
        subject
        expect(response).to have_http_status(:ok)
      end

      it "assigns an instance variable for the consultation" do
        subject
        expect(assigns(:consultation)).to eq(consultation)
      end
    end

    context "when signed in as any other user" do
      before { user.update(role: "viewer") }

      it "responds with a not authorized error" do
        expect { get edit_admin_consultation_path(consultation) }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  # Admin consultations update
  describe "PUT /admin/consultations/:id/edit" do
    let!(:params) do
      { id: consultation.id, consultation: { name: "new test consultation",
                                             consultation_type: "engagement",
                                             description: "new description" } }
    end
    subject { put admin_consultation_path(params) }

    context "when signed in as a consultation admin or super admin" do
      it "responds with an ok status" do
        subject
        expect(response).to have_http_status(302)
      end

      it "updates the consultation" do
        subject
        consultation.reload
        expect(consultation.name).to eq(params[:consultation][:name])
        expect(consultation.consultation_type).to eq(params[:consultation][:consultation_type])
        expect(consultation.description).to eq(params[:consultation][:description])
      end
    end

    context "when signed in as any other user" do
      before { user.update(role: "viewer") }

      it "responds with a not authorized error" do
        expect { get edit_admin_consultation_path(consultation) }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
