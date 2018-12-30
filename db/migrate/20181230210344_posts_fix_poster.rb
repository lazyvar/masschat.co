class PostsFixPoster < ActiveRecord::Migration[5.2]
  def change
    remove_column :posts, :author_id
    add_column :posts, :masschat_user_id, :int8
    add_reference :masschat_users, index: true
    change_column_null :posts, :masschat_user_id, false
  end
end
