class FeedbacksController < ApplicationController
	def new
		@feedback = Feedback.new
	end

	def create
	    @feedback = Feedback.new(feedback_params)

	    if @feedback.valid?
			FeedbackMailer.message_me(@feedback).deliver!
			redirect_to new_feedback_path, notice: "Thank you for your feedback!"
	    else
	      render :new
	    end
	  end

	  private

	  def feedback_params
	    params.require(:feedback).permit(:name, :email, :subject, :content)
	  end

end
