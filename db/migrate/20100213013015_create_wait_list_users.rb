class CreateWaitListUsers < ActiveRecord::Migration
  def self.up
    create_table :wait_list_users do |t|
      t.string :email_address
      t.timestamps
    end
  end

  def self.down
    drop_table :wait_list_users
  end
end
