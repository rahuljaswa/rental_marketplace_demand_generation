class ReportsMailer < ApplicationMailer
	def export_keywords(email, report, csv_file)
		@report = report

		if csv_file
			attachment_title = "Keywords-#{Date.today}.csv"
			attachments[attachment_title] = csv_file
		end
		
		mail(:to => email, :from => ENV['CLIENT_REPLY_EMAIL'], :subject => "Keywords - #{Date.today}")
	end
end
