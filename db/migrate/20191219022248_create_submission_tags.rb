class CreateSubmissionTags < ActiveRecord::Migration[6.0]
  def change
    create_table :submission_tags do |t|
      t.belongs_to :submission
      t.belongs_to :tag
      t.integer :start_char
      t.integer :end_char

      t.timestamps
    end
  end
end
