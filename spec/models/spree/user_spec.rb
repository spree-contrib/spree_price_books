require 'spec_helper'

describe Spree.user_class do

  it '#price_book_role_ids' do
    record = create(:user)
    expect(record.price_book_role_ids).to match_array([nil])
    record = create(:admin_user)
    expect(record.price_book_role_ids).to match_array([nil, Spree::Role.find_by_name('admin').id])
  end

end
