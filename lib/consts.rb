# frozen_string_literal: true

XPATH_COLLECTION = {
  product_page_url: ".//a[@class = 'product-name']/@href",
  product_name: "//h1[@class = 'product_main_name']/text()",
  product_img: "//img[@id = 'bigpic']/@src",
  product_vatiations: "//ul[contains(@class, 'attribute_radio_list')]/li",
  variation_name: ".//span[@class = 'radio_label']/text()",
  variation_price: ".//span[@class = 'price_comb']/text()"
}.freeze
