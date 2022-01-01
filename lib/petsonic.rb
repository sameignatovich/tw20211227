# frozen_string_literal: true

require 'curb'
require 'nokogiri'
require 'csv'
require 'ruby-progressbar'

class Petsonic
  def initialize(category_url)
    @category_url = category_url

    @products = []
  end

  def load_products_with_variations
    pages = load_pages
    products_urls = parse_pages(pages)

    p "Products urls count: #{products_urls.length}"

    load_products_data(products_urls)
  end

  def export_csv(category_path)
    File.write('export.csv', @products.map(&:to_csv).join)
    puts "Export of data to #{category_path} complete!"
  end

  private

  def load_pages
    page = 1
    html_pages = []

    # while page
    loop do
      p "Load category page - #{page}"

      url = fetch_page(page)
      html = Nokogiri::HTML5(url.body_str)

      # indication what this page repeat previous (eg repeated last page in category)
      break if html.xpath(".//div[contains(@class, 'af dynamic-loading next')]").empty?

      html_pages.push(html)
      page += 1
    end

    html_pages
  end

  def parse_pages(pages)
    products_urls = []

    pages.each do |page|
      hrefs = page.xpath(".//a[@class = 'product-name']/@href")

      hrefs.each do |href|
        products_urls.push(href.to_s)
      end
    end

    products_urls
  end

  def fetch_page(page_num)
    if page_num > 1
      url = "#{@category_url}?p=#{page_num}"
      Curl.get(url)
    else
      Curl.get(@category_url)
    end
  end

  def load_products_data(products_urls)
    urls_progress = ProgressBar.create(format: '%e %P% |%b>%i| %c/%C', starting_at: 0, total: products_urls.length)

    products_urls.each do |url|
      product_html = Curl.get(url)
      html = Nokogiri::HTML5(product_html.body_str)

      product_title = html.xpath("//h1[@class = 'product_main_name']/text()").to_s.strip!
      product_picture = html.xpath("//img[@id = 'bigpic']/@src").to_s
      variations = html.xpath("//ul[contains(@class, 'attribute_radio_list')]/li")

      variations.each do |li|
        vatiation_name = li.xpath(".//span[@class = 'radio_label']/text()").to_s
        price = li.xpath(".//span[@class = 'price_comb']/text()").to_s.split(' ').first

        @products.push(["#{product_title} - #{vatiation_name}", price, product_picture])
      end

      urls_progress.increment
    end
  end
end
