class CreateTableMasschatPost < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.string :url
      t.string :query
      t.belongs_to :author, index: true
      t.timestamps
    end
  end
end
