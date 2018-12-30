class MasschatUsersRenamePassword < ActiveRecord::Migration[5.2]
  def change
    rename_column :masschat_users, :password, :password_digest
  end
end
