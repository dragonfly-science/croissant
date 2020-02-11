class AddStateToConsultations < ActiveRecord::Migration[6.0]
  def change
    add_column :consultations, :state, :string
  end
end
