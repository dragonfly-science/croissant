class AddTextToSubmissionTag < ActiveRecord::Migration[6.0]
  def change
    add_column :submission_tags, :text, :string
  end
end
