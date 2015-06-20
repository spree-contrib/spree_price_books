class Spree::PriceBook < ActiveRecord::Base

  acts_as_nested_set order_column: :priority

  belongs_to :role, class_name: 'Spree::Role'

  has_many :prices
  has_many :products, -> { uniq }, through: :variants
  has_many :store_price_books
  has_many :stores, through: :store_price_books
  has_many :variants, through: :prices

  validate :validate_currency_rate
  validate :validate_single_default

  validates :active_to, timeliness: { after: :active_from, allow_blank: true }
  validates :currency, presence: true
  validates :price_adjustment_factor,
    presence: { if: Proc.new { |record| record.factored? } }

  after_create :update_prices_with_adjustment_factor
  after_update :update_prices_with_adjustment_factor, if: :price_adjustment_factor_changed?

  scope :active, -> {
    where(%Q(#{table_name}."default" = ? OR (#{table_name}.active_from <= ? AND (#{table_name}.active_to IS NULL OR #{table_name}.active_to >= ?))),
      true, Time.zone.now, Time.zone.now)
  }
  scope :by_currency, -> (currency_iso) { where(currency: currency_iso).prioritized }
  scope :by_role, -> (role_ids) { where(role_id: role_ids) }
  scope :by_store, -> (store_id) { joins(:store_price_books).where(spree_store_price_books: { store_id: store_id }) }
  scope :discount, -> { where(discount: true) }
  scope :explicit, -> { where(parent_id: nil, price_adjustment_factor: nil) }
  scope :list, -> { where(discount: false) }
  scope :prioritized, -> { order("#{table_name}.priority DESC") }

  ## Class Methods

  def self.create_default
    create(currency: Spree::Config[:currency], default: true, name: 'Default')
  end

  def self.default
    if default = where(default: true).first
      default
    else
      create_default
    end
  end

  def self.showable_attribute_names
    [
      "id", "name", "currency", "priority", "default",
      "price_adjustment_factor", "parent", "created_at", "updated_at",
      "active_from", "active_to", "discount"
    ]
  end

  ## Instance Methods

  def active?
    # TODO I'm using .to_i in here because I stumbled on a strange bug:
    # [1] surfdome(#<Spree::PriceBook>) »  active_to
    # => Wed, 19 Feb 2014 16:29:04 UTC +00:00
    # [2] surfdome(#<Spree::PriceBook>) »  Time.zone.now
    # => Wed, 19 Feb 2014 16:29:04 UTC +00:00
    # [3] surfdome(#<Spree::PriceBook>) »  active_to >= Time.zone.now
    # => false
    # [5] surfdome(#<Spree::PriceBook>) »  active_to.to_s(:number)
    # => "20140219162904"
    # [6] surfdome(#<Spree::PriceBook>) »  Time.zone.now.to_s(:number)
    # => "20140219162904"
    # [1] surfdome(#<Spree::PriceBook>) »  active_to.to_i
    # => 1392827718
    # [2] surfdome(#<Spree::PriceBook>) »  Time.zone.now.to_i
    # => 1392827718
    # [3] surfdome(#<Spree::PriceBook>) »  active_to.to_i >= Time.zone.now.to_i
    # => true
    default? or (active_from.present? and active_from <= Time.zone.now and (active_to.blank? or active_to.to_i >= Time.zone.now.to_i))
  end

  def add_product(product)
    variants = product.variants_including_master
    variants.each { |variant|
      self.add_variant(variant) }
  end

  def add_product_by_id(product_id)
    product = Spree::Product.find(product_id)
    add_product(product) if product.present?
  end

  def add_variant(variant)
    price = self.prices.where(variant_id: variant.id).first
    if price.blank?
      self.prices << Spree::Price.create(
        variant_id: variant.id,
        amount: variant.price,
        currency: self.currency
      )
    end
  end

  def destroy
    if default?
      raise RuntimeError, 'You cannot destroy the default price book.'
    else
      super
    end
  end

  def discount_price_book?
    discount?
  end

  def explicit?
    parent_id.blank?
  end

  def factored?
    parent_id.present?
  end

  def list_price_book?
    !discount?
  end

  def showable_attributes
    self.class.showable_attribute_names.each_with_object({}) do |name, hash|
      hash[name] = self.attributes[name]
    end
  end

  def update_prices_with_adjustment_factor
    return if default? or explicit?

    parent.prices.find_each do |parent_price|
      if price = prices.find_by_variant_id(parent_price.variant_id)
        price.update_attribute :amount, parent_price.amount * price_adjustment_factor
      else
        prices.create amount: (parent_price.amount * price_adjustment_factor), currency: currency, variant_id: parent_price.variant_id
      end
    end
  end

  private

  # When the adjustment factor is blank for a child price book of a foreign currency set the factor to the available exchange rate.
  def validate_currency_rate
    if parent.present? && parent.currency != currency && price_adjustment_factor.blank?
      self.price_adjustment_factor = Spree::CurrencyRate.find_by(base_currency: parent.currency, currency: currency).try(:exchange_rate)
    end
  end

  def validate_single_default
    return unless default?

    matches = Spree::PriceBook.where(default: true)

    if persisted?
      matches = matches.where('id != ?', id)
    end

    if matches.exists?
      errors.add(:default, 'cannot have multiple default price books.')
    end
  end

end
