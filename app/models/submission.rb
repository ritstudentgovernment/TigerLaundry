class Submission < ActiveRecord::Base
  belongs_to :facility
  belongs_to :user
end
