class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :omniauthable, :omniauth_providers => [:google_oauth2]
  devise :trackable, :rememberable, :omniauthable

  has_many :submissions

  def self.find_for_google_oauth2(access_token)
    data = access_token.info
    user = User.find_by_email(data[:email])
    unless user
      user = User.create(name: data['name'],
                         email: data['email'],
                        )
    end
    user
  end

  def admin?
    privilege_level >= 100
  end

  def mod?
    privilege_level >= 50
  end

end
