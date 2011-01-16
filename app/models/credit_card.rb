class CreditCard < ActiveRecord::Base
  def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :first_name, :string
  column :last_name, :string
  column :expiration, :date
  column :card_number, :string
  column :cvv, :string

  validates_presence_of :first_name, :last_name, :expiration, :card_number, :cvv
  validates_format_of :cvv, :with => /\A([0-9]{3,4})\Z/i

  validate do |card|
    card.valid_number?
  end
  
  def valid_number?
    unless valid_test_mode_card_number?(card_number) || valid_card_number_length?(card_number) &&  valid_checksum?(card_number)
      errors.add(:card_number, 'Invalid')
    end
  end
  
  private
  
  def valid_card_number_length?(number)
    number.to_s.length >= 12
  end
  
  def valid_test_mode_card_number?(number)
    RAILS_ENV != 'production' && %w[1 2 3].include?(number.to_s)
  end
  
  # Checks the validity of a card number by use of the the Luhn Algorithm. 
  # Please see http://en.wikipedia.org/wiki/Luhn_algorithm for details.
  def valid_checksum?(number)
    sum = 0
    for i in 0..number.length
      weight = number[-1 * (i + 2), 1].to_i * (2 - (i % 2))
      sum += (weight < 10) ? weight : weight - 9
    end
    (number[-1,1].to_i == (10 - sum % 10) % 10)
  end
  
end