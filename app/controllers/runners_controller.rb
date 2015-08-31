class RunnersController < ApplicationController
  before_action :set_runner, only: [:show, :edit, :update, :destroy, :remember]

  # GET /runners
  # GET /runners.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: RunnerDatatable.new(view_context) }
    end
  end

  # GET /runners/1
  # GET /runners/1.json
  def show
  end

  # GET /runners/new
  def new
    @runner = Runner.new
  end

  # GET /runners/1/edit
  def edit
  end

  # POST /runners
  # POST /runners.json
  def create
    @runner = Runner.new(runner_params)

    respond_to do |format|
      if @runner.save
        format.html { redirect_to @runner, notice: 'Runner was successfully created.' }
        format.json { render :show, status: :created, location: @runner }
      else
        format.html { render :new }
        format.json { render json: @runner.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /runners/1
  # PATCH/PUT /runners/1.json
  def update
    respond_to do |format|
      if @runner.update(runner_params)
        format.html { redirect_to @runner, notice: 'Runner was successfully updated.' }
        format.json { render :show, status: :ok, location: @runner }
      else
        format.html { render :edit }
        format.json { render json: @runner.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /runners/1
  # DELETE /runners/1.json
  def destroy
    @runner.destroy
    respond_to do |format|
      format.html { redirect_to runners_url, notice: 'Runner was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def remember
    session[:runner_ids] ||= []
    session[:runner_ids] << @runner.id
    session[:runner_ids].uniq!
    render json: @runner
  end

  def show_remembered
    if cookies[:remembered_runners]
      @runners = Runner.find(JSON.parse(cookies[:remembered_runners]))
    else
      @runners = []
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_runner
      @runner = Runner.includes(runs: [:category, :run_day]).find(params[:id]).decorate
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def runner_params
      params.require(:runner).permit(:first_name, :last_name, :birth_date, :sex)
    end
end
