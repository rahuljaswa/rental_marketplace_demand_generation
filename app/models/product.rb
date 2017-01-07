class Product < ApplicationRecord
	has_and_belongs_to_many :tags, :join_table => :tags_products
end
