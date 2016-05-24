class FeedbackMailer < ActionMailer::Base
	default :to => "foodstella.info@gmail.com"
	def message_me(msg)
		@msg = msg

		mail from: @msg.email, subject: 'Feedback - ' + @msg.subject, body: 'Feedback from: ' + @msg.name + ' - ' + @msg.email + ' Content: ' + @msg.content
	end
end
