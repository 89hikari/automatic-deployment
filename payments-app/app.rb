# frozen_string_literal: true

require 'sinatra'
require 'sinatra/base'
require_relative 'lib/list'
require_relative 'lib/payment'
require_relative 'lib/read_file'
require_relative 'lib/human'
require_relative 'lib/adress'
require_relative 'lib/statistic'

class App < Sinatra::Base

  set :bind, '0.0.0.0'
  configure do
    set :static, false
    set :pays_database, Input.read_file
  end

  get '/' do
    @pays_database = settings.pays_database
    erb :show
  end

  get '/show' do
    @pays_database = settings.pays_database
    erb :show
  end

  get '/add' do
    erb :add
  end

  post '/add' do
    hum = Human.new(params['name'], params['lastn'], params['patr'])
    adr = Address.new(params['street'], params['house'])
    pay = Payment.new(hum, adr, params['mon'], params['ob_sum'], params['kind'])
    pay.check
    @errors = pay.errors
    @ishere = 'Already exist' if settings.pays_database.exist?(pay)
    if @errors.empty? && @ishere.nil?
      settings.pays_database.add(pay)
      redirect('/show')
    else
      erb :add
    end
  end

  get '/delete_pay/:index' do
    @pay = settings.pays_database.one_pay(params['index'])
    settings.pays_database.delete(params['index'])
    redirect('/show')
  end

  get '/pay/:index' do
    @pay = settings.pays_database.one_pay(params['index'])
    erb :pay
  end

  post '/pay/:index' do
    @pay = settings.pays_database.one_pay(params['index'])
    @errors = "Введите число > 0 и <= #{@pay.ob_sum.to_i \
    - @pay.vn_sum.to_i}"
    if params['vn_sum'].to_i.positive? && params['vn_sum'].to_i <= \
                                          (@pay.ob_sum.to_i - @pay.vn_sum.to_i)
      @pay.vn_sum += params['vn_sum'].to_i
      settings.pays_database.one_pay(params['index']).vn_sum = @pay.vn_sum.to_i
      redirect('/show')
    else
      erb :pay
    end
  end

  get '/show_for_one' do
    erb :show_for_one
  end

  post '/show_for_one' do
    @pays_database = List.new
    settings.pays_database.each do |pay|
      if params['name'] == pay.fullname.name && params['lastn'] == pay.fullname.lastn && params['patr'] == \
                                                                                        pay.fullname.patr
        @pays_database.add(pay)
      end
    end
    if @pays_database.empty
      @errors = 'Something wrong'
      erb :show_for_one
    else
      erb :forone
    end
  end

  get '/group_kind' do
    erb :group_kind
  end

  post '/group_kind' do
    @pays_database = settings.pays_database.group(params['name'], \
                                                  params['lastn'], params['patr'])
    if @pays_database.empty?
      @errors = 'Not exist'
      erb :group_kind
    else
      erb :show_money
    end
  end

  get '/dolg' do
    @dolg = settings.pays_database.sort_by_lastn
    erb :dolg
  end

  get '/one_big_pay' do
    erb :one_big_pay
  end

  post '/one_big_pay' do
    pay = settings.pays_database.all_in_one(params['name'], params['lastn'], \
                                            params['patr'], params['kind'], \
                                            settings.pays_database)
    if pay.nil?
      @errors = 'Not exist'
      erb :one_big_pay
    else
      settings.pays_database.add(pay)
      redirect('/show')
    end
  end

  get '/statistic' do
    if settings.pays_database.empty
      redirect('/show')
    else
      @st = Stat.new.statistic(settings.pays_database)
      erb :statistic
    end
  end

  get '/month_pay' do
    erb :month_pay
  end

  post '/month_pay' do
    @pays_database = settings.pays_database
    peoplez = []
    @pay_month_data_base = List.new.month_pay(params['mon'], \
                                              params['kind'], \
                                              @pays_database, peoplez)
    erb :show_month_pay
  end
end

run App.run!
