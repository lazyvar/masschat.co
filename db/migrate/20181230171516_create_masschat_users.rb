class CreateMasschatUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :masschat_users do |t|
      t.string :username
      t.string :password
    end

    add_index :masschat_users, :username, unique: true
  end
end
