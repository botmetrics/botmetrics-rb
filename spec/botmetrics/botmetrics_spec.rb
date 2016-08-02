require 'spec_helper'

describe BotMetrics do
  describe '#initialize' do
    context 'without ENV variables' do
      context 'when api_key is not set' do
        it 'raises an error' do
          expect {
            BotMetrics::Client.new(api_key: nil, bot_id: 'bot_id')
          }.to raise_error("Missing argument api_key. Please pass api_key in as an argument.")
        end
      end

      context 'when bot_id is not set' do
        it 'raises an error' do
          expect {
            BotMetrics::Client.new(api_key: 'api_key', bot_id: nil)
          }.to raise_error("Missing argument bot_id. Please pass bot_id in as an argument.")
        end
      end

      context 'when api_key and bot_id are set' do
        it 'works' do
          client = BotMetrics::Client.new(api_key: 'api_key', bot_id: 'bot_id')
          expect(client.instance_variable_get(:@api_key)).to eq 'api_key'
          expect(client.instance_variable_get(:@bot_id)).to eq 'bot_id'
        end
      end
    end

    context 'with ENV variables' do
      before do
        ENV['BOTMETRICS_API_KEY']  = 'api_key'
        ENV['BOTMETRICS_BOT_ID']   = 'bot_id'
        ENV['BOTMETRICS_API_HOST'] = 'api_host'
      end

      after do
        ENV['BOTMETRICS_API_KEY']  = nil
        ENV['BOTMETRICS_BOT_ID']   = nil
        ENV['BOTMETRICS_API_HOST'] = nil
      end

      it 'defaults to ENV' do
        client = BotMetrics::Client.new
        expect(client.instance_variable_get(:@api_key)).to eq 'api_key'
        expect(client.instance_variable_get(:@bot_id)).to eq 'bot_id'
        expect(client.instance_variable_get(:@api_host)).to eq 'api_host'
      end
    end
  end

  describe '#register_bot!' do
    context 'when api_host is not set' do
      let(:client) { BotMetrics::Client.new(api_key: 'api_key', bot_id: 'bot_id') }

      before do
        stub_request(:post, "https://www.getbotmetrics.com/bots/bot_id/instances?instance%5Btoken%5D=bot_token&format=json").
          with(headers: { "Authorization" => 'api_key' }).
          to_return(body: "{\"id\":1}", status: 201)
      end

      it { expect(client.register_bot!('bot_token')).to be_truthy }

      context 'when created_at is sent as a param' do
        before do
          @now = Time.now

          stub_request(
            :post,
            "https://www.getbotmetrics.com/bots/bot_id/instances?instance%5Btoken%5D=bot_token&format=json&instance%5Bcreated_at%5D=#{@now.to_i}"
          ).
            with(headers: { "Authorization" => 'api_key' }).
            to_return(body: "{\"id\":1}", status: 201)
        end

        it { expect(client.register_bot!('bot_token', created_at: @now)).to be_truthy }
      end
    end

    context 'when api_host is set' do
      let(:client) { BotMetrics::Client.new(api_key: 'api_key', bot_id: 'bot_id', api_host: 'http://localhost:5000') }

      before do
        stub_request(
          :post,
          "http://localhost:5000/bots/bot_id/instances?instance%5Btoken%5D=bot_token&format=json"
        ).
          with(headers: { "Authorization" => 'api_key' }).
          to_return(body: "{\"id\":1}", status: 201)
      end

      it { expect(client.register_bot!('bot_token')).to be_truthy }
    end
  end

  describe '#track' do
    let(:client) { BotMetrics::Client.new(api_key: 'api_key', bot_id: 'bot_id') }
    let!(:event) do
      {
        "name": "event",
        "timestamp": "123456789.0"
      }
    end

    context 'event is a hash' do
      before do
        stub_request(:post, "https://www.getbotmetrics.com/bots/bot_id/events?event=#{event.to_json}").
          with(headers: { "Authorization" => 'api_key' }).
          to_return(status: 201)
      end

      it { expect(client.track(event)).to be_truthy }
    end

    context 'event is a JSON string' do
      before do
        stub_request(:post, "https://www.getbotmetrics.com/bots/bot_id/events?event=#{event.to_json}").
          with(headers: { "Authorization" => 'api_key' }).
          to_return(status: 201)
      end

      it { expect(client.track(event.to_json)).to be_truthy }
    end

    context 'failures' do
      it 'raises error when both event is not a hash' do
        expect {
          client.track(['abc', 'def'])
        }.to raise_error("event is not a valid JSON string or Hash")
      end

      it 'raises error when event is not a valid JSON string' do
        expect {
          client.track('abc')
        }.to raise_error("event is not a valid JSON string or Hash")
      end
    end
  end

  describe '#message' do
    let(:client) { BotMetrics::Client.new(api_key: 'api_key', bot_id: 'bot_id') }

    context 'message with text' do
      before do
        stub_request(:post, "https://www.getbotmetrics.com/bots/bot_id/messages?message%5Bteam_id%5D=T123&message%5Buser%5D=U123&message%5Btext%5D=Text").
          with(headers: { "Authorization" => 'api_key' }).
          to_return(status: 202)
      end

      it { expect(client.message('T123', user: 'U123', text: 'Text')).to be_truthy }
    end

    context 'message with attachments as non string' do
      before do
        stub_request(:post, "https://www.getbotmetrics.com/bots/bot_id/messages?message%5Battachments%5D=%5B%7B%22pretext%22:%22Hi!%22,%22title%22:%22Hello!%22%7D%5D&message%5Bteam_id%5D=T123&message%5Buser%5D=U123").
          with(:headers => { 'Authorization'=>'api_key' }).
          to_return(status: 202)
      end

      it { expect(client.message('T123', user: 'U123', attachments: [{ pretext: 'Hi!', title: 'Hello!' }])).to be_truthy }
    end

    context 'message with attachments as string' do
      before do
        stub_request(:post, "https://www.getbotmetrics.com/bots/bot_id/messages?message%5Battachments%5D=%5B%7B%22pretext%22:%22Hi!%22,%22title%22:%22Hello!%22%7D%5D&message%5Bteam_id%5D=T123&message%5Buser%5D=U123").
          with(:headers => { 'Authorization'=>'api_key' }).
          to_return(status: 202)
      end

      it { expect(client.message('T123', user: 'U123', attachments: [{ pretext: 'Hi!', title: 'Hello!' }].to_json)).to be_truthy }
    end

    context 'failures' do
      it 'raises error when both channel and user are blank' do
        expect {
          client.message('T123', text: 'Hello!')
        }.to raise_error("Missing argument channel and user. Please provide at least one.")
      end

      it 'raises error when both text and attachments are blank' do
        expect {
          client.message('T123', user: 'U123')
        }.to raise_error("Missing argument text and attachments. Please provide at least one.")
      end
    end
  end
end
