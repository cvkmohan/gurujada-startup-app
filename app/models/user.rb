class User
  include Mongoid::Document
  rolify
  include Mongoid::Timestamps
  include User::AuthDefinitions


  has_many :identities


  field :email, type: String
  field :image, type: String
  field :first_name, type: String
  field :last_name, type: String

  
  validates_presence_of :email, :first_name, :last_name

  def full_name
    "#{first_name} #{last_name}"
  end

end
