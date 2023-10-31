class CampusSelectionsController < ApplicationController
  before_action :set_campus_selection, only: %i[ show update destroy ]
  before_action :authorize_collegeadmin_request, only: %i[ create ]
  before_action :authorize_user_request, only: %i[ search student_summary placement_summary ]

  # GET /campus_selections
  def index
    @campus_selections = CampusSelection.all
    render json: @campus_selections
  end

  # GET /campus_selections/1
  def show
    render json: @campus_selection
  end

  def search
    if params[:recruitment_id]
      @campus_selections = CampusSelection.where(recruitment_id: params[:recruitment_id])
      render json: @campus_selections, only:[:id,:ctc], include: [user: {only: [:id], include: [:name, academic_detail: {only:[:section, :rollno], include: [branch:{only: :abbr}]}]}]
    end
  end

  def student_summary
    user = User.find(params[:id])
    selections = user.campus_selections


    render json: {
      selections: selections.map do |selection|
        {
          recruitment_id: selection.recruitment_id,
          ctc: selection.recruitment.ctc,
          role: selection.recruitment.role,
          company: {
            name: selection.recruitment.company.company_name,
            id: selection.recruitment.company.id
          },
          type: selection.recruitment.role_type
        }
      end
    }
  end


  def get_selection_summary
    result = User.joins(:academic_detail, :campus_selections)
                 .where(campus_selections: { recruitment_id: params[:recruitment_id] })
                 .group('academic_details.branch_id')
                 .select('academic_details.branch_id, COUNT(*) as count')
                 .includes(academic_detail: :branch)
                 .order('academic_details.branch_id')

    total_count = result.sum(&:count)

    branch_wise_counts = result.map do |row|
      {
        branch_id: row.branch_id,
        branch_abbr: Branch.find(row.branch_id).abbr,
        count: row.count
      }
    end

    render json: { total_count: total_count, branch_wise: branch_wise_counts }
  end

  # POST /campus_selections
  def create
    @campus_selection = CampusSelection.new(campus_selection_params)
    if @campus_selection.save
      render json: @campus_selection, status: :created
    else
      render json: @campus_selection.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /campus_selections/1
  def update
    if @campus_selection.update(campus_selection_params)
      render json: @campus_selection
    else
      render json: @campus_selection.errors, status: :unprocessable_entity
    end
  end

  # DELETE /campus_selections/1
  def destroy
    @campus_selection.destroy
  end



  def export_placements_data
    require 'rubyXL'
    require 'rubyXL/convenience_methods'
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]

    worksheet.add_cell(0,0, "PLACEMENT DATA - Generated at: " + DateTime.now.strftime("%B %d, %Y %I:%M %p"))
    worksheet.merge_cells(0,0,1,10)
    worksheet.change_row_horizontal_alignment(0, 'center')


    headers = [
      "Roll number", "Name",
      "Email address", "Phone", "Year of passing",
      "Branch", "Section", "Selections"
    ]

    headers.each_with_index do |header, index|
      worksheet.add_cell(2, index, header)
    end

    headers = [
      "", "",
      "", "", "",
      "", "", "Company", "Role", "CTC", "Job type"
    ]

    headers.each_with_index do |header, index|
      worksheet.add_cell(3, index, header)
    end

    (0...7).to_a.each do |col|
      worksheet.merge_cells(2, col, 3, col)
    end
    worksheet.merge_cells(2,7,2,10)

    query = User.joins(:academic_detail => :branch)

    if params[:yop].present?
      query = query.where("academic_details.yop = ?", params[:yop])
    end

    if params[:branch].present?
      query = query.where("branches.id= ?", params[:branch])
    end

    if params[:section].present?
      query = query.where("academic_details.section = ?", params[:section])
    end

    users = query


    row_index = 5



    users.each_with_index do |user, index|
      details = [
        user.academic_detail.rollno || '',
        "#{user.name&.first} #{user.name&.middle} #{user.name&.last}".strip,
        user.contact_detail&.email || '',
        user.contact_detail&.phone || '',
        user.academic_detail&.yop || '',
        user.academic_detail&.branch&.title || '',
        user.academic_detail&.section || '',
      ]

      details.each_with_index do |entry, index2|
        worksheet.add_cell(row_index, index2, entry)
      end

      selections=CampusSelection.where(user_id: user.id)

      if selections.length>0
        (0...7).to_a.each do |col|
          worksheet.merge_cells(row_index, col, row_index+selections.length-1, col)
        end
      end


      selections.each_with_index do |selection, index|
        worksheet.add_cell(row_index, 7, selection.recruitment.company.company_name)
        worksheet.add_cell(row_index, 8, selection.recruitment.role)
        worksheet.add_cell(row_index, 9, selection.recruitment.ctc)
        worksheet.add_cell(row_index, 10, selection.recruitment.role_type)
        if index!=selections.length-1
          row_index+=1
        end
      end

      row_index+=1
    end

    (0..9).to_a.each do |col|
      worksheet.change_column_vertical_alignment(col = col, alignment = 'top')
    end

    (0..4).to_a.each do |row|
      worksheet.change_row_bold(row, true )
    end


    # worksheet.data_validations = RubyXL::DataValidations.new

    # #validation
    # content = ['Afghanistan','Albania','Algeria']
    # formula = RubyXL::Formula.new(expression: "\"#{content.join(',')}\"")
    # worksheet.data_validations << RubyXL::DataValidation.new(
    #   sqref: RubyXL::Reference.new(0, 0),
    #   formula1: formula,
    #   type: 'list',
    #   prompt_title: nil,
    #   prompt: nil,
    #   show_input_message: true
    # )

    # Set the filename and content type for the attachment
    filename = 'student_data.xlsx'
    content_type = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'

    workbook.write(filename)
    send_file filename, filename: filename, type: content_type, disposition: 'attachment'
    # render json: users
  end


  def placement_summary
    branches = Branch.all

    data = {branchwise: []}


    branches.each do |branch|
      @students_count = AcademicDetail.where(branch_id: branch.id).count
      @selected_students_count = User.joins(:academic_detail).where(academic_details: { branch_id: branch.id }).joins(:campus_selections).distinct.count
      if @students_count > 0
        placement_percent = (@selected_students_count.to_f / @students_count) * 100
      else
        placement_percent = 0.0
      end

      # data.push({branch: branch.abbr, percent: sprintf('%.2f', placement_percent) })
      data[:branchwise].push({ branch: branch.abbr, total: @students_count , selected: @selected_students_count, percent: sprintf('%.1f', placement_percent)})
    end


    render json: data
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_campus_selection
      @campus_selection = CampusSelection.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def campus_selection_params
      params.require(:campus_selection).permit(:user_id, :recruitment_id, :ctc)
    end

    def authorize_collegeadmin_request
      header = request.headers['Authorization']
      header = header.split(' ').last if header
      begin
        @decoded = Service::JsonWebToken.decode(header)
        @college_admin = User.find_by(id:@decoded[:user_id], usertype:'CA')
        if @college_admin
          return @college_admin
        end
        render json: { errors: "access denied" }, status: :unauthorized
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: e.message }, status: :unauthorized
      rescue JWT::DecodeError => e
        render json: { errors: e.message }, status: :unauthorized
      end
    end

    def authorize_user_request
      header = request.headers['Authorization']
      header = header.split(' ').last if header
      begin
        @decoded = Service::JsonWebToken.decode(header)
        @user = User.find_by(id:@decoded[:user_id])
        if @user
          return @user
        end
        render json: { errors: "access denied" }, status: :unauthorized
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: e.message }, status: :unauthorized
      rescue JWT::DecodeError => e
        render json: { errors: e.message }, status: :unauthorized
      end
    end
end
