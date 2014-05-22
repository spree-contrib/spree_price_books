require 'spec_helper'

feature 'Admin - Currency Rates - Edit', js: true do
  stub_authorization!

  before do
    create(:currency_rate)
    visit spree.admin_currency_rates_path
    within_row(1) { click_icon :edit }
  end

  scenario 'can be edited' do
    fill_in 'currency_rate[base_currency]', with: 'USD'
    fill_in 'currency_rate[currency]', with: 'GBP'
    fill_in 'currency_rate[exchange_rate]', with: 1.6
    click_on 'Update'
    expect(page).to have_content('Currency Rate has been successfully updated!')
  end
end
