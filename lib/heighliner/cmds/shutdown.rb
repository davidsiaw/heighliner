# frozen_string_literal: true

module Heighliner
  module Cmds
    class Shutdown < Cli
      def usage
        <<~EOS
          Shuts down the shared infrastructure containers used by Heighliner (nginx reverse proxy, DNS resolver, and Selenium Chrome). This does **not** stop your app or database containers — use \`heighliner down\` for that.

          NOTE: This command is destructive — it removes the shared Docker network and certs volume, which will affect all Heighliner environments on this machine.

          USAGE: heighliner shutdown
        EOS
      end

      def initialize
        super
        @use_steerfile = false
      end

      def execute(_opts)
        Config.load(Dir.pwd, use_steerfile: false)

        shared_names = Config.config[:shared_names] || {}
        networkname = Config.config[:networkname] || 'heighliner_net'

        shared_names.each_value do |container_name|
          killrm container_name
        end

        CommandRunner.run Config.out, "docker network rm #{networkname}"
        CommandRunner.run Config.out, "docker volume rm #{shared_names[:certs]}"
      end
    end
  end
end
