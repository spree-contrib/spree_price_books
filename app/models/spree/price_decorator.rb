Spree::Price.class_eval do

  belongs_to :price_book

  has_many :store_price_books, through: :price_book

  validate :ensure_proper_currency
  validates :price_book_id, presence: true

  before_validation :ensure_price_book

  after_create :populate_children
  after_update :update_children

  delegate :product, to: :variant

  scope :by_currency, -> (currency_iso) { where(currency: currency_iso) }
  scope :by_role, -> (role_ids) { prioritized.where(spree_price_books: { role_id: role_ids }) }
  scope :by_store, -> (store_id) { joins(:store_price_books).where(spree_store_price_books: { store_id: store_id }) }
  scope :list, -> { prioritized.where(spree_price_books: { discount: false }) }
  scope :prioritized, -> { includes(:price_book).order("#{Spree::PriceBook.table_name}.priority DESC, #{table_name}.amount ASC") }

  ##### NOTE: This tax fun of adjusting prices by tax zone is Surfdome specific and is in here to be available in the elasticsearch extension...
  # Accepts an optional tax_zone parameter (defaults to default tax_zone) and then applies the tax_rate to the domestic net_price if inclusive.
  def gross_price(tax_zone = Spree::Zone.default_tax)
    # Unless we are recalculating gross price based upon domestic net price we just want to return the amount.
    return amount unless tax_zone.try(:recalculate_gross_price_from_domestic_net?)
    # Applies tax_zone's applicable rates to the Domestic (Default Tax Zone) net price.
    net_price * (1 + tax_zone.tax_rates.where(tax_category_id: product.tax_category_id).map(&:amount).sum)
  end

  # Returns the amount adjusted by the tax rate (if inclusive) for the default tax zone (domestic net price).
  def net_price
    # If tax_zone is somewhere tax is included all rates should be included.
    if Spree::Zone.default_tax && Spree::Zone.default_tax.tax_rates.where(tax_category_id: product.tax_category_id).detect { |r| r.included_in_price }
      amount / (1 + Spree::Zone.default_tax.tax_rates.where(tax_category_id: product.tax_category_id).map(&:amount).sum)
    else
      amount
    end
  end

  # TODO make sure that when line item is created it is taking the proper tax zone into account when calculating the gross_price here.
  def price(tax_zone = Spree::Zone.default_tax)
    gross_price(tax_zone)
  end
  ##### End surfdome specific methods

  private

  def ensure_price_book
    self.price_book ||= Spree::PriceBook.default
  end

  def ensure_proper_currency
    unless currency == price_book.currency
      errors.add(:currency, :match_price_book)
    end
  end

  def populate_children
    price_book.children.each do |book|
      if price = book.prices.find_by_variant_id(self.variant_id)
        price.update_attribute :amount, self.amount * book.price_adjustment_factor
      else
        book.prices.create amount: (self.amount * book.price_adjustment_factor), currency: book.currency, variant_id: self.variant_id
      end
    end
  end

  def update_children
    price_book.children.each do |book|
      if price = book.prices.find_by_variant_id(self.variant_id)
        price.update_attribute :amount, self.amount * book.price_adjustment_factor
      end
    end
  end

end
