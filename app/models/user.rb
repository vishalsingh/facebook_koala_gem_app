class User < ActiveRecord::Base
  attr_accessible :name, :oauth_expires_at, :oauth_token, :provider, :uid
  # def self.from_omniauth(auth)
  #   where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
  #     user.provider = auth.provider
  #     user.uid = auth.uid
  #     user.name = auth.info.name
  #     user.oauth_token = auth.credentials.token
  #     user.oauth_expires_at = Time.at(auth.credentials.expires_at)
  #     user.save!
  #   end
  # end

  def self.create_with_omniauth(auth)
  create! do |user|
    user.provider = auth['provider']
    user.uid = auth['uid']
    if auth['info']
      user.name = auth['info']['name'] || ""
      #user.email = auth['info']['email'] || ""
    end
  end
end


def facebook(token)
    @facebook ||= Koala::Facebook::API.new(token)
    block_given? ? yield(@facebook) : @facebook
  rescue Koala::Facebook::APIError => e
    logger.info e.to_s
    nil
  end
  
  def friends_count(token)
    facebook(token) { |fb| fb.get_connection("me", "friends").size}
  end

 def friends_list(token)
  facebook(token) { |fb| fb.get_connection('me','friends',:fields=>"name,relationship_status,location,email")}
    # facebook(token) { |fb| fb.get_connection('me','friends',:fields=>"name,relationship_status,location,email")}
  end

   def status_single_friend(token)
   # facebook { |fb| fb.get_connection('me','friends',:fields=>"name,gender,relationship_status")}
    facebook(token).fql_query("select uid, name, relationship_status from user WHERE relationship_status='single' AND uid in (select uid2 from friend where uid1 = me())")
  end
end
