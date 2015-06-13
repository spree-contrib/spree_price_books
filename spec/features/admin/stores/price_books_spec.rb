require 'spec_helper'

describe "Store Management - Price Books", js: true do

  stub_authorization!

  let!(:store_1) { create(:store) }
  let!(:store_2) { create(:store) }

  context 'when unassigned to store' do

    before do
      @pb1 = Spree::PriceBook.default
      @pb2 = create(:price_book, name: 'Second Created')
      @pb3 = create(:price_book, name: 'Third Created')
      visit spree.admin_path
      click_link "Configurations"
      click_link 'Stores & Domains'
    end

    it 'can be assigned' do
      expect(store_2.price_books.to_a).to eql([])
      within_row(2) do
        click_icon :edit
      end
      check "store_price_book_ids_#{@pb1.id}"
      check "store_price_book_ids_#{@pb2.id}"
      click_button 'Update'
      expect(page).to have_content('successfully updated')
      expect(store_2.reload.price_books.to_a).to match_array([@pb1, @pb2])
    end
  end

  context 'when assigned to store' do

    before do
      @pb1 = Spree::PriceBook.default
      @pb2 = create(:price_book, name: 'Second Created')
      @pb3 = create(:price_book, name: 'Third Created')
      visit spree.admin_path
      click_link "Configurations"
      click_link 'Stores & Domains'
      store_2.price_books = [@pb1, @pb2]
    end

    it 'can be prioritized' do
      expect(store_2.price_books.to_a).to match_array([@pb1, @pb2])
      within_row(2) do
        click_icon :edit
      end
      first = find("#store_price_book_id_#{@pb1.id}")
      second = find("#store_price_book_id_#{@pb2.id}")
      second.drag_to(first)
      sleep 3
      click_button 'Update'
      expect(page).to have_content('successfully updated')
      # This MUST be an eql check not a match array.  The order matters when your testing prioritizing the order.
      expect(store_2.reload.price_books.to_a).to eql([@pb1, @pb2])
    end
  end

end
