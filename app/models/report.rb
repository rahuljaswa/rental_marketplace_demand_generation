class Report < ApplicationRecord
	def self.keywords_report
		report = Hash.new
		report_data = Array.new
		
		report["column_headers"] = [
			"CPC",
			"CTR",
			"Daily Impressions",
			"Daily Clicks"
		]

		tags = Tag.where.not(adwords_max_impressions_per_day: nil).order(adwords_max_impressions_per_day: :desc)
		tags.each do |tag|
			tag_row = Hash["row_title" => (tag.name + ' rental')]
			tag_row["data"] = [
				tag.adwords_max_average_cpc.to_s,
				tag.adwords_max_click_through_rate.to_s,
				tag.adwords_max_impressions_per_day.to_s,
				tag.adwords_max_clicks_per_day.to_s
			]
			report_data.push(tag_row)
		end

		report["data"] = report_data

		return report
	end
end
