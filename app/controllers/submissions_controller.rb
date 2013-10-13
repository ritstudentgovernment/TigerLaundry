class SubmissionsController < ApplicationController
  before_action :set_facility
  before_action :set_submission, only: [:show, :edit, :update, :destroy]

  # GET facilities/1/submissions
  # GET facilities/1/submissions.json
  def index
    authorize! :read, Submission
    @submissions = Facility.find(params[:facility_id]).submissions
  end

  # GET /facilities/1/submissions/1
  # GET /facilities/1/submissions/1.json
  def show
    authorize! :read, @submission
  end

  # GET /facilities/1/submissions/new
  def new
    authorize! :create, Submission
    @submission = Submission.new
  end

  # GET /facilities/1/submissions/1/edit
  def edit
    authorize! :update, @submission
  end

  # POST /facilities/1/submissions
  # POST /facilities/1/submissions.json
  def create
    @submission = Submission.new(submission_params)
    if user_signed_in?
      @submission.user = current_user
    end
    authorize! :create, @submission

    respond_to do |format|
      if @submission.save
        format.html { redirect_to facility_submission_path(@facility, @submission), notice: 'Submission was successfully created.' }
        format.json { render action: 'show', status: :created, location: @submission }
      else
        format.html { render action: 'new' }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /facilities/1/submissions/1
  # PATCH/PUT /facilities/1/submissions/1.json
  def update
    authorize! :update, @submission
    respond_to do |format|
      if @submission.update(submission_params)
        format.html { redirect_to facility_submission_path(@facility, @submission), notice: 'Submission was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /facilities/1/submissions/1
  # DELETE /facilities/1/submissions/1.json
  def destroy
    authorize! :destroy, @submission
    @submission.destroy
    respond_to do |format|
      format.html { redirect_to facility_submissions_url(@facility) }
      format.json { head :no_content }
    end
  end

  # GET /facilities/1/submissions/limited.json
  # Params expected:
  #   hours: integer - default 24, how many hours of submissions to get
  def limited
    authorize! :read, Submission
    hours = params[:hours].to_i
    if not hours
      hours = 12
    end
    hours = hours.hours.ago
    @submissions = Submission.where("facility_id = ? AND created_at > ?",
                                    params[:facility_id], hours)
    ## REMOVE STUFF BELOW ME
    @submissions = []
    rolling_washers = rand(50)+25
    rolling_driers  = 50
    (1..6).each do |n|
      rolling_washers = [10, rolling_washers + rand(30)-15].max
      rolling_driers  = [10, rolling_driers + rand(30)-15].max
      @submissions << Submission.new(created_at: n.hours.ago,
                                     washers: rolling_washers,
                                     driers: rolling_driers,
                                     facility_id: params[:facility_id])
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_facility
      @facility   = Facility.find(params[:facility_id])
    end
    def set_submission
      @submission = Submission.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def submission_params
      params.require(:submission).permit(:washers, :driers, :facility_id)
    end
end
