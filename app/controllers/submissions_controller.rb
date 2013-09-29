class SubmissionsController < ApplicationController
  before_action :set_facility
  before_action :set_submission, only: [:show, :edit, :update, :destroy]

  # GET facilities/1/submissions
  # GET facilities/1/submissions.json
  def index
    @submissions = Facility.find(params[:facility_id]).submissions
  end

  # GET /facilities/1/submissions/1
  # GET /facilities/1/submissions/1.json
  def show
  end

  # GET /facilities/1/submissions/new
  def new
    @submission = Submission.new
  end

  # GET /facilities/1/submissions/1/edit
  def edit
  end

  # POST /facilities/1/submissions
  # POST /facilities/1/submissions.json
  def create
    @submission = Submission.new(submission_params)

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
    @submission.destroy
    respond_to do |format|
      format.html { redirect_to facility_submissions_url(@facility) }
      format.json { head :no_content }
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
