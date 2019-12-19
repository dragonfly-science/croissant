class AddSubmitterTypeToSubmission < ActiveRecord::Migration[6.0]
  def change
    add_column :submissions, :submitter_type, :string
  end
end
