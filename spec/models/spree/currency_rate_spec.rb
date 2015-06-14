require 'spec_helper'

describe Spree::CurrencyRate do

  xit '#validate_single_default' do
    default = create(:default_currency_rate)
    second_default = build :default_currency_rate
    expect(second_default.valid?).to eql(false)
    expect(second_default.errors[:default]).to include 'cannot have multiple defaults.'
    second_default.default = false
    expect(second_default.valid?).to eql(true)
  end

end
