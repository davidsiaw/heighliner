# frozen_string_literal: true

module Heighliner
  module Cmds
    class Logs < Cli
      def usage
        <<~EOS
          Continuously monitors the application container's logs.

          USAGE: heighliner logs
        EOS
      end

      def execute(_opts)
        exec "docker logs -f #{app_container_name}"
      end
    end
  end
end
