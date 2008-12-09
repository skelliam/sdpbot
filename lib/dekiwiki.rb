require 'net/https'
require 'uri'

class DekiWiki
  
  def initialize(host=nil, username=nil, password=nil)
    @host = host || $config['dekiwiki']['host']
    @user = username || $config['dekiwiki']['username']
    @password = password || $config['dekiwiki']['password']
        
    uri = URI.parse("http://#{@host}/")     
    @http = Net::HTTP.new(uri.host, uri.port)
    if uri.is_a?(URI::HTTPS)
      @http.use_ssl = true 
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
  end

  def logged_in?
    @cookies.include?('authtoken')
  end
  
  def logout
    @cookies = ''
  end
  
  def login
    uri = URI.parse("http://#{@host}/@api/deki/users/authenticate")     
    req = Net::HTTP::Get.new(uri.request_uri, nil)
    res = secure_request(req) 
    @cookies = cookie_header_to_s(res.get_fields('Set-Cookie'))
    res
  end

  def publish(release)
    iterations = ActionViewHelper.render({:partial => 'iterations', :locals => {:release => release}})
    edit("POTI/Product/Bird/#{release.name}/Tracker", iterations)
  end
  
  def edit(page, content)
    if logged_in?    
      # Twice escaped page title
      uri = URI.parse("http://#{@host}/@api/deki/pages/=#{URI.escape(URI.escape(page, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")), Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}/contents?edittime=#{Time.now.strftime("%Y%m%d%H%M%S")}")     
      req = Net::HTTP::Post.new(uri.request_uri, nil)
      req.set_content_type('text/plain')
      req.body = content
      secure_request(req) 
    end
  end

  private
  # Transform a set-cookie header into a cookie string
  def cookie_header_to_s(cookies)
    str = ""
    cookies.each {|cookie|
      str += cookie.split(';')[0] + ';'
    }
    return str
  end
  
  def secure_request(req)
    req.basic_auth @user, @password
    req['Cookie'] = @cookies unless @cookies.nil?
    @http.request(req) 
  end
end