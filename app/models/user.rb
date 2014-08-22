class User < ActiveRecord::Base

  # Roles
  UserRole = :user
  OrgAdminRole = :organisation_admin
  DefaultRole = UserRole
  
  # Enumerated roles
  enum role: [UserRole, OrgAdminRole]

  devise :registerable, :database_authenticatable, :rememberable, :lockable, :trackable, :timeoutable, :validatable, :recoverable

  # Callbacks
  after_initialize :set_default_role, :if => :new_record?
  
  # Relationships
  has_many :organisation_memberships, dependent: :destroy
  has_many :organisations, through: :organisation_memberships

private

  def set_default_role
    self.role ||= DefaultRole
  end

end
