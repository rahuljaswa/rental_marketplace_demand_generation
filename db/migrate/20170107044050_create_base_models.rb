class CreateBaseModels < ActiveRecord::Migration[5.0]
	def change
		create_table :tags do |t|
			t.string :name, :null => false
			t.string :image_url, :null => false
			t.timestamps
		end

		create_table :products do |t|
			t.string :title, :null => false
			t.boolean :active, :default => true
			t.text :description
			t.float :security_deposit, :null => false
			t.float :price, :null => false
			t.string :image_urls, array: true, default: []
			t.timestamps
		end

		create_table :tags_products, id: false do |t|
			t.belongs_to :tag, index: true
			t.belongs_to :product, index: true
		end
	end
end
