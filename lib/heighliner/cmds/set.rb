# frozen_string_literal: true

require 'json'

module Heighliner
  module Cmds
    class Set < Cli
      def usage
        <<~EOS
          This command lets you set up special variables that configure heighliner's behavior for you.

          Available subcommands:

          http-suffix          - Sets the domain suffix for the reverse proxy to use (defaults to lvh.me)
          cert-url             - Sets up a URL from which HTTPS certificates can be downloaded.
          cert-folder          - Sets up a folder from which HTTPS certificates can be copied.
          cert-1password       - Sets up a 1Password item from which HTTPS certificates can be downloaded.
          cert-1password-fields - Sets custom 1Password field names (JSON object)
          help-https           - Shows the HTTPS notes.

          USAGE: heighliner set cert-url
                 heighliner set cert-folder
                 heighliner set cert-1password
                 heighliner set cert-1password-fields
                 heighliner set http-suffix
                 heighliner set help-https
        EOS
      end

      def initialize
        super
        @use_steerfile = false
      end

      def execute(_opts)
        cmd = ARGV.shift

        case cmd
        when 'cert-url'
          Config.config[:cert_source] = { url: ARGV.shift }
        when 'cert-folder'
          Config.config[:cert_source] = { folder: ARGV.shift }
        when 'cert-1password'
          handle_cert_1password
        when 'cert-1password-fields'
          Config.config[:cert_source]['1password-fields'] = JSON.parse(ARGV.shift)
        when 'http-suffix'
          Config.config[:http_suffix] = ARGV.shift
        when 'help-https'
          puts help_https
        else
          Optimist.die "Unknown subcommand: '#{cmd}'"
        end

        save_config
      end

      private

      def handle_cert_1password
        if ARGV.empty?
          puts help_1password
        else
          Config.config[:cert_source] = { '1password': ARGV.shift }
        end
      end

      def help_https
        <<~SET_HELP
          Notes on HTTPS:

          You need to set suffix and either cert-url or cert-folder to enable HTTPS.

          cert-url and cert-folder are mutually exclusive. If you set one of them the other will be erased.

          The cert-url and cert-folder must satisfy the following requirements to work:

          The strings must be the root of certificates named after the suffix. For example,

            if cert-url is https://mydomain.com/certs and your suffix is local.mydomain.com, the following
            url need to be the certificate files:

            https://mydomain.com/certs/local.mydomain.com.chain.pem
            https://mydomain.com/certs/local.mydomain.com.crt
            https://mydomain.com/certs/local.mydomain.com.key

          Another example:

            If you use suffix of localme.com and cert-folder is /home/me/https, The following files need to exist:

            /home/me/https/localme.com.chain.pem
            /home/me/https/localme.com.crt
            /home/me/https/localme.com.key
        SET_HELP
      end

      def help_1password
        <<~SET_HELP
          Notes on 1Password certificates:

          You need to set suffix and cert-1password to enable HTTPS with 1Password.

          The cert-1password value should be in the format 'Vault/Item'.

          By default, the field names in the 1Password item should match the file extensions:
            - key   → <suffix>.key
            - crt   → <suffix>.crt
            - chain → <suffix>.chain.pem

          You can customize field names with:
            heighliner set cert-1password-fields '{"key":"private-key","crt":"certificate","chain":"ca-bundle"}'

          Example:
            heighliner set cert-1password Vault/Dev-Certs
            heighliner set http-suffix local.mydomain.com

          This will read:
            op read "op://Vault/Dev-Certs/key"   → local.mydomain.com.key
            op read "op://Vault/Dev-Certs/crt"   → local.mydomain.com.crt
            op read "op://Vault/Dev-Certs/chain" → local.mydomain.com.chain.pem

          Make sure the `op` CLI is installed and authenticated on your machine.
        SET_HELP
      end
    end
  end
end
