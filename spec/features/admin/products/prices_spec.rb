require 'spec_helper'

describe "Prices" do
  stub_authorization!

  let!(:default_price_book) { Spree::PriceBook.create_default }
  let!(:explicit_price_book) { create(:price_book, priority: 5, name: 'Explicit', default: false) }
  let!(:factored_price_book) { create(:factored_price_book) }
  let!(:product) { create(:product, name: 'apache baseball cap', price: 10) }

  before(:each) do
    visit spree.admin_products_path  
    within_row(1) do 
      find('td:nth-child(3) a').click()
    end
  end

  context "#product without variants" do
    before do
      within '[data-hook=admin_product_tabs]' do
        click_link "Price Books"
      end
    end

    it "shows the price book drop-down in the correct order" do
      within(:css, '#price_book_id') do
        find('option:nth-child(1)').should have_text "Default (USD)"
        find('option:nth-child(2)').should have_text "Explicit (USD)"
        find('option:nth-child(3)').should have_text "Factored (USD)"
      end
    end

    it "has the default price book selected by default" do
      page.has_select?('price_book_id', :selected => 'Default (USD)').should == true
    end

    it "loads a new price book when one is selected from the drop-down" do
      select('Explicit (USD)', :from => 'price_book_id')
      page.has_select?('price_book_id', :selected => 'Explicit (USD)').should == true
    end

    it "shows the master variant as the only variant in the prices table" do
      page.all('table.table tbody tr').count.should == 1
      find('table.table tbody tr td:nth-child(1)').should have_text "Master"
    end

    it "navigates to the product detail page when canceling" do
      click_link "Cancel"
      current_path.should == spree.edit_admin_product_path(product)
    end

    context "#using an explicit price book" do
      before do
        explicit_price_book.prices.create(variant: product.master, amount: 888)
        select('Explicit (USD)', :from => 'price_book_id')
      end

      it "lists the prices in text fields", js: true do
        page.all('table.table tbody tr td input[type=text]').count.should == product.variants_including_master.size
      end

      it "allows the prices to be modified", js: true do
        within('table.table tbody tr td:nth-child(3)') do
          find('input').set('123')
        end
        click_button 'Update'

        price = explicit_price_book.prices.find_by_variant_id(product.master)
        price.amount.should == 123
      end
    end

    context "#using a factored price book" do
      before do
        factored_price_book.prices.create(variant: product.master, amount: 999)
        select('Factored (USD)', :from => 'price_book_id')
      end

      it "lists the prices as read-only", js: true do
        page.all('table.table tbody tr td input[type=text]').count.should == 0
        find('table.table tbody tr td:nth-child(3)').should have_text(factored_price_book.prices.find_by_variant_id(product.master).amount)
      end
    end

    context "#product with multiple variants" do
      let!(:variant) { create(:variant, product: product) }

      before do
        product.reload
        within '[data-hook=admin_product_tabs]' do
          click_link "Price Books"
        end
      end

      it "lists each variant in the prices tabale" do
        page.all('table.table tbody tr').count.should == product.variants_including_master.size
      end

      it "lists the master variant first in the prices table" do
        within('table.table tbody tr') do
          find('td:nth-child(1)').should have_text "Master"
        end
      end

      it "copies the master price to empty variant prices", js: true do
        within('table.table tbody') do
          # empty one of the non-master prices
          within('tr:nth-child(2) td:nth-child(3)') do
            find('input').set('')
          end

          # change the master price
          within('tr:nth-child(1) td:nth-child(3)') do
            fill_in "variant_#{product.master.id}_amount", with: '876'
          end
          page.execute_script "$('#variant_#{product.master.id}_amount').trigger('blur');"

          # verify our recently-emptied price now has the master price
          within('tr:nth-child(2) td:nth-child(3)') do
            sleep 3 # let the on blur take effect
            expect(find('input').value).to eql('876')
          end
        end
      end
    end
  end
end
