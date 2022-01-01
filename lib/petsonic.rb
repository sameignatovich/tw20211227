# frozen_string_literal: true

require 'set'
require 'csv'
require 'nokogiri'
require 'ruby-progressbar'

require_relative 'common'
require_relative 'consts'
require_relative 'utils'

class Petsonic
  def initialize(category_url)
    @category_url = category_url

    @logger = init_logger
    @crawled_pages = Set.new
    @products = []
  end

  def run
    @logger.info('Downloading category pages')
    pages = download_pages

    @logger.info('Extracting products urls')
    products_urls = extract_products_urls(pages)

    @logger.info("Products urls count: #{products_urls.length}")

    load_products(products_urls)
  end

  def export_csv(export_path)
    File.write(export_path, @products.map(&:to_csv).join)
    @logger.info("Export of data to #{export_path} completed!")
  end

  private

  def download_pages
    page_num = 1
    html_pages = []

    # while page
    loop do
      link = "#{@category_url}?p=#{page_num}"
      catergory_page, category_headers = fetch_page(link)
      current_location = get_location(category_headers) || link

      # indication what this page repeat previous (eg repeated last page in category)
      break unless @crawled_pages.add?(current_location)

      @logger.info("Page ##{page_num} downloaded")
      html = Nokogiri::HTML5(catergory_page)
      html_pages.push(html)
      page_num += 1
    end

    html_pages
  end

  def extract_products_urls(pages)
    products_urls = []

    pages.each do |page|
      hrefs = page.xpath(XPATH_COLLECTION[:product_page_url])

      hrefs.each do |href|
        products_urls.push(href.to_s)
      end
    end

    products_urls
  end

  def load_products(products_urls)
    urls_progress = ProgressBar.create(format: '%e %P% |%b>%i| %c/%C', starting_at: 0, total: products_urls.length)

    products_urls.each do |url|
      product_html, = fetch_page(url)

      html = Nokogiri::HTML5(product_html)

      extract_product(html)

      urls_progress.increment
    end
  end

  def extract_product(html)
    product_title = html.xpath(XPATH_COLLECTION[:product_name]).to_s.strip!
    product_picture = html.xpath(XPATH_COLLECTION[:product_img]).to_s
    variations = html.xpath(XPATH_COLLECTION[:product_vatiations])

    variations.each do |li|
      vatiation_name = li.xpath(XPATH_COLLECTION[:variation_name]).to_s
      variation_price = li.xpath(XPATH_COLLECTION[:variation_price]).to_s.split(' ').first

      @products.push(["#{product_title} - #{vatiation_name}", variation_price, product_picture])
    end
  end
end
