require "rails_helper"

RSpec.describe SurveyAnswer, type: :model do
  subject { FactoryBot.build(:survey_answer) }

  it { is_expected.to have_attribute :submission_id }
  it { is_expected.to have_attribute :survey_question_id }
  it { is_expected.to have_attribute :answer }

  it "is invalid without an answer" do
    subject.answer = ""
    expect(subject).not_to be_valid
  end
end
