# frozen_string_literal: true

module Heighliner
  module Cmds
    class Deinit < Cli
      def usage
        <<~EOS
          Removes the Heighliner environment from \`~/.heighliner/.config.yml\`. This however does not delete the \`~/.heighliner/databases/<ENV_NAME>\` directory.

          USAGE: heighliner init ENV_NAME
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
