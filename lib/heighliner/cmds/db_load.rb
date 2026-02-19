# frozen_string_literal: true

module Heighliner
  module Cmds
    class DbLoad < Cli
      def usage
        <<~EOS
          Shuts down the database docker container, *replaces* the database with the backup provided and brings the container up again.

          The database will be restored from a tarball saved as \`~/.heighliner/<ENV_NAME>/<current_github_branch_name>/<DB_BACKUP_FILENAME>.tar.bz\`

          Alternatively you can also load it from your current directory.

          If no database name was provided, the default database stored at \`~/.heighliner/<ENV_NAME>/<current_github_branch_name>/default.tar.bz\` will be used.

          USAGE: heighliner db_load
                 heighliner db_load DB_BACKUP_FILENAME
                 heighliner db_load ./my_database.tar.bz
        EOS
      end

      def execute(_opts)
        ensure_setup
        name = ARGV.shift || 'default'
        load_db(name)
      end
    end
  end
end
