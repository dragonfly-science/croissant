require "rails_helper"

RSpec.describe Consultation, type: :model do
  subject { FactoryBot.build(:consultation) }

  it { is_expected.to have_attribute :name }
  it { is_expected.to have_attribute :consultation_type }

  it "is invalid without a name" do
    subject.name = ""
    expect(subject).not_to be_valid
  end

  it "is invalid without a consultation_type" do
    subject.consultation_type = ""
    expect(subject).not_to be_valid
  end

  it "is invalid with a consultation_type not included in the enum" do
    expect { subject.consultation_type = "hotdog" }.to raise_error(ArgumentError)
  end

  it "creates a new taxonomy when it is created" do
    expect(subject.taxonomy).to be_an_instance_of(Taxonomy)
  end

  context "alphabetical_order scope" do
    it "returns all consultations ordered alphabetically" do
      consultation2 = FactoryBot.create(:consultation, name: "Be a banana")
      consultation1 = FactoryBot.create(:consultation, name: "A hotdog")
      consultation3 = FactoryBot.create(:consultation, name: "The only apple")

      expect(Consultation.alphabetical_order.to_a).to eq([consultation1, consultation2, consultation3])
    end
  end

  context "active scope" do
    it "returns all consultations with an active state" do
      consultation2 = FactoryBot.create(:consultation, name: "Be a banana")
      consultation1 = FactoryBot.create(:consultation, name: "A hotdog")
      archived_consultation = FactoryBot.create(:consultation, name: "The only apple",
                                                               state: "archived")

      expect(Consultation.active.to_a).to include(consultation1, consultation2)
      expect(Consultation.active.to_a).to_not include(archived_consultation)
    end
  end

  describe "#state_changes" do
    context "with an active consultation" do
      let(:active_consultation) { FactoryBot.create(:consultation) }

      it "can change state to archived" do
        active_consultation.archive!
        expect(active_consultation.archived?).to eq(true)
      end
    end

    context "with an archived consultation" do
      let(:archived_consultation) { FactoryBot.create(:consultation, state: "archived") }

      it "can change state to active" do
        archived_consultation.restore!
        expect(archived_consultation.active?).to eq(true)
      end
    end
  end

  describe "#add_user" do
    let(:user) { FactoryBot.create(:user) }
    let(:consultation) { FactoryBot.create(:consultation) }

    context "with no role provided" do
      it "creates a new ConsultationUser with a role of viewer" do
        consultation.add_user(user)
        consultation_user = ConsultationUser.find_by(user: user, consultation: consultation)
        expect(consultation_user).not_to eq(nil)
        expect(consultation_user.role).to eq("viewer")
      end
    end

    context "with a role provided" do
      it "creates a new ConsultationUser with that role" do
        consultation.add_user(user, "admin")
        consultation_user = ConsultationUser.find_by(user: user, consultation: consultation)
        expect(consultation_user).not_to eq(nil)
        expect(consultation_user.role).to eq("admin")
      end
    end
  end
end
