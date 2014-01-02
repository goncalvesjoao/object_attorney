class CreateAddresses < ActiveRecord::Migration
  def up
    create_table :addresses do |t|
      t.string :street
      t.integer :post_id
      t.timestamps
    end
  end

  def down
    drop_table :addresses
  end
end
