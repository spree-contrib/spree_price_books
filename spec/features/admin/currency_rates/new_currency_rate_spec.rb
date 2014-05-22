require 'spec_helper'

feature 'Admin - Currency Rates - New', js: true do
  stub_authorization!

  before do
    visit spree.admin_currency_rates_path
    click_on 'New Currency Rate'
  end

  scenario 'can be created' do
    fill_in 'currency_rate[base_currency]', with: 'USD'
    fill_in 'currency_rate[currency]', with: 'GBP'
    fill_in 'currency_rate[exchange_rate]', with: 1.6
    click_on 'Create'
    expect(page).to have_content('Currency Rate has been successfully created!')
  end
end
