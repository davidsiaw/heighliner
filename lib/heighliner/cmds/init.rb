# frozen_string_literal: true

module Heighliner
  module Cmds
    class Init < Cli
      def usage
        <<~EOS
          Initializes a Heighliner environment and assigns ports for it in \`~/.heighliner/config.yml\`. When running \`heighliner up\` later the directory \`~/.heighliner/databases/<ENV_NAME>\` will get created.

          If the current directory is already initialized, you will get an error telling you the existing environment name.

          USAGE: heighliner init ENV_NAME
        EOS
      end

      def execute(_opts)
        return Optimist.die "Already initialized as #{envname}. Use 'heighliner deinit' to remove this environment first." if envname

        name = ARGV.shift
        return Optimist.die 'Needs environment name' if name.nil?

        init_config_for_env(name)
        save_config
      end

      def init_config_for_env(name)
        Config.config[:envnames][Config.work_dir] = name
        Config.config[:envs][name] = {
          app_port: (largest_port + 1).to_s,
          db_port: (largest_port + 2).to_s
        }
        Config.config[:largest_port] = Config.config[:largest_port] + 2
      end

      def largest_port
        Config.config[:largest_port]
      end
    end
  end
end
