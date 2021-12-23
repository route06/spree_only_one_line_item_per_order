# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_only_one_line_item_per_order/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_only_one_line_item_per_order'
  s.version     = SpreeOnlyOneLineItemPerOrder.version
  s.summary     = 'It is a Spree extension that realizes "one type and one item can be added to an order"'
  s.description = ''
  s.required_ruby_version = '>= 2.5'

  s.author    = 'ROUTE06'
  s.email     = 'development+rubygems@route06.co.jp'
  s.homepage  = 'https://github.com/route06/spree_only_one_line_item_per_order'
  s.license   = 'BSD-3-Clause'

  s.files       = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(/^spec\/fixtures/) }
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree', '>= 4.3.0'
  s.add_dependency 'spree_extension'

  s.add_development_dependency 'actionmailer' # needed for running rspec
  s.add_development_dependency 'spree_dev_tools'
end
