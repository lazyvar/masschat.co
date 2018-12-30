class MasschatUsersRequirePassword < ActiveRecord::Migration[5.2]
  def change
    change_column_null :masschat_users, :password, false
  end
end