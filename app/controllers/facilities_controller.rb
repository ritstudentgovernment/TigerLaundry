class FacilitiesController < ApplicationController
  # Show and list all facilities
  def index
    @facilities = Facility.all
  end
  
  # Show the information for one specific facility
  def show
    @facility = Facility.find(params[:id])
  end
end
