require "rails_helper"

RSpec.describe SurveyQuestion, type: :model do
  subject { FactoryBot.create(:survey_question) }

  it { is_expected.to have_attribute :survey_id }
  it { is_expected.to have_attribute :question }
  it { is_expected.to have_attribute :token }

  it "is invalid without a question" do
    subject.question = ""
    expect(subject).not_to be_valid
  end

  it "has a token" do
    expect(subject.token).to eq("SQ_#{subject.survey_id}_#{subject.id}")
  end
end
