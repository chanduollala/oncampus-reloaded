class OffcampusSelectionsController < ApplicationController
  before_action :set_offcampus_selection, only: %i[ show update destroy ]

  # GET /offcampus_selections
  def index
    @offcampus_selections = OffcampusSelection.all

    render json: @offcampus_selections
  end

  # GET /offcampus_selections/1
  def show
    render json: @offcampus_selection
  end

  # POST /offcampus_selections
  def create
    @offcampus_selection = OffcampusSelection.new(offcampus_selection_params)

    if @offcampus_selection.save
      render json: @offcampus_selection, status: :created, location: @offcampus_selection
    else
      render json: @offcampus_selection.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /offcampus_selections/1
  def update
    if @offcampus_selection.update(offcampus_selection_params)
      render json: @offcampus_selection
    else
      render json: @offcampus_selection.errors, status: :unprocessable_entity
    end
  end

  # DELETE /offcampus_selections/1
  def destroy
    @offcampus_selection.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_offcampus_selection
      @offcampus_selection = OffcampusSelection.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def offcampus_selection_params
      params.require(:offcampus_selection).permit(:user_id, :ctc, :company_name, :job_type, :location, :role)
    end
end
