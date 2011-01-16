class CreateUsers < ActiveRecord::Migration
  class User < ActiveRecord::Base
    def password=(pw)
      salt = [Array.new(6){rand(256).chr}.join].pack('m').chomp #2^48 combos
      self.password_salt, self.password_hash = salt, Digest::MD5.hexdigest(pw + salt)
    end
  end
  
  def self.up
    create_table :users do |t|
      t.column "first_name",    :string
      t.column "last_name",     :string
      t.column "email",         :string
      t.column "password_salt", :string
      t.column "password_hash", :string
      t.column "birthday", :date
      t.column "home_phone", :string
      t.column "cell_phone", :string
      t.column "height", :string
      t.column "weight", :integer
      t.column "goals", :text
      t.column "equipment", :string
      t.column "sex", :string
      t.column "target_weight", :integer
      t.timestamps
    end
    
    User.new(
      :first_name => 'Adam',
      :last_name => 'Podolnick',
      :email => 'adam@fitstream360.com',
      #:email_confirmation => 'adam@fitstream360.com',
      :password => 'fitstream',
      #:password_confirmation => 'fitstream',
      :cell_phone => '5555555555',
      :home_phone => '5555555555',
      :height => '-',
      :weight => 0,
      :target_weight => 0,
      :goals => '-',
      :birthday => Date.today,
      :sex => 'Male'
    ).save_with_validation(false)
    
    User.new(
      :first_name => 'Josh',
      :last_name => 'Zitomer',
      :email => 'josh@fitstream360.com',
      #:email_confirmation => 'josh@fitstream360.com',
      :password => 'fitstream',
      #:password_confirmation => 'fitstream',
      :cell_phone => '5555555555',
      :home_phone => '5555555555',
      :height => '-',
      :weight => 0,
      :target_weight => 0,
      :goals => '-',
      :birthday => Date.today,
      :sex => 'Male'
    ).save_with_validation(false)
    
  end

  def self.down
    drop_table :users
  end
end
