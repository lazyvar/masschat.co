class VotesRequiredFields < ActiveRecord::Migration[5.2]
  def change
    change_column_null :votes, :masschat_user_id, false
    change_column_null :votes, :up, false
    change_column_null :votes, :post_id, false
  end
end
