require "./app.rb"
require "spec_helper"

describe App do
  def app
    App
  end

  def build_request(command)
    <<-END
      [{"device":"socket", "command": "#{command}", "network": "0xc6d2", "socket":0}]
    END
  end

  describe "controlling the hacklet" do
    context "with an invalid" do
      before do
        allow_any_instance_of(app).to receive(:configuration).and_return({ "key" => "b" })
      end

      context "key" do
        let(:body) { build_request("on") }

        it "fails" do
          post "/", body
          expect(last_response.status).to eq(403)
        end
      end
    end

    context "with a valid credentials" do
      before do
        allow_any_instance_of(app).to receive(:configuration).and_return({ "key" => "key" })
      end

      describe "turning on" do
        let(:body) { build_request("on") }

        it "succeeds" do
          expect_any_instance_of(Plugins::Socket).to receive(:`).with("hacklet on -n 0xc6d2 -s 0").and_return("None")
          post "/?key=key", body
          expect(last_response.status).to eq(200)
        end
      end

      describe "turning off" do
        let(:body) { build_request("off") }

        it "succeeds" do
          expect_any_instance_of(Plugins::Socket).to receive(:`).with("hacklet off -n 0xc6d2 -s 0").and_return("None")
          post "/?key=key", body
          expect(last_response.status).to eq(200)
        end
      end
    end
  end
end
