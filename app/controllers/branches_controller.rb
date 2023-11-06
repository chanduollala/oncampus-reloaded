class BranchesController < ApplicationController
  before_action :set_branch, only: %i[ show update destroy ]
  before_action :authorize_collegeadmin_request, only: %i[  ]
  before_action :authorize_user_request, only: %i[ index ]


  # GET /branches
  def index

    @branches = Branch.where(college_id:@user.college.id)

    render json: @branches, only: [:id, :abbr]
  end



  # GET /branches/1
  def show
    render json: @branch, only: [ :abbr, :title]
  end

  # POST /branches
  def create
    @branch = Branch.new(branch_params)

    if @branch.save
      render json: @branch, status: :created, location: @branch
    else
      render json: @branch.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /branches/1
  def update
    if @branch.update(branch_params)
      render json: @branch
    else
      render json: @branch.errors, status: :unprocessable_entity
    end
  end

  # DELETE /branches/1
  def destroy
    @branch.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_branch
      @branch = Branch.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def branch_params
      params.require(:branch).permit(:title, :abbr, :des, :college_id)
    end
end
