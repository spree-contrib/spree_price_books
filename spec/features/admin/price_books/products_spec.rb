require 'spec_helper'

describe "Price Books - " do
  stub_authorization!

  before(:each) do
    Spree::PriceBook.default
    visit spree.admin_path
    click_link "Products"
    click_link "Price Books"    
  end

  context "Default PriceBook has products" do
    before(:each) do
      product = create(:product)
      Spree::PriceBook.default.add_product(product)
      click_link "Price Books"
    end

    it "cannot remove products from the Default PriceBook" do
      click_link "Default"
      expect(page).to_not have_content "Remove product"
    end
  end

  context "a custom PriceBook has products" do
    let!(:price_book) { create :explicit_price_book }

    before(:each) do
      product = create :product
      price_book.add_product(product)
      click_link "Price Books"
      click_link "Explicit"
      create :product
    end

    it "can add products to a PriceBook" do
      click_link "Add Products"
      page.find("input[type='checkbox']").set true
      click_button "Update"

      expect(page.all('#listing_products tr').count).to eq 3
    end

    it "can remove products from a PriceBook" do
      click_link "Remove product"
      expect(page).to have_content "No Products found"
    end

    it "can edit the price for a product in a PriceBook" do
      click_link "Edit price"
      page.find("input[id^='variant_'][id$='_amount']").set(12.34)
      click_button 'Update'
      visit spree.admin_price_book_path(price_book)
      expect(page).to have_content "12.34"
    end
  end

end
