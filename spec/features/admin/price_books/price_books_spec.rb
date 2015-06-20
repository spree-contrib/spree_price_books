require 'spec_helper'

describe "PriceBooks Feature", js: true do
  stub_authorization!

  before do
    Spree::PriceBook.default
    visit spree.admin_path
    click_link "Products"
    click_link "Price Books"
  end

  context "can create a" do

    it "factored PriceBook" do
      click_link "New Price Book"

      fill_in 'price_book_name', with: 'TEST'
      select 'GEL', from: 'price_book_currency'
      fill_in 'price_book_priority', with: '12'
      fill_in 'price_book_price_adjustment_factor', with: '34'
      fill_in 'price_book_active_from', with: (Time.now - 1.day).strftime('%Y/%m/%d')
      fill_in 'price_book_active_to', with: (Time.now + 1.year).strftime('%Y/%m/%d')
      select 'Default', from: 'price_book_parent_id'

      click_button 'Create'

      expect(page).to have_content "has been successfully created"
    end

    it "discount PriceBook" do
      click_link "New Price Book"

      fill_in 'price_book_name', with: 'Discount'
      select 'GEL', from: 'price_book_currency'
      fill_in 'price_book_priority', with: '12'
      fill_in 'price_book_active_from', with: (Time.now - 1.day).strftime('%Y/%m/%d')
      fill_in 'price_book_active_to', with: (Time.now + 1.year).strftime('%Y/%m/%d')
      select '', from: 'price_book_parent_id'
      check 'price_book_discount'

      click_button 'Create'

      expect(page).to have_content "has been successfully created"
    end

    it "explicit PriceBook" do
      click_link "New Price Book"

      fill_in 'price_book_name', with: 'TEST'
      select 'GEL', from: 'price_book_currency'
      fill_in 'price_book_priority', with: '12'
      fill_in 'price_book_active_from', with: (Time.now - 1.day).strftime('%Y/%m/%d')
      fill_in 'price_book_active_to', with: (Time.now + 1.year).strftime('%Y/%m/%d')
      select '', from: 'price_book_parent_id'

      click_button 'Create'

      expect(page).to have_content "has been successfully created"
    end
  end

  it "hides factored fields when PB is explicit" do
    click_link "New Price Book"

    select 'Default', from: 'price_book_parent_id'
    expect(find(:css, "#price_book_price_adjustment_factor_field")).to be_visible

    select '', from: 'price_book_parent_id'
    expect(find(:css, "#price_book_price_adjustment_factor_field", visible: false)).to_not be_visible
  end

end
