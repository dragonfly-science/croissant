class AddDescriptionToConsultation < ActiveRecord::Migration[6.0]
  def change
    add_column :consultations, :description, :text
  end
end
