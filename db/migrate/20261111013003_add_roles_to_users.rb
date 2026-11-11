class AddRolesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :roles, :string
  end
end
