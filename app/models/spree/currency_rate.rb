class Spree::CurrencyRate < Spree::Base

  validates :base_currency, presence: true
  validates :currency, presence: true, uniqueness: { scope: :base_currency }
  validates :exchange_rate, presence: true
  validate :validate_single_default

  ## Class Methods

  def self.create_default
    create(base_currency: Spree::Config[:currency], currency: Spree::Config[:currency], default: true)
  end

  def self.default
    if default = where(default: true).first
      default
    else
      create_default
    end
  end

  ## Instance Methods


  private

  # TODO this could be a concern shared by price book (maybe store too)
  def validate_single_default
    return unless default?

    matches = self.class.where(default: true)

    if persisted?
      matches = matches.where('id != ?', id)
    end

    if matches.exists?
      errors.add(:default, 'cannot have multiple defaults.')
    end
  end

end
