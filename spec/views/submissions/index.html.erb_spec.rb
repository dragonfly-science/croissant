require "rails_helper"

RSpec.describe "submissions/index", type: :view do
  before(:each) do
    @consultation = assign(:consultation, FactoryBot.create(:consultation))
    FactoryBot.create_list(:submission, 2)
    assign(:submissions, @consultation.submissions.page(1))
    assign(:filter, SubmissionFilter.new(@consultation.submissions, {}))
  end

  it "renders a list of submissions" do
    render
  end
end
