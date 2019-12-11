class CreateTags < ActiveRecord::Migration[6.0]
  def change
    create_table :tags do |t|
      t.references :taxonomy, null: false, foreign_key: true
      t.string :name
      t.references :parent

      t.timestamps
    end
  end
end
