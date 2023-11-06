class InternshipsController < ApplicationController
  before_action :set_internship, only: %i[ show update destroy ]
  before_action :authorize_student_request, only: %i[ create ]

  # GET /internships
  def index
    @internships = Internship.all

    render json: @internships
  end

  # GET /internships/1
  def show
    render json: @internship
  end

  # POST /internships
  def create
    @internship = Internship.new(internship_params)

    @internship.user_id = @user.id

    if @internship.save
      render json: @internship, status: :created, location: @internship
    else
      render json: @internship.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /internships/1
  def update
    if @internship.update(internship_params)
      render json: @internship
    else
      render json: @internship.errors, status: :unprocessable_entity
    end
  end

  # DELETE /internships/1
  def destroy
    @internship.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_internship
      @internship = Internship.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def internship_params
      params.require(:internship).permit(:user_id, :company_name, :role_title, :stipend, :start_date, :end_date, :noc, :turned_in, :location)
    end


end
