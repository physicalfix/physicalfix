class CreateFreebies < ActiveRecord::Migration
  def self.up
    create_table :freebies do |t|
      t.column "email", :string
      t.column "key", :string
      t.column "used", :boolean
      t.column "membership_type", :string
      t.timestamps
    end
  end

  def self.down
    drop_table :freebies
  end
end
