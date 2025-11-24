# frozen_string_literal: true

require "curses"
require "stringio"
require "rspec/core"

require "specbug/runner"
require "specbug/ui"

module Specbug
  # Coordinates the UI and runner interactions for the Specbug TUI.
  class App
    def initialize(root: Dir.pwd)
      @root = root
      @runner = Runner.new(root: root)
      @ui = UI.new
      @status_message = "Press Enter to run the highlighted spec"
    end

    def run
      specs = @runner.discover_specs
      selection = 0

      @ui.start do
        loop do
          @ui.render(specs: specs, selection: selection, status: @status_message)

          key = @ui.read_key
          break if key == :quit

          case key
          when :up
            selection = (selection - 1) % [specs.length, 1].max
          when :down
            selection = (selection + 1) % [specs.length, 1].max
          when :run
            result = run_single_spec(specs, selection)
            @status_message = format_status(result)
          end
        end
      end
    ensure
      @ui.close
    end

    private

    def run_single_spec(specs, selection)
      return nil if specs.empty?

      @status_message = "Running #{specs[selection]}..."
      @ui.render(specs: specs, selection: selection, status: @status_message)

      @runner.run_spec(specs[selection])
    end

    def format_status(result)
      return "No specs found in #{@root}/spec" if result.nil?

      if result[:status] == :passed
        "✅ #{result[:path]} passed"
      else
        "❌ #{result[:path]} failed (exit #{result[:exit_code]})"
      end
    end
  end
end
