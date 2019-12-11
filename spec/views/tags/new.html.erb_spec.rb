require "rails_helper"

RSpec.describe "tags/new", type: :view do
  before(:each) do
    @consultation = FactoryBot.create(:consultation)
    assign(:tag, Tag.new(
                   taxonomy: @consultation.taxonomy,
                   name: "MyString"
                 ))
    assign(:taxonomy, @consultation.taxonomy)
  end

  it "renders new tag form" do
    render

    assert_select "form[action=?][method=?]", taxonomy_tags_path(@consultation.taxonomy), "post" do
      assert_select "input[name=?]", "tag[name]"
    end
  end
end
