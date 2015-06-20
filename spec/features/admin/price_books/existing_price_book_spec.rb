require 'spec_helper'

describe "Price Books - Existing" do
  stub_authorization!

  before(:each) do
    Spree::PriceBook.default
    create :price_book
    visit spree.admin_path
    click_link "Products"
    click_link "Price Books" 
  end

  it "can read a PriceBook" do
    click_link "Default"

    expect(page).to have_content %q(Price Book "Default")
  end

  it "can update a PriceBook" do
    find('#spree_price_book_1 td.actions a').click

    fill_in 'price_book_name', with: 'TEST'
    select 'GEL', from: 'price_book_currency'

    click_button 'Update'

    expect(page).to have_content "has been successfully updated"
    expect(page).to have_content "TEST"
    expect(page).to have_content "GEL"
  end

  it "can remove a PriceBook", js: true do
    click_icon :delete
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax

    expect(page).to have_content "has been successfully removed"
  end

  context "Default PriceBook has products" do
    before(:each) do
      product = create(:product)
      Spree::PriceBook.default.add_product(product)
    end

    it "cannot remove products from the Default PriceBook" do
      click_link "Default"
      expect(page).to_not have_content "Remove product"
    end
  end

end
