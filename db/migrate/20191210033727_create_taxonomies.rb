class CreateTaxonomies < ActiveRecord::Migration[6.0]
  def change
    create_table :taxonomies do |t|
      t.references :consultation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
