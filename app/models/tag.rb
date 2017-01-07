class Tag < ApplicationRecord
	has_and_belongs_to_many :products, :join_table => :tags_products

	before_save :set_initial_tag_image, :if => Proc.new { |a| a.image_url.nil? }

	def self.find_or_create_with_name(name)
		sanitized_name = name.squish.downcase
		tag = Tag.where('lower(name) = ?', sanitized_name).first 
		if !tag
			tag = Tag.new(:name => name.squish)
		end
		return tag
	end

	def set_initial_tag_image
		if !self.image_url
			self.image_url = self.products.first.image_urls[0]
		end
	end
end
