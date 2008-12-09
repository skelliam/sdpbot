require 'logger'
require 'fileutils'

LOGFILENAME = "sdpbot.log"

begin
  begin
    FileUtils.mkdir "log"
  rescue
  end
  
  DEFAULT_LOGGER = Logger.new(File.join(File.dirname(__FILE__), "../log/#{LOGFILENAME}"), shift_age='daily')
#  DEFAULT_LOGGER.level = Logger::INFO 
  DEFAULT_LOGGER.level = Logger::DEBUG

rescue StandardError
  DEFAULT_LOGGER = Logger.new(STDERR)
  DEFAULT_LOGGER.level = Logger::WARN
  DEFAULT_LOGGER.warn(
    "Error: Unable to access log file. Please ensure that #{LOGFILENAME} exists and is chmod 0666. " +
    "The log level has been raised to WARN and the output directed to STDERR until the problem is fixed."
  )
end

module Logging
  def logger
    DEFAULT_LOGGER
  end
end
