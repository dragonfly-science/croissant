require "rails_helper"

RSpec.describe "Consultations", type: :request do
  let(:consultation) { FactoryBot.create(:consultation) }
  let(:superadmin) { FactoryBot.create(:user, role: "superadmin") }
  before do
    sign_in(superadmin)
  end

  # Admin consultations index
  describe "GET /admin/consultations" do
    subject { get admin_consultations_path }

    context "when signed in as an admin or super admin" do
      it "responds with an ok status" do
        subject
        expect(response).to have_http_status(:ok)
      end

      context "with an instance variable assigned for all consultations" do
        let!(:consultation3) { FactoryBot.create(:consultation, name: "Pancake factory") }
        let!(:consultation1) { FactoryBot.create(:consultation, name: "Iguana farm") }
        let!(:consultation2) { FactoryBot.create(:consultation, name: "Llama lakes", state: "archived") }

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

    context "when signed in as any other user" do
      before { superadmin.update(role: "viewer") }

      it "responds with a not authorized error" do
        expect { get admin_consultations_path }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  # Admin consultations archive
  describe "PUT /admin/consultations/:id/archive" do
    subject { put admin_archive_consultation_path(consultation) }

    context "when signed in as an admin or super admin" do
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
      before { superadmin.update(role: "viewer") }

      it "responds with a not authorized error" do
        expect { subject }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  # Admin consultations restore
  describe "PUT /admin/consultations/:id/restore" do
    subject { put admin_restore_consultation_path(consultation) }

    context "when signed in as an admin or super admin" do
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
      before { superadmin.update(role: "viewer") }

      it "responds with a not authorized error" do
        expect { subject }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
