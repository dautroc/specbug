# frozen_string_literal: true

require "curses"

module Specbug
  # Lightweight curses UI for navigating and running specs.
  class UI
    def start
      setup_screen
      yield if block_given?
    end

    def read_key
      case @window.getch
      when Curses::Key::UP
        :up
      when Curses::Key::DOWN
        :down
      when 10, 13
        :run
      when "q"
        :quit
      else
        nil
      end
    end

    def render(specs:, selection:, status: "")
      @window.clear
      @window.setpos(0, 0)
      @window.addstr("Specbug — Select a spec and press Enter to run (q to quit)\n")
      @window.addstr("Status: #{status}\n\n")

      if specs.empty?
        @window.addstr("No specs found in spec/\n")
      else
        specs.each_with_index do |spec, index|
          pointer = index == selection ? "➤" : " "
          @window.addstr("#{pointer} #{spec}\n")
        end
      end

      @window.refresh
    end

    def close
      return unless @window

      Curses.close_screen
      @window = nil
    end

    private

    def setup_screen
      Curses.init_screen
      Curses.cbreak
      Curses.noecho
      Curses.stdscr.keypad(true)
      @window = Curses.stdscr
    end
  end
end
