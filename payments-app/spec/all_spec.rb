# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Payments', type: :feature do
  before(:example) do
    Capybara.app = Sinatra::Application.new
  end

  it 'Проверка перехода к /' do
    visit('/')
    expect(page).to have_content('Коммунальные платежи')
  end

  it 'Проверка перехода к /show' do
    visit('/show')
    expect(page).to have_content('Коммунальные платежи')
  end

  it 'Тест на добавление' do
    visit('/')
    click_on('Добавить')
    fill_in('name', with: 'Kolya')
    fill_in('lastn', with: 'Pupkin')
    fill_in('patr', with: 'Evgenievich')
    fill_in('street', with: 'Pushkina')
    fill_in('house', with: '15')
    select('1', from: 'mon')
    fill_in('ob_sum', with: '1234')
    select('Telephone', from: 'kind')
    click_on('Добавить платёж')
    expect(page).to have_content('Список платежей')
  end

  it 'Тест на ошибки при добавлении' do
    visit('/')
    click_on('Добавить')
    expect(page).to have_content('Добавление платежа')
    click_on('Добавить платёж')
    expect(page).to have_content('Заполните здесь')
    expect(page).to have_content('Либо пусто, либо нужно число > 0')
  end

  it 'Тест на добавление элемента, который уже есть' do
    visit('/')
    click_on('Добавить')
    expect(page).to have_content('Добавление платежа')
    fill_in('name', with: 'Michail')
    fill_in('lastn', with: 'Romanov')
    fill_in('patr', with: 'Petrovich')
    fill_in('street', with: 'Some')
    fill_in('house', with: '33')
    select('8', from: 'mon')
    fill_in('ob_sum', with: '2000')
    select('Rent', from: 'kind')
    click_on('Добавить платёж')
    expect(page).to have_content('Already exist')
  end

  it 'Тест на оплату' do
    visit('/')
    sum = find_by_id('vn_sum', match: :first).text
    click_on('Оплатить', id: 'pay-0')
    expect(page).to have_content('Оплата')
    fill_in('vn_sum', with: '12')
    click_on('Оплатить')
    expect(page).to have_content(sum.to_i + 12)
  end

  it 'Тест на удаление' do
    visit('/')
    name = 'Michail'
    lastn = 'Romanov'
    patr = 'Petrovich'
    mon = 8
    kind = 'Rent'
    ob_sum = 2000
    vn_sum = 0
    click_on('Удалить', id: 'delete-2')
    expect(page).not_to have_content(include(name).and(include(lastn).and(include(patr)
    .and(include(mon).and(include(kind)
    .and(include(ob_sum).and(include(vn_sum))))))))
  end

  it 'Ошибка оплаты' do
    visit('/')
    click_on('Оплатить', id: 'pay-0')
    click_on('Оплатить')
    expect(page).to have_content('Введите число > 0 и <= ')
  end

  it 'Тест на статистику' do
    visit('/')
    click_on('Статистика')
    expect(page).to have_content('Статистика')
  end

  it 'Должники' do
    visit('/')
    click_on('Должники')
    expect(page).to have_content('Список должников')
  end

  it 'Тест на вывод всех счетов человека' do
    visit('/')
    click_on('Платежи одного человека')
    fill_in('name'.to_s, with: 'Vlad')
    fill_in('lastn'.to_s, with: 'Belousov')
    fill_in('patr'.to_s, with: 'Denisovich')
    click_on('Показать все счета человека')
    expect(page).to have_content('Vlad')
    expect(page).to have_content('Belousov')
    expect(page).to have_content('Denisovich')
  end

  it 'Ошибка вывода всех счетов человека' do
    visit('/')
    click_on('Платежи одного человека')
    click_on('Показать все счета человека')
    expect(page).to have_content('Something wrong')
  end

  it 'Ошибка при объединении счетов' do
    visit('/')
    click_on('Общий счёт')
    click_on('Объединить')
    expect(page).to have_content('Not exist')
  end

  it 'Тест на объединение счетов' do
    visit('/')
    click_on('Общий счёт')
    fill_in('name', with: 'Vlad')
    fill_in('lastn', with: 'Belousov')
    fill_in('patr', with: 'Denisovich')
    select('Telephone', from: 'kind')
    click_on('Объединить')
    expect(page).to have_content('Список платежей')
  end

  it 'Тест группировки по типу' do
    visit('/')
    click_on('Сгруппировать по типу')
    expect(page).to have_content('Группировка по типу')
    fill_in('name', with: 'Vlad')
    fill_in('lastn', with: 'Belousov')
    fill_in('patr', with: 'Denisovich')
    click_on('Показать')
    expect(page).to have_content('Нужно еще заплатить')
  end

  it 'Ошика при группировке по типу' do
    visit('/')
    click_on('Сгруппировать по типу')
    click_on('Показать')
    expect(page).to have_content('Not exist')
  end

  it 'Тест на невыставленные счета' do
    visit('/')
    click_on('Не выставлены счета по опр. типу')
    expect(page).to have_content('Люди, которым не выставлен счёт за месяц по указанному типу')
    select('6', from: 'mon')
    select('Telephone', from: 'kind')
    click_on('Показать')
    expect(page).to have_content('Список людей которым не выставлен счёт')
  end
end
