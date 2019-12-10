class CreateConsultations < ActiveRecord::Migration[6.0]
  def change
    create_table :consultations do |t|
      t.string  :name, null: false
      t.integer :consultation_type, null: false

      t.timestamps
    end
  end
end
