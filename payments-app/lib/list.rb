# frozen_string_literal: true

require_relative 'payment'
# Functions for work with data list
class List
  def initialize
    @paylist = []
  end

  def add(element)
    @paylist.push(element)
  end

  def delete(index)
    @paylist.delete_at(index.to_i)
  end

  def one_pay(index)
    @paylist[index.to_i]
  end

  def size
    @paylist.size
  end

  def index(element)
    @paylist.index(element)
  end

  def each
    @paylist.each { |element| yield(element) }
  end

  def each_with_index
    @paylist.each_with_index { |element, index| yield(element, index) }
  end

  def empty
    return true if @paylist.empty?
  end

  def exist?(pay)
    check = false
    @paylist.each do |element|
      if pay.fullname.name_str == element.fullname.name_str && pay.adr.adr_str == element.adr.adr_str
        check = true if pay.kind == element.kind && pay.mon.to_i == element.mon.to_i && \
                        pay.ob_sum.to_i == element.ob_sum.to_i
      end
    end
    check
  end

  def group(name, lastn, patr)
    group_data = []
    @paylist.each do |element|
      if element.fullname.name == name && element.fullname.lastn == lastn && element.fullname.patr == patr
        group_data.push(element)
      end
    end
    group_data
  end

  def sort_by_lastn
    sort_data = []
    @paylist.each do |element1|
      check = true
      sort_data.each do |element2|
        if element2.fullname.name_str == element1.fullname.name_str
          check = false if element2.kind == element1.kind
        end
      end
      sort_data.push(element1) if element1.ob_sum.to_i > element1.vn_sum && check
    end
    sort_data.sort_by { |element| element.fullname.lastn }
  end

  def search_with_kind(name, lastn, patr, kind, database)
    tmp = []
    database.each_with_index do |pay, _index|
      if pay.fullname.lastn == lastn && pay.fullname.name == name && pay.fullname.patr == patr
        tmp.push(pay) if pay.kind == kind
      end
    end
    tmp.each do |elm|
      database.delete(database.index(elm))
    end
    tmp
  end

  def all_in_one(name, lastn, patr, kind, database)
    tmp = search_with_kind(name, lastn, patr, kind, database)

    big_pay = tmp[0]
    tmp.each_with_index do |pay, index|
      next if index.zero?

      big_pay.vn_sum += pay.vn_sum
      big_pay.ob_sum = big_pay.ob_sum .to_i + pay.ob_sum .to_i
      big_pay.mon = pay.mon if pay.mon.to_i > big_pay.mon.to_i
    end
    big_pay
  end

  def month_pay(mon, kind, database, peoplez)
    deletebase = []
    database.each do |pay|
      check = true
      peoplez.each do |person|
        check = false if person.name_str == pay.fullname.name_str
      end
      peoplez.push(pay.fullname) if check
      deletebase.push(pay.fullname) if pay.mon.to_i == mon.to_i && pay.kind == kind
    end
    deletebase.each do |elm|
      peoplez.each_with_index do |person, index|
        peoplez.delete_at(index) if person.name_str == elm.name_str
      end
    end
    peoplez
  end
end
