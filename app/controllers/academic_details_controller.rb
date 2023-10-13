class AcademicDetailsController < ApplicationController
  before_action :set_academic_detail, only: %i[ show update destroy ]

  # GET /academic_details
  def index
    @academic_details = AcademicDetail.all

    render json: @academic_details
  end

  # GET /academic_details/1
  def show
    render json: @academic_detail
  end

  # POST /academic_details
  def create
    @academic_detail = AcademicDetail.new(academic_detail_params)

    if @academic_detail.save
      render json: @academic_detail, status: :created, location: @academic_detail
    else
      render json: @academic_detail.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /academic_details/1
  def update
    if @academic_detail.update(academic_detail_params)
      render json: @academic_detail
    else
      render json: @academic_detail.errors, status: :unprocessable_entity
    end
  end

  # DELETE /academic_details/1
  def destroy
    @academic_detail.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_academic_detail
      @academic_detail = AcademicDetail.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def academic_detail_params
      params.require(:academic_detail).permit!
    end
end
