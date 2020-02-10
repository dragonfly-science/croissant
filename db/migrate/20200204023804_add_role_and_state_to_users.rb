class AddRoleAndStateToUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :users, bulk: true do |t|
      t.integer :role, default: 0
      t.string :state
    end
  end
end
