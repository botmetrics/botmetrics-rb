require "json"
require "excon"

module BotMetrics
  class Client
    DEFAULT_API_HOST = "https://www.getbotmetrics.com".freeze

    def initialize(api_key:, bot_id:, api_host: nil)
      if api_key.nil? || api_key == ""
        raise ArgumentError.new("Missing argument api_key. Please pass api_key in as an argument.")
      end

      if bot_id.nil? || bot_id == ""
        raise ArgumentError.new("Missing argument bot_id. Please pass bot_id in as an argument.")
      end

      @api_key  = api_key
      @bot_id   = bot_id
      @api_host = api_host || DEFAULT_API_HOST
    end

    def register_bot!(token, opts = {})
      params = { "instance[token]" => token, "format" => "json" }

      created_at = opts[:created_at] || opts["created_at"]
      params["instance[created_at]"] = created_at.to_i if created_at.to_i != 0

      connection = Excon.new("#{api_url}/instances", options(body: URI.encode_www_form(params)))
      response = connection.request(method: :post)

      response.status == 201
    end

    private

      attr_accessor :api_key, :bot_id, :api_host

      def api_url
        "#{api_host}/bots/#{bot_id}"
      end

      def options(extra_params)
        {
          headers: { "Authorization" => api_key },
          omit_default_port: true,
          idempotent: true,
          retry_limit: 6,
          read_timeout: 360,
          connect_timeout: 360
        }.merge(extra_params)
      end
  end

end
