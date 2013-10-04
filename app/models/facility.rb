class Facility < ActiveRecord::Base
  has_many :submissions

  # returns the most recent submission
  def last_submission
    submissions.last
  end

  # Get the status of the washers
  # returns either :full, :almost_full, or :open
  def washers_status
    get_status last_submission.washers
  end

  # Get the status of the driers
  # returns either :full, :almost_full, or :open
  def driers_status
    get_status last_submission.driers
  end

  # Gets the most severe status of washers and driers
  # from least to greatest in order of severity: :open, :almost_full, :full
  def status
    w_s = washers_status
    d_s = driers_status
    
    if w_s == :full or d_s == :full
      return :full
    elsif w_s == :almost_full or d_s == :almost_full
      return :almost_full
    end
    return :open
  end


  private
  
  # get the status of the given number
  # returns either :full, :almost_full, or :open
  def get_status(n)
    if n >= 95
      return :full
    elsif n >= 75
      return :almost_full
    else
      return :open
    end
  end
  
end
