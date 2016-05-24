require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase
   test 'responds to name, email, subject and content' do
    msg = Feedback.new
    [:name, :email, :subject, :content].each do |attr|
      assert msg.respond_to? attr
    end
  end

  test 'attributes can not be blank' do
      msg = Feedback.new
      refute msg.valid?
    end
end
