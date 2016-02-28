require "rails_helper"

describe API::V1 do
  include Rack::Test::Methods

  def app
    API::V1::Registrations
  end

  let(:parameters) {
    {
      email: "james@lixibox.com",
      first_name: "James",
      last_name: "William",
      password: "12345678",
      password_confirmation: "12345678",
      phone: "9098887777666"
    }
  }
  describe "User Registration" do
    context "When user input valid information" do
      it "returns access token and user information" do
        post "/api/v1/registrations", parameters
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body).keys).to include("access_token")
      end
    end

    context "When user input wrong information" do
      it "response errors message on required fields" do
        post "/api/v1/registrations", {}
        expect(last_response.status).to eq(422)
        expect(JSON.parse(last_response.body)).to eql({
          "email"=>["can't be blank"],
          "password"=>["can't be blank"],
        })
      end

      context "When email invalid" do
        it "returns email is invalid" do
          parameters.merge!(email: "james")
          post "/api/v1/registrations", parameters
          expect(last_response.status).to eq(422)
          expect(JSON.parse(last_response.body)).to eql({"email"=>["is invalid"]})
        end

        it "returns email exists" do
          create(:user, email: "james@lixibox.com")
          post "/api/v1/registrations", parameters
          expect(last_response.status).to eq(422)
          expect(JSON.parse(last_response.body)).to eql({"email"=>["đã có trong hệ thống."]})
        end
      end

      context "When input invalid password" do
        it "return invalid password"  do
          parameters.merge!(password: "123", password_confirmation: "123")
          post "/api/v1/registrations", parameters
          expect(last_response.status).to eq(422)
          expect(JSON.parse(last_response.body)["password"]).to eql(["is too short (minimum is 8 characters)"])
        end
      end
    end
  end
end
