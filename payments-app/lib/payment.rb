# frozen_string_literal: true

# Initialization for all payment, some errors check is included
class Payment
  attr_accessor :fullname, :adr, :mon, :ob_sum, :vn_sum, :kind, :errors
  def initialize(fullname, adr, mon, ob_sum, kind)
    @fullname = fullname
    @adr = adr
    @mon = mon
    @ob_sum = ob_sum
    @vn_sum = 0
    @kind = kind
  end

  def check
    @errors = {}
    empty = 'Заполните здесь'
    zero = 'Либо пусто, либо нужно число > 0'
    check_space1(empty)
    check_space2(zero)
  end

  def check_space1(message)
    @errors[:name] = message if @fullname.name.empty?
    @errors[:lastn] = message if @fullname.lastn.empty?
    @errors[:patr] = message if @fullname.patr.empty?
  end

  def check_space2(message)
    @errors[:adres] = message if @adr.house.empty? || @adr.house.to_i <= 0
    @errors[:adres_1] = message if @adr.street.empty?
    @errors[:sum] = message if @ob_sum.empty? || @ob_sum.to_i <= 0
  end
end
