require 'spec_helper'

describe Spree::PriceBook do

  describe 'Scopes' do

    it '.active' do
      Timecop.freeze do
        default = create(:default_price_book)
        pb1 = create(:price_book) # active_from and to are nil
        pb2 = create(:price_book, active_from: 1.second.ago)
        pb3 = create(:price_book, active_from: Time.zone.now)
        pb4 = create(:price_book, active_from: 1.second.from_now)
        pb5 = create(:price_book, active_from: 1.day.ago, active_to: 1.second.ago)
        pb6 = create(:price_book, active_from: 1.day.ago, active_to: Time.zone.now)
        pb7 = create(:price_book, active_from: 1.day.ago, active_to: 1.second.from_now)

        expect(subject.class.active.to_a).to match_array([default, pb2, pb3, pb6, pb7])
      end
    end

    it '.by_currency' do
      usd_book = create(:price_book, currency: 'USD')
      gbp_book = create(:price_book, currency: 'GBP')
      expect(subject.class.by_currency('GBP').to_a).to eql([gbp_book])
    end

    context '.by_role' do
      let!(:admin) { create(:role, name: 'admin') }
      let!(:customer) { create(:role, name: 'customer') }
      let!(:employee) { create(:role, name: 'employee') }
      let!(:pb1) { create(:price_book, role: admin) }
      let!(:pb2) { create(:price_book) }
      let!(:pb3) { create(:price_book, role: customer) }
      let!(:pb4) { create(:price_book) }
      let!(:pb5) { create(:price_book, role: employee) }

      it 'should return books for NULL id' do
        expect(subject.class.by_role(nil).to_a).to match_array([pb2, pb4])
      end

      it 'should return books for single id' do
        expect(subject.class.by_role(customer.id).to_a).to match_array([pb3])
      end

      it 'should return books for array of ids' do
        expect(subject.class.by_role([admin.id, employee.id]).to_a).to match_array([pb1, pb5])
        expect(subject.class.by_role([nil, employee.id]).to_a).to match_array([pb2, pb4, pb5])
      end
    end

    it '.by_store' do
      store_1 = create(:store)
      store_2 = create(:store)
      default = Spree::PriceBook.default
      book_1 = create(:store_price_book, stores: [store_1])
      book_2 = create(:store_price_book, stores: [store_2])
      book_3 = create(:store_price_book, stores: [store_1, store_2])

      expect(subject.class.by_store(store_1.id).to_a).to match_array([book_3, book_1])
      expect(subject.class.by_store(store_2.id).to_a).to match_array([book_3, book_2])
    end

    it '.discount' do
      pb1 = create :price_book
      pb2 = create :price_book, discount: true
      pb3 = create :price_book

      expect(subject.class.discount.to_a).to eql([pb2])
    end

    it '.list' do
      pb1 = create :price_book
      pb2 = create :price_book, discount: true
      pb3 = create :price_book

      expect(subject.class.list.to_a).to match_array([pb1, pb3])
    end

  end

  it '#active?' do
    Timecop.freeze(Time.zone.now) do
      default = create(:default_price_book)
      pb1 = create(:price_book) # active_from and to are nil
      pb2 = create(:price_book, active_from: 1.second.ago)
      pb3 = create(:price_book, active_from: Time.zone.now)
      pb4 = create(:price_book, active_from: 1.second.from_now)
      pb5 = create(:price_book, active_from: 1.day.ago, active_to: 1.second.ago)
      pb6 = create(:price_book, active_from: 1.day.ago, active_to: Time.zone.now)
      pb7 = create(:price_book, active_from: 1.day.ago, active_to: 1.second.from_now)

      expect(default.active?).to be true
      expect(pb1.active?).to be false
      expect(pb2.active?).to be true
      expect(pb3.active?).to be true
      expect(pb4.active?).to be false
      expect(pb5.active?).to be false
      expect(pb6.active?).to be true
      expect(pb7.active?).to be true
    end
  end

  it '#destroy' do
    expect { Spree::PriceBook.default.destroy }.to raise_error(RuntimeError)
  end

  it '#discount_price_book?' do
    book = build :price_book, discount: true
    expect(book.discount_price_book?).to be true
    book.discount = false
    expect(book.discount_price_book?).to be false
  end

  it '#explicit?' do
    record = build :price_book, parent_id: nil
    expect(record.explicit?).to be true
    record.parent_id = 1
    expect(record.explicit?).not_to be true
  end

  it '#factored?' do
    record = build :price_book, parent_id: nil
    expect(record.factored?).not_to be true
    record.parent_id = 1
    expect(record.factored?).to be true
  end

  it '#list_price_book?' do
    book = build :price_book, discount: true
    expect(book.list_price_book?).to be false
    book.discount = false
    expect(book.list_price_book?).to be true
  end

  describe '#update_prices_with_adjustment_factor' do

    # TODO there is a recursion bug with master_variant factory that causes a product to be created with 2 master variants.
    #      so just creating product and grabbing master variant until fixed.
    let(:variant) { create(:product, price: 10).master }
    let(:variant_two) { create(:product, price: 10).master }
    let(:parent_book) { Spree::PriceBook.default }

    before do
      variant
      variant_two
    end

    it 'does not update prices if parent_id is null' do
      book  = create(:price_book)
      price = variant.prices.create amount: 10, price_book: book
      book.update_prices_with_adjustment_factor

      expect(book).not_to receive(:parent)
      expect(price.reload.amount.to_f).to eql(10.0)
    end

    it 'updates prices if parent is present' do
      book  = create(:price_book, parent: parent_book, price_adjustment_factor: 1.1)
      price = variant.prices.find_by_price_book_id(book.id)
      expect(price.amount.to_f).to eql(11.0)

      # change amount so its not the no longer correct
      price.update_attribute :amount, 10
      # run update
      book.update_prices_with_adjustment_factor

      expect(price.reload.amount.to_f).to eql(11.0)
    end

    it 'duplicates all prices from parent and factors them if they dont exist' do
      book  = build(:price_book, parent: parent_book, price_adjustment_factor: 1.1)
      expect(book.prices.empty?).to be true
      book.save
      book.reload
      expect(book.prices.size).to eql(2)
      book.prices.each do |price|
        expect(price.amount.to_f).to eql(11.0)
      end
    end

    it 'is called when price adjustment factor changes' do
      book  = create(:price_book, parent: parent_book, price_adjustment_factor: 1.1)
      expect(book).to receive(:update_prices_with_adjustment_factor)
      book.update_attribute :price_adjustment_factor, 1.2
    end

  end

  it '#validate_currency_rate' do
    default_book = create(:default_price_book)
    create(:currency_rate, base_currency: default_book.currency, currency: 'CAD', exchange_rate: 2)
    new_book = build :price_book, currency: 'CAD', parent: default_book, price_adjustment_factor: nil

    expect(new_book.valid?).to be true
    expect(new_book.price_adjustment_factor).to eql(2.0)
  end

  it '#validate_single_default' do
    # Create default
    default_book = create(:default_price_book)
    # Second book should not be valid because it shares currency and store id
    second_default_book = build :default_price_book
    expect(second_default_book.valid?).to eql(false)
    expect(second_default_book.errors[:default]).to include 'cannot have multiple default price books.'
    # Changing default to false is valid
    second_default_book.default = false
    expect(second_default_book.valid?).to eql(true)
  end

end
