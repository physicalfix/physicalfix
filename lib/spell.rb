require 'rubygems'
require 'raspell'

module Spell
  SP = Aspell.new("en")
  SP.suggestion_mode = Aspell::ULTRA
  SP.set_option("ignore-case", "false")

  def self.correct string
     string.gsub(/[\w\']+/) do |word|
       not SP.check(word) and SP.suggest(word).first or word
     end
  end
end