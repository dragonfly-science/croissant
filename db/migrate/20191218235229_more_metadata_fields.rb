class MoreMetadataFields < ActiveRecord::Migration[6.0]
  def change
    change_table :submissions, bulk: true do |t|
      t.boolean :exemplar
      t.boolean :maori_perspective
      t.boolean :pacific_perspective
      t.boolean :high_impact_stakeholder
      t.boolean :high_relevance_stakeholder
      t.string :age_bracket
      t.string :ethnicity
      t.string :gender
    end
  end
end
