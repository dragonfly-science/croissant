require "rails_helper"

RSpec.describe SurveyQuestionExporter do
  let(:consultation) { FactoryBot.create(:consultation, name: "Test Consultation") }
  let!(:survey_1) { FactoryBot.create(:survey, consultation: consultation) }
  let!(:survey_2) { FactoryBot.create(:survey, consultation: consultation) }
  let!(:survey_question_1) { FactoryBot.create(:survey_question, survey: survey_1) }
  let!(:survey_question_2) { FactoryBot.create(:survey_question, survey: survey_2) }

  subject { SurveyQuestionExporter.new(consultation) }

  it "creates a CSV with columns of information about the survey question" do
    csv = subject.export
    expect(csv).to start_with("survey_id,survey_question,question_token\n")
  end

  it "includes a row for all survey questions for the consultation" do
    expect(subject.export.lines.count).to eq(SurveyQuestion.count + 1)
  end

  it "includes the survey id, survey question and token for each survey question" do
    csv = subject.export
    expect(csv).to include("#{survey_1.id},#{survey_question_1.question},#{survey_question_1.token}")
    expect(csv).to include("#{survey_2.id},#{survey_question_2.question},#{survey_question_2.token}")
  end

  it "includes the date and consultation name in the filename" do
    expect(subject.filename).to eq("#{Time.zone.today.iso8601}-test-consultation-survey-questions.csv")
  end

  context "when the question contains a comma" do
    it "adds '' around the question" do
      survey_question_3 = FactoryBot.create(:survey_question,
                                            survey: survey_1,
                                            question: "Do you like questions with, commas?")
      csv = subject.export
      expect(csv).to include("#{survey_1.id},\"#{survey_question_3.question}\",#{survey_question_3.token}")
    end
  end
end
