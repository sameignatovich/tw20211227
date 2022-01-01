# frozen_string_literal: true

require 'logger'

def init_logger
  logger = Logger.new($stdout)
  logger.level = Logger::INFO

  logger.formatter = proc do |severity, datetime, _progname, msg|
    date_format = datetime.strftime('%Y-%m-%d %H:%M:%S')
    "[#{date_format}] #{severity.ljust(5)}: '#{msg}'\n"
  end

  logger
end
