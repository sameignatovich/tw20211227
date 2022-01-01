# frozen_string_literal: true

require './lib/petsonic'

CATEGORY_URL = ARGV[0]
EXPORT_PATH = ARGV[1]

category = Petsonic.new(CATEGORY_URL || 'https://www.petsonic.com/dermatitis-y-problemas-piel-para-perros/')

category.run
category.export_csv(EXPORT_PATH || 'export.csv')
