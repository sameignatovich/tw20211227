# frozen_string_literal: true

require 'curb'
require_relative 'utils'

$logger = init_logger

def fetch_page(url)
  c = Curl::Easy.new(url) do |config|
    config.headers['User-Agent'] = 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'
    config.follow_location = true
  end
  # c.follow_location = true

  begin
    c.perform
    [c.body_str, c.header_str]
  rescue Curl::Err::CurlError => e
    $logger.error("Page loading error! Error: '#{e.class}', Page: #{url}")
    raise e
  end
end

def get_location(headers_str)
  http_response, *http_headers = headers_str.split(/[\r\n]+/).map(&:strip)
  http_headers = Hash[http_headers.flat_map { |s| s.scan(/^(\S+): (.+)/) }]
  http_headers['location']
end
