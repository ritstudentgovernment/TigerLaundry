class FacilitiesController < ApplicationController
  before_action :set_facility, only: [:show, :edit, :update, :destroy]

  # GET /facilities
  # GET /facilities.json
  def index
    authorize! :read, Facility
    @facilities = Facility.all
  end

  # GET /facilities/1
  # GET /facilities/1.json
  def show
    authorize! :read, @facility
  end

  # GET /facilities/new
  def new
    authorize! :create, Facility
    @facility = Facility.new
  end

  # GET /facilities/1/edit
  def edit
    authorize! :update, @facility
  end

  # POST /facilities
  # POST /facilities.json
  def create
    authorize! :create, Facility
    @facility = Facility.new(facility_params)
    # make sure a facility has at least 1 submission

    respond_to do |format|
      if @facility.save
        format.html { redirect_to @facility,
                                  notice: 'Facility was successfully created.' }
        format.json { render action: 'show',
                             status: :created, location: @facility }
      else
        format.html { render action: 'new' }
        format.json { render json: @facility.errors,
                                   status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /facilities/1
  # PATCH/PUT /facilities/1.json
  def update
    authorize! :update, @facility
    respond_to do |format|
      if @facility.update(facility_params)
        format.html { redirect_to @facility, notice: 'Facility was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @facility.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /facilities/1
  # DELETE /facilities/1.json
  def destroy
    authorize! :destroy, @facility
    @facility.destroy
    respond_to do |format|
      format.html { redirect_to facilities_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_facility
      @facility = Facility.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def facility_params
      params.require(:facility).permit(:washers, :driers, :name)
    end
end
