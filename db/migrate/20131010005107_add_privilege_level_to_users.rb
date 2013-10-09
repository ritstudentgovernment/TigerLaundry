class AddPrivilegeLevelToUsers < ActiveRecord::Migration
  def change
    add_column :users, :privilege_level, :integer, default: 0, null: false
  end
end
