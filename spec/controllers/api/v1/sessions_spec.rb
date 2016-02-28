require "rails_helper"

describe API::V1 do
  include Rack::Test::Methods

  def app
    API::V1::Sessions
  end

  let!(:user) { create(:user) }

  describe "User Login" do
    context "When user input valid information" do
      it "returns access token" do
        post "/api/v1/sessions", { email: user.email, password: user.password }
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body).keys).to include("access_token")
      end
    end

    context "When user input wrong information" do
      it "email and password blank" do
        post "/api/v1/sessions", {}
        expect(last_response.status).to eq(422)
        expect(JSON.parse(last_response.body)).to eql({"error" => "Invalid email or password"})
      end

      it "email invalid" do
        post "/api/v1/sessions", { email: "james" }
        expect(last_response.status).to eq(422)
        expect(JSON.parse(last_response.body)).to eql({"error" => "Invalid email or password"})
      end

      it "password blank" do
        post "/api/v1/sessions", { email: user.email }
        expect(last_response.status).to eq(422)
        expect(JSON.parse(last_response.body)).to eql({"error" => "Invalid email or password"})
      end

      it "email blank" do
        post "/api/v1/sessions", { password: user.password }
        expect(last_response.status).to eq(422)
        expect(JSON.parse(last_response.body)).to eql({"error" => "Invalid email or password"})
      end

      it "account not exist" do
        post "/api/v1/sessions", { email: "james@lixibox.com", password: "password" }
        expect(last_response.status).to eq(422)
        expect(JSON.parse(last_response.body)).to eql({"error" => "Invalid email or password"})
      end
    end
  end

  describe "User logout" do
    before {
      post "/api/v1/sessions", { email: user.email, password: user.password }
    }
    context "When access_token is invalid" do
      it "access_token blank" do
        delete "/api/v1/sessions", { access_token: nil }
        expect(last_response.status).to eq(422)
        expect(JSON.parse(last_response.body)).to eql({"error" => "Invalid access token."})
      end

      it "can not logout" do
        delete "/api/v1/sessions", { access_token: "xxxxxxxxxxxxxxxxxxx" }
        expect(last_response.status).to eq(422)
        expect(JSON.parse(last_response.body)).to eql({"error" => "Invalid access token."})
      end
    end

    context "When access_token is valid" do
      it "can logout" do
        user.reload
        delete "/api/v1/sessions", { access_token: user.authentication_token }
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).not_to eql({"status" => "Invalid access token."})
      end
    end
  end
end
