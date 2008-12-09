require 'fileutils'
require 'singleton'

module SDP
  class Releases < Hash
    class ReleaseExists < Exception
    end
    
    include Singleton
    
    PATH = File.dirname(__FILE__) + '/../../releases'
    
    attr :loaded
    
    def initialize
      FileUtils.mkdir_p(PATH) unless File.exists?(PATH)
      @loaded = false      
    end
    
    def load      
      # This is a terrible hack. 
      # When a release gets deserialized, every view gets loaded from Bugzilla. That leads to a load of requests
      # and makes it slow.
      # This query loads all the items assigned to a release and should populate the cache so that all subsequent
      # queries should hit the cache and not query Bugzilla
      #View.from_query(Query.all(%w(ReleaseName )))          
      
      Dir.glob("#{PATH}/*.yaml") { |file|
        File.open(file) { |f|          
          release = Release.from_yaml(f)
          self[release.name.downcase.to_sym] = release
        }
      }
      @loaded = true
    end

    def is_loaded?
      @loaded
    end
    
    def save
      each {|key, release|
        save_release(key, release)
      }
    end

    def track_all
      each_value {|release|
        release.track
      }
    end

    # Create a release and save it 
    def create(name, start_date, end_date)
      file_name = name.downcase
      unless file_exists?(file_name) 
        release = Release.new(name, start_date, end_date)
        save_release(file_name, release)
      else
        raise ReleaseExists.new
      end
    end
    
    def find(release)
      if release.is_a?(String)
        key = release.downcase.to_sym
      else
        key = release
      end
      if include?(key)
        return self[key]
      end
      return nil
    end
    
    def to_s
      s = ""
      each {|release|
        s+= release.to_s
      }
      s
    end
    
    private
    def file_exists?(file_name)
      File.exist?("#{PATH}/#{file_name}.yaml")
    end
    
    def save_release(file_name, release)
      # Make a backup
      if file_exists?(file_name)
        FileUtils.cp("#{PATH}/#{file_name}.yaml", "#{PATH}/#{file_name}.yaml.#{Time.now.strftime("%Y-%m-%d-%H-%M-%S")}")
      end
      f = File.new("#{PATH}/#{file_name}.yaml",  "w+")
      f.print release.to_yaml   
      f.close   
    end
  end
end