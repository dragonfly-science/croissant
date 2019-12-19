class AddFileHashToSubmission < ActiveRecord::Migration[6.0]
  def change
    add_column :submissions, :file_hash, :string
  end
end
