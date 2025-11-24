# frozen_string_literal: true

require "rspec/core"
require "stringio"

module Specbug
  # Handles discovery and execution of specs.
  class Runner
    def initialize(root: Dir.pwd)
      @root = root
    end

    def discover_specs
      Dir.glob(File.join(@root, "spec/**/*_spec.rb")).sort
    end

    def run_spec(path)
      stdout = StringIO.new
      stderr = StringIO.new

      exit_code = RSpec::Core::Runner.run([path], stderr, stdout)

      {
        path: path,
        status: exit_code.zero? ? :passed : :failed,
        exit_code: exit_code,
        stdout: stdout.string,
        stderr: stderr.string
      }
    end
  end
end
