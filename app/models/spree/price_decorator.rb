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
  scope :prioritized, -> { includes(:price_book).order('spree_price_books.priority DESC, spree_prices.amount ASC') }

  #### Hack to allow negative priced product
  # overriding greater than zero price validation from core in Spree::Price model
  # removes line from model in core:  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  amount_numericality_validator = _validators[:amount].find { |v| v.is_a?(ActiveModel::Validations::NumericalityValidator)}
  _validators[:amount].reject! {|val| val == amount_numericality_validator }
  _validate_callbacks.instance_variable_get(:@chain).reject! do |callback|
    callback.filter == amount_numericality_validator
  end
  # replace with new numericality validator
  validates :amount, numericality: true, allow_nil: true


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
