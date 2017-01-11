namespace :reports do
	task :keywords => :environment do
		report = Array.new
		report.push(Report.keywords_report)
		ReportsMailer.export_keywords("adwords_manager@borrowbear.com", report, nil).deliver_now
	end
end
