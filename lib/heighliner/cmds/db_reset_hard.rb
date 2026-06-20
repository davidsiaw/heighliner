# frozen_string_literal: true

module Heighliner
  module Cmds
    class DbResetHard < Cli
      def usage
        <<~EOS
          Shuts down the database docker container, deletes the default database image stored at \`~/.heighliner/<ENV_NAME>/<current_github_branch_name>/default.tar.bz\`, rebuilds the docker volume if needed and the default database image from scratch and then brings the container up again.

          USAGE: heighliner db_reset_hard
        EOS
      end

      def execute(_opts)
        ensure_setup
        FileUtils.rm db_image_path('default') if File.exist?(db_image_path('default'))
        setup_db
      end
    end
  end
end
