require "rails_helper"

RSpec.describe "Consultation Users", type: :request do
  let(:consultation) { FactoryBot.create(:consultation) }
  let(:superadmin) { FactoryBot.create(:user, role: "superadmin") }
  before do
    sign_in(superadmin)
  end

  # Admin consultation users create
  describe "POST /admin/consultation_users" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:params) { { user_id: user.id, consultation_id: consultation.id, role: "viewer", format: "js" } }
    subject { post admin_consultation_users_path(params) }

    context "when signed in as an admin or super admin" do
      it "creates a new consultation user" do
        subject
        consultation_user = ConsultationUser.find_by(user: user, consultation: consultation)
        expect(consultation_user).not_to be_nil
      end
    end

    context "when signed in as any other user" do
      before { superadmin.update(role: "viewer") }

      it "responds with a not authorized error" do
        expect { subject }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  # Admin consultation users destroy
  describe "DELETE /admin/consultation_user" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:consultation_user) { FactoryBot.create(:consultation_user, user: user, consultation: consultation) }
    subject { delete admin_consultation_user_path(consultation_user.id, format: "js") }

    context "when signed in as an admin or super admin" do
      before { subject }

      it "destroys an existing consultation user" do
        deleted_consultation_user = ConsultationUser.find_by(user: user, consultation: consultation)
        expect(deleted_consultation_user).to be_nil
      end

      it "does not destroy the consultation or user records" do
        expect(user).not_to be_nil
        expect(consultation).not_to be_nil
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
