# frozen_string_literal: true

module Heighliner
  module Cmds
    class DbReset < Cli
      def usage
        <<~EOS
          Shuts down the database docker container, *replaces* the database with the default database image stored at \`~/.heighliner/<ENV_NAME>/<current_github_branch_name>/default.tar.bz\` and brings the container up again.

          This is the same as running \`heighliner db_load\` with no arguments.

          USAGE: heighliner db_reset
        EOS
      end

      def execute(_opts)
        ensure_setup
        load_db('default')
      end
    end
  end
end
