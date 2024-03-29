require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RentalMarketplaceDemandGeneration
	class Application < Rails::Application
		config.autoload_paths += Dir[Rails.root.join('app', '{*/}')]
		config.autoload_paths += %W(#{config.root}/lib)
		config.autoload_paths += Dir["#{config.root}/lib/**/"]

		config.before_configuration do
			env_file = File.join(Rails.root, 'config', 'local_env.yml')
			YAML.load(File.open(env_file)).each do |key, value|
				ENV[key.to_s] = value
			end if File.exists?(env_file)	
		end
	end
end
