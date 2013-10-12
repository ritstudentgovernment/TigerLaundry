class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise  :ldap_authenticatable, authentication_keys: [:username]

  has_many :submissions

  def admin?
    privilege_level >= 100
  end

  def mod?
    privilege_level >= 50
  end

end
