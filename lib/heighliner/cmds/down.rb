# frozen_string_literal: true

module Heighliner
  module Cmds
    class Down < Cli
      def usage
        <<~EOS
          Stops and removes your app and database containers, and deletes the database volume. This does **not** affect the shared infrastructure (nginx, DNS, Chrome) — use \`heighliner shutdown\` for that.

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
