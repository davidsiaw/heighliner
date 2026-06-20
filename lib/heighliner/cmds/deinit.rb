# frozen_string_literal: true

module Heighliner
  module Cmds
    class Deinit < Cli
      def usage
        <<~EOS
          Removes the Heighliner environment from \`~/.heighliner/config.yml\`. This also runs \`heighliner down\` to stop and delete your app containers and database volume. It does not delete the \`~/.heighliner/databases/<ENV_NAME>\` directory.

          USAGE: heighliner deinit
        EOS
      end

      def execute(_opts)
        down
        Config.config[:envs].delete(envname)
        Config.config[:envnames].delete(Config.work_dir)
        save_config
      end
    end
  end
end
