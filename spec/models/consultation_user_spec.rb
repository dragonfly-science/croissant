require "rails_helper"

RSpec.describe ConsultationUser, type: :model do
  subject { FactoryBot.build(:consultation_user) }

  it { is_expected.to have_attribute :role }

  it "is invalid without a role" do
    subject.role = ""
    expect(subject).not_to be_valid
  end

  it "is invalid with a role not included in the enum" do
    expect { subject.role = "dingo" }.to raise_error(ArgumentError)
  end
end
