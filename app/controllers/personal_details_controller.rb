class PersonalDetailsController < ApplicationController
  before_action :set_personal_detail, only: %i[ show update destroy ]

  # GET /personal_details
  def index
    @personal_details = PersonalDetail.all

    render json: @personal_details
  end

  # GET /personal_details/1
  def show
    render json: @personal_detail
  end

  # POST /personal_details
  def create
    @personal_detail = PersonalDetail.new(personal_detail_params)

    if @personal_detail.save
      render json: @personal_detail, status: :created, location: @personal_detail
    else
      render json: @personal_detail.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /personal_details/1
  def update
    if @personal_detail.update(personal_detail_params)
      render json: @personal_detail
    else
      render json: @personal_detail.errors, status: :unprocessable_entity
    end
  end

  # DELETE /personal_details/1
  def destroy
    @personal_detail.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_personal_detail
      @personal_detail = PersonalDetail.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def personal_detail_params
      params.require(:personal_detail).permit(:photo, :gender, :dob, :mother_name, :father_name, :nationality, :passport, :PAN, :user_id)
    end
end
