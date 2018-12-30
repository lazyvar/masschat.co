class CreateVotesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :votes do |t|
      t.belongs_to :masschat_user, index: true
      t.boolean :up
      t.belongs_to :post, index: true
      t.timestamps
    end
  end
end
