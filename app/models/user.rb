class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise  :ldap_authenticatable, :rememberable, authentication_keys: [:username]

  has_many :submissions

  before_save do
    Rails.logger.debug "############"
    Rails.logger.debug username
    entry = Devise::LDAP::Adapter.get_ldap_entry(username)
    Rails.logger.debug "!!!!!!!!!!!!!!!!!!!!!!!"
    self.name  = entry[:cn][0]
    self.email = username + "@rit.edu"
  end

  def admin?
    privilege_level >= 100
  end

  def mod?
    privilege_level >= 50
  end

end
