# frozen_string_literal: true

# Initialization for FIO is here
class Human
  attr_accessor :name, :lastn, :patr
  def initialize(name, lastn, patr)
    @name = name
    @lastn = lastn
    @patr = patr
  end

  def name_str
    "#{@name} #{@lastn} #{@patr}"
  end
end
