class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name
    end
    
    create_table :user_roles do |t|
      t.integer :user_id, :role_id
      t.timestamps
    end
    
    add_index :roles, :name
    Role.create(:name => 'Admin')
    User.find_by_email('adam@fitstream360.com').add_role('Admin')
    User.find_by_email('josh@fitstream360.com').add_role('Admin')
    
  end

  def self.down
    drop_table :roles
    drop_table :user_roles
  end
end
