# frozen_string_literal: true

require "simplecov"
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "discriminable"

require "minitest/autorun"
require "active_record"
require "byebug"
require "minitest/reporters"

require_relative "./case"

ActiveRecord::Migration.verbose = false # Silence migrations
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new($stdout) if ENV.fetch("LOG", false)

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]
