# frozen_string_literal: true

module Heighliner
  module CliOptions
    def option(*option)
      @options ||= []
      @options << option
    end

    def options
      @options || []
    end
  end
end
