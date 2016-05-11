require 'spec_helper'

describe BotMetrics do
  describe '#initialize' do
    context 'when api key is not set' do
      it 'raises an error' do
        expect {
          BotMetrics::Client.new(api_key: nil, bot_id: 'bot_id')
        }.to raise_error("Missing argument api_key. Please pass api_key in as an argument.")
      end
    end

    context 'when bot id is not set' do
      it 'raises an error' do
        expect {
          BotMetrics::Client.new(api_key: 'api_key', bot_id: nil)
        }.to raise_error("Missing argument bot_id. Please pass bot_id in as an argument.")
      end
    end
  end

  describe '#register_bot!' do
    context 'when api_host is not set' do
      let(:client) { BotMetrics::Client.new(api_key: 'api_key', bot_id: 'bot_id') }

      before do
        stub_request(:post, "https://www.getbotmetrics.com/bots/bot_id/instances").
          with(body:    "instance%5Btoken%5D=bot_token&format=json",
               headers: { "Authorization" => 'api_key' }).
          to_return(body: "{\"id\":1}", status: 201)
      end

      it { expect(client.register_bot!('bot_token')).to be_truthy }

      context 'when created_at is sent as a param' do
        before do
          @now = Time.now

          stub_request(:post, "https://www.getbotmetrics.com/bots/bot_id/instances").
            with(body:    "instance%5Btoken%5D=bot_token&format=json&instance%5Bcreated_at%5D=#{@now.to_i}",
                 headers: { "Authorization" => 'api_key' }).
            to_return(body: "{\"id\":1}", status: 201)
        end

        it { expect(client.register_bot!('bot_token', created_at: @now)).to be_truthy }
      end
    end

    context 'when api_host is set' do
      let(:client) { BotMetrics::Client.new(api_key: 'api_key', bot_id: 'bot_id', api_host: 'http://localhost:5000') }

      before do
        stub_request(:post, "http://localhost:5000/bots/bot_id/instances").
          with(body:    "instance%5Btoken%5D=bot_token&format=json",
               headers: { "Authorization" => 'api_key' }).
          to_return(body: "{\"id\":1}", status: 201)
      end

      it { expect(client.register_bot!('bot_token')).to be_truthy }
    end
  end
end
