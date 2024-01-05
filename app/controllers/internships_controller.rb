class InternshipsController < ApplicationController
  before_action :set_internship, only: %i[ show update destroy ]
  before_action :authorize_student_request, only: %i[ create index ]

  # GET /internships
  def index
    @internships = Internship.where(user_id: @user.id)

    render json: @internships
  end

  # GET /internships/1
  def show
    render json: @internship, include: [:internship_documents]
  end

  # POST /internships
  def create
    @internship = Internship.new(internship_params)

    @internship.user_id = @user.id

    if @internship.save
      render json: @internship, status: :created
    else
      render json: @internship.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /internships/1
  def update
    internship_params[:noc]=false
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


  def unverified_count
    render json: Internship.where(noc:false).count, status: :ok
  end


  def pending_submissions
    render json: Internship.where(noc:false), include: [user: {include: [:name, academic_detail: {only: :rollno}], only: []}, ]
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
