require "rails_helper"

RSpec.describe "submissions/show", type: :view do
  before(:each) do
    @consultation = assign(:consultation, FactoryBot.create(:consultation))
    @submission = assign(:submission, FactoryBot.create(:submission, consultation: @consultation))
  end

  it "renders attributes in <p>" do
    render
  end
end
