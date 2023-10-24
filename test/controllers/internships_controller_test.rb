require "test_helper"

class InternshipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @internship = internships(:one)
  end

  test "should get index" do
    get internships_url, as: :json
    assert_response :success
  end

  test "should create internship" do
    assert_difference("Internship.count") do
      post internships_url, params: { internship: { company_name: @internship.company_name, end_date: @internship.end_date, noc: @internship.noc, role_title: @internship.role_title, start_date: @internship.start_date, stipend: @internship.stipend, user_id: @internship.user_id } }, as: :json
    end

    assert_response :created
  end

  test "should show internship" do
    get internship_url(@internship), as: :json
    assert_response :success
  end

  test "should update internship" do
    patch internship_url(@internship), params: { internship: { company_name: @internship.company_name, end_date: @internship.end_date, noc: @internship.noc, role_title: @internship.role_title, start_date: @internship.start_date, stipend: @internship.stipend, user_id: @internship.user_id } }, as: :json
    assert_response :success
  end

  test "should destroy internship" do
    assert_difference("Internship.count", -1) do
      delete internship_url(@internship), as: :json
    end

    assert_response :no_content
  end
end
