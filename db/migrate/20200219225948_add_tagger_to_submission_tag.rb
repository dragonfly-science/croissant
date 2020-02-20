class AddTaggerToSubmissionTag < ActiveRecord::Migration[6.0]
  def change
    change_table :submission_tags do |t|
      t.references :tagger, index: true, foreign_key: { to_table: :users }, null: true
    end
  end
end
