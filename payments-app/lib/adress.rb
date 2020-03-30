# frozen_string_literal: true

# Initialization for adress is here
class Address
  attr_accessor :street, :house
  def initialize(street, house)
    @street = street
    @house = house
  end

  def adr_str
    "#{@street} + #{@house}"
  end
end
