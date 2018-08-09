class Distributor < ActiveRecord::Base
  extend GridTable

  attr_accessor :skip_password_required

  has_many :orders, as: :orderer, dependent: :destroy

  has_secure_password

  validates :company_name, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true
  validates :address1, presence: true
  validates :city, presence: true
  validates :country, presence: true
  validates :state, presence: true
  validates :zip, presence: true
  validates :price, presence: true
  validates :tax_info, presence: true
  
  validates :email, presence: true,
                    uniqueness: true,
                    format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, on: :create }

  validates :password, presence: true, confirmation: true, length: { minimum: 6 }, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

  grid_table_control :company_name
  grid_table_control :city
  grid_table_control :state
  grid_table_control :price
  grid_table_control :created_at

  before_validation(on: :create) do
    if self.password.blank?
      self.password = "hairillusion"
      self.price = 5995
      self.password_confirmation = self.password
    end
  end
  
  def name
    return "#{first_name} #{last_name}"
  end

  private
  def password_required?
    self.require_password_reset && !skip_password_required
  end
end
