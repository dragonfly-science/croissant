require "rails_helper"

RSpec.describe "taxonomies/show", type: :view do
  before(:each) do
    @consultation = FactoryBot.create(:consultation)
    @taxonomy = assign(:taxonomy, @consultation.taxonomy)
  end

  it "renders attributes in <p>" do
    @tag = FactoryBot.create(:tag, taxonomy: @taxonomy)
    render
    expect(rendered).to have_content(@tag.name)
  end

  it "renders new tag form" do
    render

    assert_select "form[action=?][method=?]", taxonomy_tags_path(@consultation.taxonomy), "post" do
      assert_select "input[name=?]", "tag[name]"
    end
  end
end
