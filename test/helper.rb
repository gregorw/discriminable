# frozen_string_literal: true

require "simplecov"
require "simplecov_json_formatter"
SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter if ENV.fetch("CC_TEST_REPORTER_ID", false)
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "discriminable"

require "minitest/autorun"
require "active_record"
require "byebug"

require_relative "./case"

ActiveRecord::Migration.verbose = false # Silence migrations
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new($stdout) if ENV.fetch("LOG", false)
