class FeedbackMailer < ActionMailer::Base
	default :to => "salulos@gmail.com"
	def message_me(msg)
		@msg = msg

		mail from: @msg.email, subject: 'Feedback - ' + @msg.subject, body: @msg.content
	end
end
