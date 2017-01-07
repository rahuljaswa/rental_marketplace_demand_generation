require 'mechanize'


namespace :bootstrap do
	task :delete_bootstraps => :environment do
		products = Product.all
		products.each do |product|
			product.destroy
		end

		tags = Tag.all
		tags.each do |tag|
			tag.destroy
		end
	end

	task :populate_music => :environment do
		mechanize = Mechanize.new
		page = safely_get(mechanize, 'http://www.samash.com/SiteMapView?storeId=10001&urlRequestType=Base&langId=-1&catalogId=10051')
		return if page.nil?

		page.parser.css('div.department-box ul.links li a').each do |category|
			category_selector = 'div.department-box ul.links li a'
			product_selector = 'div.prod-matrix p.name a'
			product_security_deposit_selector = 'b.sale-price'
			product_description_selector = 'div.prod-detail-content span#PIPlongDescription'
			product_description_attribution = 'Sam Ash'
			product_tags_selector = 'ul.breadcrumbs li'
			product_image_selector = 'div#mainImages a'
			product_image_base_link = nil

			traverse_category_page_link(category, mechanize, category_selector, product_selector, product_security_deposit_selector, product_description_selector, product_description_attribution, product_tags_selector, product_image_selector, product_image_base_link)
		end
	end

	task :populate_home => :environment do
		mechanize = Mechanize.new
		page = safely_get(mechanize, 'http://www.homedepot.com/c/site_map')
		return if page.nil?

		page.parser.css('div.legacy-content a.list__link').each do |category|
			category_selector = 'div.legacy-content a.list__link'
			product_selector = 'div.pod-plp__description a'
			product_security_deposit_selector = 'span.pReg'
			product_description_selector = 'div.main_description'
			product_description_attribution = 'The Home Depot'
			product_tags_selector = 'ul#header-crumb li'
			product_image_selector = 'div.media__main-image img'
			product_image_base_link = nil

			traverse_category_page_link(category, mechanize, category_selector, product_selector, product_security_deposit_selector, product_description_selector, product_description_attribution, product_tags_selector, product_image_selector, product_image_base_link)
		end
	end

	task :populate_outdoors => :environment do 
		mechanize = Mechanize.new
		page = safely_get(mechanize, 'http://www.dickssportinggoods.com/category/index.jsp;ab=TopNav_ShopbySport&categoryId=70516396')
		return if page.nil?

		page.parser.css('ul.sub-categories-loop li a').each do |category|
			category_selector = 'ul.sub-categories-loop li a'
			product_selector = 'ul#product-loop li.prod-item a'
			product_security_deposit_selector = 'div.price span.now'
			product_description_selector = 'div.prod-long-desc'
			product_description_attribution = 'Dick\'s Sporting Goods'
			product_tags_selector = 'a.breadcrumb'
			product_image_selector = 'img.prod-image'
			product_image_base_link = 'http://www.dickssportinggoods.com'

			traverse_category_page_link(category, mechanize, category_selector, product_selector, product_security_deposit_selector, product_description_selector, product_description_attribution, product_tags_selector, product_image_selector, product_image_base_link)
		end
	end

	task :populate_photo_video => :environment do
		mechanize = Mechanize.new
		page = safely_get(mechanize, 'https://www.bhphotovideo.com/')
		return if page.nil?

		page.parser.css('section#homePageCategiriesMain div.category a').each do |category|
			category_selector = 'li.clp-category a'
			product_selector = 'div.headder a'
			product_security_deposit_selector = 'span.ypYouPay'
			product_description_selector = 'div.js-highlightsAndReviews ul.top-section-list'
			product_description_attribution = 'B&H Photo Video'
			product_tags_selector = 'ul#breadcrumbs li'
			product_image_selector = 'img#mainImage'
			product_image_base_link = nil

			traverse_category_page_link(category, mechanize, category_selector, product_selector, product_security_deposit_selector, product_description_selector, product_description_attribution, product_tags_selector, product_image_selector, product_image_base_link)
		end
	end

	def safely_get(mechanize, url)
		begin
			return mechanize.get(url)
		rescue => e
			puts "Unknown mechanize exception"
		end
	end

	def sanitize_string(string)
		return string.gsub("\t", "").gsub("\n", "").strip.squish
	end

	def sanitize_number_string(number_string)
		return number_string.gsub(/[^0-9.]/, "")
	end

	def create_or_update_product(product, title, description, security_deposit, tags, image)
		if !product
			product = Product.new
		end

		product.title = title
		product.description = description 
		product.price = security_deposit.to_f * 0.1
		product.security_deposit = security_deposit.to_f
		product.image_urls |= [image]

		product.active = (product.price >= 10.0) ? true : false

		product.tags = []
		tags.each do |tag_name|
			tag = Tag.find_or_create_with_name(tag_name)
			if !tag.image_url
				tag.image_url = image
			end
			product.tags |= [tag]
		end

		product.save
	end

	def traverse_category_page_link(category_page_link, mechanize, category_selector, product_selector, product_security_deposit_selector, product_description_selector, product_description_attribution, product_tags_selector, product_image_selector, product_image_base_link)
		category_page_links = Array.new
		category_page = safely_get(mechanize, category_page_link['href'])
		return if category_page.nil?

		category_page.parser.css(category_selector).each do |link|
			category_page_links << link
		end

		if category_page_links.length > 0
			category_page_links.each do |category_page_link|
				traverse_category_page_link(category_page_link, mechanize, category_selector, product_selector, product_security_deposit_selector, product_description_selector, product_description_attribution, product_tags_selector, product_image_selector, product_image_base_link)
			end
		else
			category_page.parser.css(product_selector).each do |product|
				title = sanitize_string(product.text)
				next if (!title || title.length == 0)

				existing_product = Product.where(title: title).where(active: true).first
				next if existing_product

				product_page = safely_get(mechanize, product['href'])
				next if product_page.nil?

				security_deposit_html = product_page.search(product_security_deposit_selector).first
				next if !security_deposit_html
				security_deposit = sanitize_number_string(security_deposit_html.text)

				description_html = product_page.search(product_description_selector).first
				next if !description_html
				description = 'From '
				description += product_description_attribution
				description += ': '
				description += description_html.text
				description = sanitize_string(description)

				potential_tags = Array.new
				if !product_tags_selector.nil?
					product_page.parser.css(product_tags_selector).each do |tag|
						potential_tags << tag.text
					end
				end
				potential_tags |= title.split(' ')

				tags = Array.new
				potential_tags.each do |tag|
					sanitized_tag = sanitize_string(tag)
					unless !validate_tag(sanitized_tag)
						tags << sanitized_tag
					end
				end

				image_html = product_page.search(product_image_selector).first
				next if !image_html
				image_source = image_html['src']
				if !image_source
					image_source = image_html['href']
				end
				next if !image_source
				
				if product_image_base_link
					image = product_image_base_link + image_source
				else
					image = image_source
				end

				create_or_update_product(existing_product, title, description, security_deposit, tags, image)
			end
		end
	end

	def validate_tag(tag)
		# alphabetical order in case this blacklist balloons
		blacklist = ["available", "and", "for", "home", "kit", "men's", "pro", "shop by sport", "stainless", "steel", "the", "this week's deals", "warranty", "white", "with", "women's"]
		alphanumeric_tag = tag.gsub(/\W+/, '')
		return (!blacklist.include?(tag.downcase) && tag[/[a-zA-Z]+/] && !tag[/[()]+/] && (alphanumeric_tag.length >= 3))
	end
end
