class AddTextToSubmission < ActiveRecord::Migration[6.0]
  def change
    change_table :submissions, bulk: true do |t|
      t.text :text
      t.text :description
    end
  end
end
