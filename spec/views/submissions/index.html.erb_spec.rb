require "rails_helper"

RSpec.describe "submissions/index", type: :view do
  before(:each) do
    @consultation = assign(:consultation, FactoryBot.create(:consultation))
    assign(:submissions, FactoryBot.create_list(:submission, 2))
  end

  it "renders a list of submissions" do
    render
  end
end
