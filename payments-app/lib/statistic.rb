# frozen_string_literal: true

require_relative 'payment'

# This class have functions for statistic's counting
class Stat
  def people_count(database)
    peoplz = []
    database.each do |one|
      exist = false
      peoplz.each do |two|
        exist = true if two.fullname.name_str == one.fullname.name_str
      end
      peoplz.push(one) if !exist
    end
    peoplz.size
  end

  def sred_sum(database)
    sum = 0
    database.each do |pay|
      sum += pay.ob_sum.to_i
    end
    sum / database.size
  end

  def sred_sum_done(database)
    sum = 0
    database.each do |pay|
      sum += pay.vn_sum.to_i
    end
    sum / database.size
  end

  def main_kind(database)
    tel = 0
    rent = 0
    el = 0
    database.each do |elem|
      tel += 1 if elem.kind == 'Telephone'
      rent += 1 if elem.kind == 'Rent'
      el += 1 if elem.kind == 'ElectricPower'
    end
    mas = { 'Telephone' => tel, 'Rent' => rent, 'ElectricPower' => el }
    max = 0
    mas.each do |_key, value|
      max = value if value > max
    end
    mas.key(max)
  end

  def sum_for_main_kind(database, main_kind)
    sum = 0
    count = 0
    database.each do |elem|
      if elem.kind == main_kind
        sum += elem.ob_sum.to_i
        count += 1
      end
    end
    sum / count
  end

  def statistic(database)
    stat = [people_count(database), sred_sum(database), sred_sum_done(database), main_kind(database), \
            sum_for_main_kind(database, main_kind(database))]
    stat
  end
end
