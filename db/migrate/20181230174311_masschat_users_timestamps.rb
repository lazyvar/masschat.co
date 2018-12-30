class MasschatUsersTimestamps < ActiveRecord::Migration[5.2]
  def change
    add_column :masschat_users, :created_at, :timestamp
    add_column :masschat_users, :updated_at, :timestamp
  end
end
