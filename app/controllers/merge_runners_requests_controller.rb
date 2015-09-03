class MergeRunnersRequestsController < ApplicationController
  before_action :set_merge_runner_request, only: [:show, :edit, :update, :destroy]

  # GET /merge_runner_requests
  def index
    @merge_runners_requests = MergeRunnersRequest.all
  end

  # GET /merge_runner_requests/1
  def show
  end

  # GET /merge_runner_requests/new
  def new
    @merge_runners_request = MergeRunnersRequest.new
  end

  # GET /merge_runner_requests/1/edit
  def edit
  end

  # POST /merge_runner_requests
  def create
    @merge_runners_request = MergeRunnersRequest.new(merge_runner_request_params)

    if @merge_runners_request.save
      redirect_to @merge_runners_request, notice: 'Merge runner request was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /merge_runner_requests/1
  def update
    if @merge_runners_request.update(merge_runner_request_params)
      redirect_to @merge_runners_request, notice: 'Merge runner request was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /merge_runner_requests/1
  def destroy
    @merge_runners_request.destroy
    redirect_to merge_runners_requests_url, notice: 'Merge runner request was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_merge_runner_request
      @merge_runners_request = MergeRunnersRequest.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def merge_runner_request_params
      params.require(:merge_runners_request).permit(:merged_first_name, :merged_last_name, :merged_club_or_hometown, :merged_nationality, :merged_sex)
    end
end
