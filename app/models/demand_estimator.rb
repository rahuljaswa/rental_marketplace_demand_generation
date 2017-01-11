require 'adwords_api'

class DemandEstimator
    def estimate_keyword_traffic(should_refresh)
        if should_refresh
            Tag.update_all adwords_max_average_cpc: nil
            Tag.update_all adwords_max_average_position: nil
            Tag.update_all adwords_max_impressions_per_day: nil
            Tag.update_all adwords_max_click_through_rate: nil
            Tag.update_all adwords_max_clicks_per_day: nil
        end

        config_filename = File.join(Rails.root, 'config', 'adwords_api.yml')
        adwords_client = AdwordsApi::Api.new(config_filename)

        tag_batches = Tag.all
        if !should_refresh
            tag_batches = tag_batches.where(adwords_max_average_cpc: nil)
            tag_batches = tag_batches.where(adwords_max_average_position: nil)
            tag_batches = tag_batches.where(adwords_max_impressions_per_day: nil)
            tag_batches = tag_batches.where(adwords_max_click_through_rate: nil)
            tag_batches = tag_batches.where(adwords_max_clicks_per_day: nil)
        end

        tag_batches = tag_batches.each_slice(2000).to_a
        send_requests(adwords_client, tag_batches)
    end

    def send_requests(adwords_client, tag_batches)
        tag_batches.each do |tag_batch|
            keywords = Array.new

            tag_batch.each do |keyword|
                keywords.push({:xsi_type => 'Keyword', :text => (keyword.name + ' rental'), :match_type => 'BROAD'})
            end

            keyword_requests = keywords.map {|keyword| {:keyword => keyword}}

            ad_group_request = {
                :keyword_estimate_requests => keyword_requests,
                :max_cpc => {
                  :micro_amount => 1000000
                }
            }

            campaign_request = {
                :ad_group_estimate_requests => [ad_group_request],
                :criteria => [
                    {:xsi_type => 'Location', :id => 2840},
                    {:xsi_type => 'Language', :id => 1000}
                ]
            }

            selector = {
                :campaign_estimate_requests => [campaign_request]
            }

            response = adwords_client.service(:TrafficEstimatorService, :v201609).get(selector)

            if response && response[:campaign_estimates] && response[:campaign_estimates].size > 0
                campaign_estimate = response[:campaign_estimates].first

                keyword_estimates = campaign_estimate[:ad_group_estimates].first[:keyword_estimates]
                keyword_estimates.each_with_index do |keyword_estimate, index|
                    tag = tag_batch[index]

                    max_estimate = keyword_estimate[:max]
                    tag.adwords_max_average_cpc = max_estimate[:average_cpc] ? (max_estimate[:average_cpc][:micro_amount])/1000000.0 : nil
                    tag.adwords_max_average_position = max_estimate[:average_position]
                    tag.adwords_max_impressions_per_day = max_estimate[:impressions_per_day]
                    tag.adwords_max_click_through_rate = max_estimate[:click_through_rate]
                    tag.adwords_max_clicks_per_day = max_estimate[:clicks_per_day]

                    tag.save
                end
            end
        end
    end
end
