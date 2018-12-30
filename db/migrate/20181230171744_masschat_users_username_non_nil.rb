class MasschatUsersUsernameNonNil < ActiveRecord::Migration[5.2]
  def change
    change_column_null :masschat_users, :username, false
  end
end
