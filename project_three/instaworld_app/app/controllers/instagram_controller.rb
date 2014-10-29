class InstagramController < ApplicationController

  def index
    instagram_base_url = "https://api.instagram.com/oauth/authorize"
    # instagram_scope = "user"
    instagram_state = SecureRandom.urlsafe_base64
    # storing state in session because we need to compare it in a later request
    session[:instagram_state] = instagram_state
    @instagram_uri = "#{instagram_base_url}?client_id=#{INSTAGRAM_CLIENT_ID}&redirect_uri=#{INSTAGRAM_REDIRECT_URL}&response_type=code&state=#{instagram_state}"

  end

  def oauth
    # Instagram OAuth
    # puts session
    # state = params[:state]
    code = params[:code]
    # compare the states to ensure the information is from who we think it is
    if session[:instagram_state] == params[:state]
      instagram_response = HTTParty.post("https://api.instagram.com/oauth/access_token",
                              :body => {
                              client_id: INSTAGRAM_CLIENT_ID,
                              client_secret: INSTAGRAM_CLIENT_SECRET,
                              grant_type: "authorization_code",
                              code: code,
                              redirect_uri: INSTAGRAM_REDIRECT_URL
                              },
                              :headers =>{
                                "Accept" => "application/json"
                                })
        session[:instagram_access_token] = instagram_response["access_token"]
    end
    redirect to("/feed")
  end

  def logout
    session[:instagram_access_token] = nil
    redirect to('/')
  end

  def show
    response = HTTParty.get("https://api.instagram.com/v1/tags/#{@q}/media/recent?access_token=#{insta_access_token}")
    @insta_searched_response = JSON.parse response.to_json
    # Instagram Searched by Location Feed
    # https://api.instagram.com/v1/locations/514276/media/recent?access_token=ACCESS-TOKEN
  end
end
