class SubmissionsController < ApplicationController
  # Prompt for information to make a new submission
  #   params should have a :facility_id key
  def new
    @facility = Facility.find(params[:facility_id])
  end

  # Make the new submission
  def create
    @facility = Facility.find(params[:facility_id])
    @submission = Submission.new(
          washers:     params[:submission][:washers],
          driers:      params[:submission][:driers],
          facility_id: params[:facility_id]
        )
    @submission.save

    redirect_to facility_url(@facility)
  end
end
