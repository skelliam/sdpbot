require 'action_mailer'

ActionMailer::Base.delivery_method = :sendmail                                    
ActionMailer::Base.template_root = File.dirname(__FILE__) + '/templates'
ActionMailer::Base.logger = DEFAULT_LOGGER
ActionMailer::Base.perform_deliveries = true

module SDP
  class Notifier < ActionMailer::Base
    def release_tracking(to, release)
      unless release.nil?
        recipients  to
        from        $config['notifier']['from']
        subject     "[#{release.name}] release tracking"     
        body        :release => release
        content_type "text/html"  
      end
    end        
  end
end