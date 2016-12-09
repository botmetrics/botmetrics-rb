require "json"
require "http"

module BotMetrics
  class Client
    DEFAULT_API_HOST = "https://www.getbotmetrics.com".freeze

    def initialize(api_key: nil, bot_id: nil, api_host: nil)
      @api_key  = api_key  || ENV['BOTMETRICS_API_KEY']
      @bot_id   = bot_id   || ENV['BOTMETRICS_BOT_ID']
      @api_host = api_host || ENV['BOTMETRICS_API_HOST'] || DEFAULT_API_HOST

      if blank?(@api_key)
        raise ArgumentError.new("Missing argument api_key. Please pass api_key in as an argument.")
      end

      if blank?(@bot_id)
        raise ArgumentError.new("Missing argument bot_id. Please pass bot_id in as an argument.")
      end
    end

    def register_bot!(token, opts = {})
      params = { "format" => "json", "instance[token]" => token }

      created_at = opts[:created_at] || opts["created_at"]
      params["instance[created_at]"] = created_at.to_i if created_at.to_i != 0

      response = HTTP.auth(api_key).post("#{api_url}/instances", params: params)

      response.code == 201
    end

    def track(event)
      event_json = nil

      if event.is_a?(Hash)
        event_json = event.to_json
      elsif event.is_a?(String)
        begin
          event_json = JSON.parse(event)
        rescue JSON::ParserError
          raise ArgumentError.new("event is not a valid JSON string or Hash")
        end
        event_json = event
      end

      if event_json.nil?
        raise ArgumentError.new("event is not a valid JSON string or Hash")
      end

      response = HTTP.auth(api_key).post("#{api_url}/events", params: {event: event_json, format: 'json'})
      response.code == 202
    end

    def message(team_id, opts = {})
      channel = opts[:channel]
      user = opts[:user]
      text = opts[:text]
      attachments = opts[:attachments]

      if blank?(channel) && blank?(user)
        raise ArgumentError.new("Missing argument channel and user. Please provide at least one.")
      end

      if blank?(text) && blank?(attachments)
        raise ArgumentError.new("Missing argument text and attachments. Please provide at least one.")
      end

      params = {
        "message[team_id]"     => team_id,
        "message[channel]"     => channel,
        "message[user]"        => user,
        "message[text]"        => text,
        "message[attachments]" => message_attachments(attachments)
      }.delete_if { |_, v| v.nil? }

      response = HTTP.auth(api_key).post("#{api_url}/messages", params: params)

      response.code == 202
    end

    def short_link(url, user_id, opts = {})
      params = {
        'user_id' => user_id,
        'url'     => url,
      }.merge(opts).delete_if { |_, v| v.nil? }

      response = HTTP.auth(api_key).post("#{api_url}/short_links", params: params)

      if response.code == 200
        JSON.parse(response.body)['url']
      else
        return nil
      end
    end

    private
    attr_accessor :api_key, :bot_id, :api_host

    def blank?(attr)
      attr.nil? || attr == ''
    end

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

    def message_attachments(attachments)
      if attachments.nil?
        nil
      else
        if attachments.is_a? String
          attachments
        else
          attachments.to_json
        end
      end
    end
  end
end
