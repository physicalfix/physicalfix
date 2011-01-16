class SetRolesForUsers < ActiveRecord::Migration
  def self.up
    Role.create(:name => 'Premium')
    Role.create(:name => 'Basic')
    Role.create(:name => 'Free')
    
    User.all.each do |u|
      u.add_role('Premium') unless u.has_role?('Admin')
    end
  end

  def self.down
    User.all.each do |u|
      u.remove_role('Premium')
      u.remove_role('Basic')
      u.remove_role('Free')
    end
    
    Role.find_by_name('Premium').destroy
    Role.find_by_name('Basic').destroy
    Role.find_by_name('Free').destroy
  end
end
