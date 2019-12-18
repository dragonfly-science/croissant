class AddStateToSubmission < ActiveRecord::Migration[6.0]
  def change
    add_column :submissions, :state, :string
  end
end
