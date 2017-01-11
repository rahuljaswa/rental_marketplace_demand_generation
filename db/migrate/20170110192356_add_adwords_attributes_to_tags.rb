class AddAdwordsAttributesToTags < ActiveRecord::Migration[5.0]
	def change
		add_column :tags, :adwords_max_average_cpc, :float
		add_column :tags, :adwords_max_average_position, :float
		add_column :tags, :adwords_max_impressions_per_day, :float
		add_column :tags, :adwords_max_click_through_rate, :float
		add_column :tags, :adwords_max_clicks_per_day, :float
	end
end
