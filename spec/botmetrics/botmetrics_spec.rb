require 'spec_helper'

describe BotMetrics do
  describe '.register_bot!' do
    context 'api_key is not set' do
      before do
        ENV['BOTMETRICS_BOT_ID'] = 'bot_id'
      end

      after do
        ENV['BOTMETRICS_BOT_ID'] = nil
      end

      it 'should raise an error' do
        expect {
          BotMetrics.register_bot!('bot_token')
        }.to raise_error("You have to either set the env variable BOTMETRICS_API_KEY or pass in an as argument api_key")
      end
    end

    context 'bot_id is not set' do
      it 'should raise an error' do
        expect {
          BotMetrics.register_bot!('bot_token')
        }.to raise_error("You have to either set the env variable BOTMETRICS_BOT_ID or pass in an as argument bot_id")
      end
    end

    context 'with BOTMETRICS_BOT_ID and BOTMETRICS_API_KEY env variables set' do
      before do
        ENV['BOTMETRICS_BOT_ID'] = 'bot_id'
        ENV['BOTMETRICS_API_KEY'] = 'bot_api_key'
      end

      after do
        ENV['BOTMETRICS_BOT_ID'] = nil
        ENV['BOTMETRICS_API_KEY'] = nil
      end

      context 'when BOTMETRICS_API_HOST is not set' do
        before do
          stub_request(:post, "https://www.getbotmetrics.com/bots/bot_id/instances").
                       with(body: "instance%5Btoken%5D=bot_token&format=json",
                            headers: { "Authorization" => 'bot_api_key' }).
                       to_return(body: "{\"id\":1}", status: 201)
        end

        it 'should return true' do
          expect(BotMetrics.register_bot!('bot_token')).to be_truthy
        end

        context 'when created_at is sent as a param' do
          before do
            @now = Time.now

            stub_request(:post, "https://www.getbotmetrics.com/bots/bot_id/instances").
                    with(body: "instance%5Btoken%5D=bot_token&instance%5Bcreated_at%5D=#{@now.to_i}&format=json",
                         headers: { "Authorization" => 'bot_api_key' }).
                    to_return(body: "{\"id\":1}", status: 201)
          end

          it 'should return true' do
            expect(BotMetrics.register_bot!('bot_token', created_at: @now)).to be_truthy
          end
        end
      end

      context 'when BOTMETRICS_API_HOST is set' do
        before do
          ENV['BOTMETRICS_API_HOST'] = 'http://localhost:5000'
          stub_request(:post, "http://localhost:5000/bots/bot_id/instances").
                       with(body: "instance%5Btoken%5D=bot_token&format=json",
                            headers: { "Authorization" => 'bot_api_key' }).
                       to_return(body: "{\"id\":1}", status: 201)
        end

        it 'should return true' do
          expect(BotMetrics.register_bot!('bot_token')).to be_truthy
        end
      end

      context 'when you pass in arguments' do
        before do
          stub_request(:post, "http://localhost:5000/bots/another_bot_id/instances").
                       with(body: "instance%5Btoken%5D=bot_token&format=json",
                            headers: { "Authorization" => 'another_bot_api_key' }).
                       to_return(body: "{\"id\":1}", status: 201)
        end

        it 'should return true' do
          expect(BotMetrics.register_bot!('bot_token', bot_id: 'another_bot_id',
                                                       api_key: 'another_bot_api_key')).to be_truthy
        end
      end
    end
  end
end
