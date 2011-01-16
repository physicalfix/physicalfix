require 'rubygems'
require 'httparty'
require 'openssl'
require 'cgi'
require 'base64'

class FsFood
  include HTTParty
  BASE_URL = 'http://platform.fatsecret.com/rest/server.api'
  API_SECRET = '9023ababf8434c6cb128ae5c7c8e7fce'
  API_CONSUMER_KEY = 'd353e2aedbab4ed29e2c2cc1f8cdc520'
  DIGEST  = OpenSSL::Digest::Digest.new('sha1')
  
  base_uri = 'platform.fatsecret.com/rest/server.api'
  
  def self.find(id)
    key = cache_key_for_find(id)
    if result = Rails.cache.read(key)
      return result
    else
      params = self.signed_request('GET', {'method' => 'food.get', 'food_id' => id})
      result = get(BASE_URL, :query => params)
      Rails.cache.write(key, result, :expires_in => 24.hours, :raw => false)
      return result
    end
  end
  
  def self.find_all_by_name(food, page = 0)
    key =  cache_key_for_find_by_name(food, page)
    if result = Rails.cache.read(key)
      return result
    else
      params = self.signed_request('GET', {'method' => 'foods.search', 'search_expression' => FsFood.url_escape(food), 'max_results' => 25, 'page_number' => page})
      result = get(BASE_URL, :query => params)
      Rails.cache.write(key, result, :expires_in => 24.hours, :raw => false)
      return result
    end
  end
  
  private
  
  def self.signed_request(http_method, opts = {})
    request_url = CGI::escape(BASE_URL)
    
    oauth_params = {
      'oauth_consumer_key' => API_CONSUMER_KEY,
      'oauth_signature_method' => "HMAC-SHA1",
      'oauth_timestamp' => Time.now.to_i.to_s,
      'oauth_nonce' => [OpenSSL::Random.random_bytes(5)].pack('m').gsub(/\W/,''),
      'oauth_version' => "1.0"
    }
    
    opts.merge!(oauth_params)
    
    sorted_opts = opts.sort
    
    normalized_params = ''
    
    sorted_opts.each do |opt|
      normalized_params += "#{opt[0]}=#{CGI::escape(opt[1].to_s)}&"
    end
    
    normalized_params.chop! #remove the trailing &
    
    string_to_sign = "#{http_method}&#{request_url}&#{CGI::escape(normalized_params)}"
    signature = OpenSSL::HMAC.digest(DIGEST, "#{API_SECRET}&", string_to_sign)
    opts.merge!({:oauth_signature => Base64.encode64(signature).chop})
  end
  
  def self.cache_key_for_find_by_name(food, page)
    "fs_food_search_#{food.gsub(/[^a-z0-9]+/i, '-')}_page_#{page}".downcase
  end
  
  def self.cache_key_for_find(id)
    "#fs_food_get_#{id}".downcase
  end

  def self.url_escape(string)
    string.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
      '%' + $1.unpack('H2' * $1.size).join('%').upcase
    end.tr(' ', '+')
  end
end