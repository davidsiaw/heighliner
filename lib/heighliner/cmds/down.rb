# frozen_string_literal: true

module Heighliner
  module Cmds
    class Down < Cli
      def usage
        <<~EOS
          Shuts down and *deletes* the containers that were started using \`heighliner up\`.

          USAGE: heighliner down
        EOS
      end

      def execute(_opts)
        stop_db
        stop_app
        delete_db_volume
      end
    end
  end
end
