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
    ret = :open
    if is_full? n
      ret = :full
    elsif is_almost_full? n
      ret = :almost_full
    end
    return ret
  end
  
  # does this indicate washers / driers are full?
  def is_full?(n)
    n >= 95
  end
  
  # does this indicate washers / driers are almost full?
  def is_almost_full?(n)
    75 <= n and n < 95
  end

end
