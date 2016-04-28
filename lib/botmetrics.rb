require "json"
require "excon"

class BotMetrics
  VERSION = "0.0.2"

  def self.register_bot!(token, opts = {})
    team_id = opts[:team_id] || opts['team_id'] || ENV['BOTMETRICS_TEAM_ID']
    bot_id = opts[:bot_id] || opts['bot_id'] || ENV['BOTMETRICS_BOT_ID']
    api_key = opts[:api_key] || opts['api_key'] || ENV['BOTMETRICS_API_KEY']

    if team_id.nil? || team_id == ""
      raise ArgumentError.new("You have to either set the env variable BOTMETRICS_TEAM_ID or pass in an as argument team_id")
    end
    if bot_id.nil? || bot_id == ""
      raise ArgumentError.new("You have to either set the env variable BOTMETRICS_BOT_ID or pass in an as argument bot_id")
    end
    if api_key.nil? || api_key == ""
      raise ArgumentError.new("You have to either set the env variable BOTMETRICS_API_KEY or pass in an as argument api_key")
    end

    created_at = opts[:created_at] || opts['created_at']
    host = ENV['BOTMETRICS_API_HOST'] || 'https://www.getbotmetrics.com'

    opts = {
      omit_default_port: true,
      idempotent: true,
      retry_limit: 6,
      read_timeout: 360,
      connect_timeout: 360
    }

    params = { "instance[token]" => token }
    params["instance[created_at]"] = created_at.to_i if created_at.to_i != 0
    params["format"] = "json"

    url = "#{host}/teams/#{team_id}/bots/#{bot_id}/instances"
    opts[:body] = URI.encode_www_form(params)
    opts[:headers] = { "Authorization" => api_key }

    connection = Excon.new(url, opts)
    response = connection.request(method: :post)

    response.status == 201
  end
end
