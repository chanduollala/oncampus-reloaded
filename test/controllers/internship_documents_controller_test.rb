require "test_helper"

class InternshipDocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @internship_document = internship_documents(:one)
  end

  test "should get index" do
    get internship_documents_url, as: :json
    assert_response :success
  end

  test "should create internship_document" do
    assert_difference("InternshipDocument.count") do
      post internship_documents_url, params: { internship_document: { document_link: @internship_document.document_link, is_verified: @internship_document.is_verified, title: @internship_document.title, user_id: @internship_document.user_id } }, as: :json
    end

    assert_response :created
  end

  test "should show internship_document" do
    get internship_document_url(@internship_document), as: :json
    assert_response :success
  end

  test "should update internship_document" do
    patch internship_document_url(@internship_document), params: { internship_document: { document_link: @internship_document.document_link, is_verified: @internship_document.is_verified, title: @internship_document.title, user_id: @internship_document.user_id } }, as: :json
    assert_response :success
  end

  test "should destroy internship_document" do
    assert_difference("InternshipDocument.count", -1) do
      delete internship_document_url(@internship_document), as: :json
    end

    assert_response :no_content
  end
end
