require 'scrapi'
require 'net/https'
require 'uri'

class MediaWiki
  
  def initialize(host=nil, username=nil, password=nil)
    @host = host || $config['mediawiki']['host']
    @user = username || $config['mediawiki']['username']
    @password = password || $config['mediawiki']['password']
        
    uri = URI.parse("https://#{@host}/")     
    @http = Net::HTTP.new(uri.host, uri.port)
    if uri.is_a?(URI::HTTPS)
      @http.use_ssl = true 
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
  end

  def logged_in?
    @cookies.include?('hq_wiki_mc2__session')
  end
  
  def logout
    @cookies = ''
  end
  
  def login
    uri = URI.parse("https://#{@host}/wiki/index.php?title=Special:Userlogin&action=submitlogin&type=login")     
    req = Net::HTTP::Post.new(uri.request_uri, nil)
    req.set_form_data({'wpName' => @user, 'wpPassword' => @password, 'wpLoginattempt' => 'Log in'})  
    res = secure_request(req) 
    @cookies = cookie_header_to_s(res.get_fields('Set-Cookie'))
    res
  end

  def publish(release)
    iterations = ActionViewHelper.render({:partial => 'iterations', :locals => {:release => release}})
    iterations.gsub!(/<a\s*href="(.*?)">(.*?)<\/a>/i, '[\1 \2]')
    iterations.gsub!(/\n/, '')   
    iterations.gsub!(/\s{2,}/, '')
    edit("Template:Release_#{release.name}_Tracker", iterations)
  end
  
  def edit(page, content)
    if logged_in?
      uri = URI.parse("https://#{@host}/wiki/index.php?title=#{page}&action=edit")     
      req = Net::HTTP::Get.new(uri.request_uri, nil)
      res = secure_request(req) 
      
      input = Scraper.define do
        process '*', :name => "@name", :value => "@value"
        result :name, :value
      end
      
      hidden_fields = Scraper.define do
        array :hidden_fields
        process "input[type='hidden']", :hidden_fields => input
        result :hidden_fields
      end
      
      form = Scraper.define do 
        process "form#editform", :hidden_fields => hidden_fields
        result :hidden_fields
      end
      f = res.body
      # Somehow a backsplash confuses tidy
      f.gsub!(/\\/, "")
      editform = form.scrape(f)
      
      uri = URI.parse("https://#{@host}/wiki/index.php?title=#{page}&action=submit")     
      req = Net::HTTP::Post.new(uri.request_uri, nil)
      data = Hash.new
      editform.each {|element|
        element.value += "\\" if element.name == 'wpEditToken'        
        data.store element.name, element.value
      }
      data.store "wpTextbox1", content
      data.store 'wpSave', 'Save page'
      data.store "wpSummary", ''

      req.set_form_data(data)  
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
    req.basic_auth $config['mediawiki']['web-username'], $config['mediawiki']['web-password']
    req['Cookie'] = @cookies unless @cookies.nil?
    @http.request(req) 
  end
end