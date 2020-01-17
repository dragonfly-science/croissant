require "rails_helper"

RSpec.describe SubmissionSeparator do
  let(:blank_submission) { FactoryBot.create(:submission, text: nil) }
  let(:short_submission) { FactoryBot.create(:submission, text: "12345") }
  let(:long_submission) { FactoryBot.create(:submission, text: "12345\n67890\nabcde") }
  it "returns one SubmissionPart object for blank submissions" do
    separator = SubmissionSeparator.new(blank_submission, character_limit: 6)
    expect(separator.part_count).to eq(1)
    expect(separator.parts).to eq([SubmissionPart.new(blank_submission, 1, "")])
  end
  it "returns one SubmissionPart object for submissions under the length specified" do
    separator = SubmissionSeparator.new(short_submission, character_limit: 6)
    expect(separator.part_count).to eq(1)
    expect(separator.parts).to eq([SubmissionPart.new(short_submission, 1, "12345")])
  end
  it "returns SubmissionPart objects with text of the length specified" do
    separator = SubmissionSeparator.new(long_submission, character_limit: 6)
    expect(separator.part_count).to eq(3)
    expect(separator.parts).to include(SubmissionPart.new(long_submission, 1, "12345\n"))
  end
end
