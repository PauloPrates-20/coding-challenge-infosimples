=begin
  Campos:

  title: string,
  brand: string,
  categories: string[],
  description: string,
  skus: [
    {
      name: string,
      current_price: float/null,
      old_price: float/null,
      available: bool,
    },
  ],
  properties: [
    {
      label: string,
      value: string,
    },
  ],
  reviews: [
    {
      name: string,
      date: string,
      score: int,
      text: string,
    },
  ],
  reviews_average_score: float,
  url: string,
=end

require 'mechanize'
require 'json'

# URL do site
url = 'https://infosimples.com/vagas/desafio/commercia/product.html'

# Instanciamento do agente
agent = Mechanize.new

# JSON contendo a resposta final
output_json = {}

# Arrays
categories = []
skus = []
properties = []
reviews = []

# Request e parse da página
agent.get(url)
html = agent.page.parser

# Scrapping
# Title
output_json['title'] = html.css('h2#product_title').text
# Brand
output_json['brand'] = html.css('div.brand').text
# Categories
html.css('nav.current-category>a').each { |node|
  categories << node.text
}
output_json['categories'] = categories
# Descriptions
output_json['description'] = html.css('div.proddet>p').text
# Skus
html.css('div.card-container').each { |node|
  sku = {}
  sku['name'] = node.css('div.prod-nome').text

  if node.css('>i')
    sku['available'] = false
    sku['current_price'] = nil
    sku['old_price'] = nil
  else
    sku['available'] = true
    sku['current_price'] = html.css('div.prod-pnow').text.to_f
    sku['old_price'] = html.css('div.prod-pold').text.to_f
  end

  skus << sku
}
output_json['skus'] = skus
# Properties
html.css('tr').each { |node|
  property = {}

  if node.css('td>b').text != "" 
    property['label'] = node.css('td>b').text
    property['value'] = node.css('td:nth-child(2)').text

    properties << property
  end

}
output_json['properties'] = properties
# Reviews
html.css('div.analisebox').each { |node|
  review = {}

  review['name'] = node.css('span.analiseusername').text
  review['date'] = node.css('span.analisedate').text
  # Lógica para a extrair o score a partir da quantidade de estrelas
  stars = node.css('span.analisestars').text
  score = stars.length
  stars.length.times { |index| 
    score -= 1 if stars[index] != '★'
  }
  review['score'] = score
  review['text'] = node.css('p').text

  reviews << review
}
output_json['reviews'] = reviews
# Reviews_average_score
output_json['reviews_average_score'] = /\d.\d/.match(html.css('div#comments>h4').text).to_s.to_f
# URL
output_json['url'] = url

# Arquivo de saída
File.open('out/produto.json', 'w') { |file| file.write(JSON.dump(output_json)) }

# Logs para fins de teste
# puts html.css('td')