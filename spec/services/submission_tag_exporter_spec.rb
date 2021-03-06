require "rails_helper"

RSpec.describe SubmissionTagExporter do
  let(:consultation) { FactoryBot.create(:consultation, name: "With a Space") }
  let(:taxonomy) { consultation.taxonomy }
  let!(:tag1) { FactoryBot.create(:tag, taxonomy: taxonomy, name: "Bears") }
  let!(:tag11) { FactoryBot.create(:tag, taxonomy: taxonomy, name: "Polar", parent: tag1) }
  let!(:tag2) { FactoryBot.create(:tag, taxonomy: taxonomy, name: "Wolves") }
  let(:submission1) { FactoryBot.create(:submission, :ready_to_tag, consultation: consultation) }
  let(:submission2) { FactoryBot.create(:submission, :ready_to_tag, consultation: consultation) }
  let(:tagger) { FactoryBot.create(:user) }
  let(:survey_answer) { FactoryBot.create(:survey_answer, answer: "The bird in flight", submission: submission1) }

  # to test for false positive inclusions
  let!(:other_consult) { FactoryBot.create(:consultation) }
  let!(:other_tag) { FactoryBot.create(:tag, taxonomy: other_consult.taxonomy, name: "Trees") }
  let!(:other_submission) { FactoryBot.create(:submission, :ready_to_tag, consultation: other_consult) }

  let!(:st1) { submission1.add_tag(tag: tag1, start_char: 0, end_char: 4, text: "bear", tagger: tagger) }
  let!(:st2) { submission1.add_tag(tag: tag11, start_char: 5, end_char: 10, text: "polar") }
  let!(:st3) { submission2.add_tag(tag: tag1, start_char: 0, end_char: 4, text: "roar") }
  let!(:st4) { submission2.add_tag(tag: tag2, start_char: 0, end_char: 4, text: "roar") }
  let!(:st5) { survey_answer.add_tag(tag: tag2, start_char: 4, end_char: 7, text: "bird") }
  let!(:other_st) { other_submission.add_tag(tag: other_tag, start_char: 0, end_char: 4, text: "1234") }

  subject { SubmissionTagExporter.new(consultation) }

  it "creates a CSV with columns of information about submission, tag, and submission_tag" do
    csv = subject.export
    column_names = %w[submission_id tag_id submission_filename survey_question_token tag_name tag_number
                      quote start_char end_char tagger tagtime]
    expect(csv).to start_with("#{column_names.join(",")}\n")
  end

  it "includes all submission_tags in number order" do
    sts = [st1, st2, st3, st4, st5]
    expect(subject.export.lines.count).to eq(sts.count + 1)
    expect(subject.items.to_a).to match_array(sts)
  end

  it "includes the full number, name and ID for each tag" do
    csv = subject.export
    expect(csv).to include(
      "#{submission1.id},#{st1.id},00988_Anonymous.pdf,\"\",Bears,1,bear,0,4,#{tagger.email},#{st1.created_at}"
    )
    expect(csv).to include(
      "#{submission1.id},#{st2.id},00988_Anonymous.pdf,\"\",Polar,1.1,polar,5,10,\"\",#{st2.created_at}"
    )
    expect(csv).to include(
      "#{submission2.id},#{st3.id},00988_Anonymous.pdf,\"\",Bears,1,roar,0,4,\"\",#{st3.created_at}")
    expect(csv).to include(
      "#{submission2.id},#{st4.id},00988_Anonymous.pdf,\"\",Wolves,2,roar,0,4,\"\",#{st4.created_at}")
    expect(csv).to include(
      "#{submission1.id},#{st5.id},00988_Anonymous.pdf,#{st5.survey_question_token},"\
      "Wolves,2,bird,4,7,\"\",#{st5.created_at}")
  end

  it "includes the date and consultation name in the filename" do
    expect(subject.filename).to eq("#{Time.zone.today.iso8601}-with-a-space-tags.csv")
  end
end
