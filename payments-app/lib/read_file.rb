# frozen_string_literal: true

require 'yaml'
require_relative 'payment'
require_relative 'adress'
require_relative 'human'
require_relative 'list'
# This module have function for read yaml file
module Input
  FILEWITHDATA = File.expand_path('../data/data.yaml', __dir__)
  def self.read_file
    pays_database = List.new
    exit unless File.exist?(FILEWITHDATA)
    all_info = Psych.load_file(FILEWITHDATA)
    all_info.each do |element|
      name = Human.new(element['name'], element['lastn'], element['patr'])
      adress = Address.new(element['street'], element['house'])
      full_data = Payment.new(name, adress, element['mon'], element['ob_sum'], element['kind'])
      pays_database.add(full_data)
    end
    pays_database
  end
end
