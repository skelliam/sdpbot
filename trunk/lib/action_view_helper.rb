module ActionViewHelper
  def ActionViewHelper.render(opts)
    opts[:locals].each { |key, value| 
      instance_eval "@#{key.to_s}=value" 
      instance_eval "def #{key.to_s}\n @#{key.to_s}\n end\n" 
    } unless opts[:locals].nil?     
    template = ''
    File.open("#{Notifier.template_root}/#{Notifier.mailer_name}/_#{opts[:partial]}.rhtml") { |f| template = f.read } unless opts[:partial].nil?      
    File.open("#{Notifier.template_root}/#{Notifier.mailer_name}/#{opts[:file]}.rhtml") { |f| template = f.read } unless opts[:file].nil?      
    erb = ERB.new(template)
    return erb.result(binding)
  end
end