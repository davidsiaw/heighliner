# frozen_string_literal: true

module Heighliner
  class Config
    class << self
      attr_accessor :out,
                    :info_out

      attr_reader :work_dir,
                  :config_dir,
                  :config_file,
                  :steerfile,
                  :config

      def load(work_dir, use_steerfile: true)
        @work_dir = work_dir
        @config_dir = "#{ENV['HOME']}/.heighliner"

        migrate_dotted_config_files

        FileUtils.mkdir_p @config_dir
        @config_file = "#{@config_dir}/config.yml"

        @config = {
          envnames: {},
          envs: {},
          networkname: 'heighliner_net',
          shared_names: {
            redis: 'heighliner-redis',
            nginx: 'heighliner-nginx',
            chrome: 'heighliner-chrome',
            dns: 'heighliner-dns',
            certs: 'heighliner-certs'
          },
          largest_port: 9000,
          always_verbose: false
        }

        load_config

        if use_steerfile
          @steerfile = Steerfile.new("#{@work_dir}/Steerfile")
          alt_steerfile = "#{ENV['HOME']}/steerfiles/Steerfile.#{@config[:envnames][work_dir]}"
          @steerfile = Steerfile.new(alt_steerfile) if File.exist?(alt_steerfile)
        end

        @config
      end

      def always_verbose?
        @config[:always_verbose]
      end

      # Up until version 0.5.1, heighliner used dotfiles for all of it configuration.
      # It makes sense of hide the configuration directory itself but hiding the files
      # inside of it just causes confusion.
      #
      # Heighliner 0.5.2 started using non-dotted files instead. This method renames the old
      # files in case you have just upgraded from an older version.
      def migrate_dotted_config_files
        return unless File.exist?("#{@config_dir}/.config.yml")

        Dir["#{@config_dir}/**/.*"].each do |x|
          dest = x.sub(%r{/\.([a-z.]+)$}, '/\1')
          FileUtils.mv x, dest
        end
      end

      def load_config
        loaded = YAML.load_file(@config_file) if File.exist?(@config_file)

        config_shared_names = @config[:shared_names] if @config
        loaded_shared_names = loaded[:shared_names] if loaded

        @config = {
          **(@config || {}),
          **(loaded || {}),
          shared_names: { **(config_shared_names || {}), **(loaded_shared_names || {}) }
        }
      end
    end
  end
end
