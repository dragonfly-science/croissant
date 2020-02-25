class CreateConsultationUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :consultation_users do |t|
      t.references :user
      t.references :consultation
      t.integer :role, default: 0

      t.timestamps
    end
  end
end
