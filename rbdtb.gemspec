Gem::Specification.new do |s|
  s.name        = 'rbdtb'
  s.version     = '1.0.0'
  s.date        = '2019-11-20'
  s.summary     = "rbdtb"
  s.description = "ruby plain device tree parser"
  s.authors     = ["Hake Huang"]
  s.email       = 'hakehuang@gmail.com'
  s.files       = ["lib/rbdtb.rb"]
  s.homepage    =
    'http://rubygems.org/gems/rbdtb'
  s.license       = 'Apache-2.0'
  s.require_paths = ["lib"]
  s.add_development_dependency "awesome_print",  ["~> 1.8.0"]
  s.add_development_dependency "rly",  ["~> 0.2.3"]
  s.add_development_dependency "logger",  ["= 1.3.0"]
end