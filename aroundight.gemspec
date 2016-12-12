# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aroundight/version'

Gem::Specification.new do |spec|
  spec.name          = "aroundight"
  spec.version       = Aroundight::VERSION
  spec.authors       = ["geane99"]
  spec.email         = ["geane75@gmail.com"]

  spec.summary       = ""
  spec.description   = ""#"�Ð��f�[�^�̂����A�c�\�I�i�ʏ�E�V�[�h�j�A�l�i1000,3000�j�A�u�b�N���[�J�[�̃f�[�^�����W���邽�߂̋@�\".scrub(?)
  spec.homepage      = "https://github.com/geane99/aroundight"
  spec.license       = "Apache License 2.0"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'https://github.com/geane99/aroungiht'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
