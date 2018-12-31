class ModifyUsersForSms < ActiveRecord::Migration[5.2]
  def change
    drop_table :masschat_users
    create_table :masschat_users do |t|
      t.string :username 
      t.string :phonenumber

      t.timestamps
    end

    add_index :masschat_users, :username, unique: true
    change_column_null :masschat_users, :username, false
    add_index :masschat_users, :phonenumber, unique: true
    change_column_null :masschat_users, :phonenumber, false
  end
end
