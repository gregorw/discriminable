# frozen_string_literal: true

require_relative "lib/discriminable/version"

Gem::Specification.new do |spec|
  spec.name = "discriminable"
  spec.version = Discriminable::VERSION
  spec.authors = ["Gregor Wassmann"]
  spec.email = ["gregor.wassmann@gmail.com"]

  spec.summary = "Discriminable Rails Models"
  spec.description = "Single Table Inheritencs (STI) like functionality using _any_ column, like e.g. enums, etc."
  spec.homepage = "https://github.com/gregorw/discrimainable"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # rubocop:disable Gemspec/RequireMFA
  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "changelog_uri" => "#{spec.homepage}/CHANGELOG.md",
    "rubygems_mfa_required" => "false"
  }
  # rubocop:enable Gemspec/RequireMFA

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activerecord", ">= 6.0"

  spec.add_development_dependency "appraisal", "~> 2.4"
  spec.add_development_dependency "byebug", "~> 11.1"
  spec.add_development_dependency "minitest", "~> 5.15"
  spec.add_development_dependency "rubocop", "~> 1.26"
  spec.add_development_dependency "simplecov", "~> 0.21"
  spec.add_development_dependency "sqlite3", "~> 1.4"
end
