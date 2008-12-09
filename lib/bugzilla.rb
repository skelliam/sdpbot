require 'xmlrpc/client'
require 'net/http'

require 'bugzilla/string_helper'
require 'bugzilla/module_helper'

require 'bugzilla/base'
require 'bugzilla/query'
require 'bugzilla/view'
require 'bugzilla/entities'
include Bugzilla::Entities
require 'bugzilla/attributes'
include Bugzilla::Attributes

module Bugzilla  
  class Bugzilla
    attr :user
    attr :cookies
    attr :host

    attr :xmlrpc
    attr :http
    
    def initialize(host=nil, user=nil, password=nil)
      @host = host || $config['bugzilla']['host']
      @user = user || $config['bugzilla']['username']
      @password = password || $config['bugzilla']['password']
      @cookies = ''    
#      @xmlrpc = XMLRPC::Client.new2("http://#{@host}/xmlrpc.cgi", "127.0.0.1:8888")
      @xmlrpc = XMLRPC::Client.new2("http://#{@host}/xmlrpc.cgi")
      @xmlrpc.timeout = 180
      
      uri = URI.parse("http://#{@host}")
#      @http = Net::HTTP::Proxy('127.0.0.1', 8888).new(uri.host, uri.port)       
      @http = Net::HTTP.new(uri.host, uri.port)       
    end

    def logged_in?
      @cookies.include?('Bugzilla_logincookie')
    end
    
    def login
      http_login
    end

    def logout
      @cookies = ''
    end
          
    def get(url)
      http_get(url)
    end
    
    def call(service, params)
      xmlrpc.call(service, params)
    end
    
    private
    def http_get(path)
      headers = {'Cookie' => @cookies}
      res = http.request_get(path, headers)
      return res.body
    end

    def http_login
      res = Net::HTTP.post_form(URI.parse("http://#{@host}/index.cgi"), {'Bugzilla_login'=>@user, 'Bugzilla_password'=>@password, 'GoAheadAndLogIn'=>'Login'})
      @cookies = cookie_header_to_s(res.get_fields('Set-Cookie'))
      xmlrpc.cookie = @cookies
    end
        
    # Transform a set-cookie header into a cookie string
    def cookie_header_to_s(cookies)
      str = ""
      cookies.each {|cookie|
        str += cookie.split(';')[0] + ';'
      }
      return str
    end
  end
end

Bugzilla::Base.connector = Bugzilla::Bugzilla.new