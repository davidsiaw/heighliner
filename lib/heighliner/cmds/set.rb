# frozen_string_literal: true

require 'json'
require 'heighliner/cmds/set_help'

module Heighliner
  module Cmds
    class Set < Cli
      include SetHelp

      def usage
        <<~EOS
          This command lets you set up special variables that configure heighliner's behavior for you.

          Available subcommands:

          http-suffix          - Sets the domain suffix for the reverse proxy to use (defaults to lvh.me)
          cert-url             - Sets up a URL from which HTTPS certificates can be downloaded.
          cert-folder          - Sets up a folder from which HTTPS certificates can be copied.
          cert-1password       - Sets up a 1Password item from which HTTPS certificates can be downloaded.
          cert-1password-field - Sets one custom 1Password field name, e.g. `key privkey`
          cert-1password-fields - Sets custom 1Password field names all at once (JSON object).
                                  Prefer cert-1password-field: JSON needs shell quoting.
          help-https           - Shows the HTTPS notes.

          USAGE: heighliner set cert-url
                 heighliner set cert-folder
                 heighliner set cert-1password
                 heighliner set cert-1password-field key privkey
                 heighliner set cert-1password-fields
                 heighliner set http-suffix
                 heighliner set help-https
        EOS
      end

      def initialize
        super
        @use_steerfile = false
      end

      HANDLERS = {
        'cert-url' => :handle_cert_url,
        'cert-folder' => :handle_cert_folder,
        'cert-1password' => :handle_cert_1password,
        'cert-1password-field' => :handle_cert_1password_field,
        'cert-1password-fields' => :handle_cert_1password_fields,
        'http-suffix' => :handle_http_suffix,
        'help-https' => :handle_help_https
      }.freeze

      def execute(_opts)
        cmd = ARGV.shift
        handler = HANDLERS[cmd]

        return Optimist.die "Unknown subcommand: '#{cmd}'" unless handler

        send(handler)

        save_config
      end

      private

      def handle_cert_url
        Config.config[:cert_source] = { url: ARGV.shift }
      end

      def handle_cert_folder
        Config.config[:cert_source] = { folder: ARGV.shift }
      end

      def handle_http_suffix
        Config.config[:http_suffix] = ARGV.shift
      end

      def handle_help_https
        puts help_https
      end

      def handle_cert_1password
        if ARGV.empty?
          puts help_1password
        else
          Config.config[:cert_source] = { '1password': ARGV.shift }
        end
      end

      # Sets a single field name as two plain words, so there is nothing for a
      # shell to mangle:
      #   heighliner set cert-1password-field key privkey
      def handle_cert_1password_field
        name = ARGV.shift
        value = ARGV.shift

        unless Cli::CERT_FILE_EXTS.include?(name)
          return Optimist.die "Unknown certificate field: '#{name}'. " \
                              "Valid fields are: #{Cli::CERT_FILE_EXTS.join(', ')}"
        end

        return Optimist.die "No value given for field '#{name}'" if value.blank?

        cert_1password_fields[name] = value
      end

      # Accepts every field at once as JSON. Kept for configs and scripts that
      # already use it; cert-1password-field avoids the shell quoting entirely.
      def handle_cert_1password_fields
        json = ARGV.shift
        return Optimist.die 'No JSON object given' if json.blank?

        fields = begin
          JSON.parse(json)
        rescue JSON::ParserError => e
          return Optimist.die "Could not parse JSON: #{e.message}. " \
                              'Your shell may have eaten the quotes. Try: ' \
                              'heighliner set cert-1password-field key privkey'
        end

        unknown = fields.keys - Cli::CERT_FILE_EXTS
        return Optimist.die "Unknown certificate fields: #{unknown.join(', ')}" unless unknown.empty?

        cert_1password_fields.merge!(fields)
      end

      # Field names live inside the certificate source, which may not exist yet.
      def cert_1password_fields
        Config.config[:cert_source] ||= {}
        Config.config[:cert_source]['1password-fields'] ||= {}
      end
    end
  end
end
