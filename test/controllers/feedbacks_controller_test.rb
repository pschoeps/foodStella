require 'test_helper'

class FeedbacksControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
  end

  test "successful post" do
    post :create, message: {
      name: 'cornholio',
      email: 'cornholio@example.com',
      subject: 'hi',
      content: 'bai'
    }

    assert_redirected_to new_message_path
end
