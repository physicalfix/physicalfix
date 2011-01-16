class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.integer :subscription_id
      t.float :amount
      t.boolean :success, :test
      t.string  :reference, :message, :action
      t.text  :params
      
      t.timestamps
    end
  end

  def self.down
    drop_table :transactions
  end
end
