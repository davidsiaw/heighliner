# frozen_string_literal: true

module Heighliner
  module Cmds
    # The long-form help text printed by `heighliner set help-https` and by
    # `heighliner set cert-1password` with no arguments. It lives here rather
    # than in Set so that the command itself stays readable.
    module SetHelp
      private

      def help_https
        <<~SET_HELP
          Notes on HTTPS:

          You need to set suffix and one of cert-url, cert-folder or cert-1password to enable HTTPS.

          They are mutually exclusive. If you set one of them the others will be erased.

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

          For certificates kept in 1Password, see: heighliner set cert-1password
        SET_HELP
      end

      def help_1password
        <<~SET_HELP
          Notes on 1Password certificates:

          You need to set suffix and cert-1password to enable HTTPS with 1Password.

          The cert-1password value should be in the format 'Vault/Item'.

          By default, the field names in the 1Password item should match the file extensions:
            - key       → <suffix>.key
            - crt       → <suffix>.crt
            - chain.pem → <suffix>.chain.pem

          If your item names them differently, set them one at a time:
            heighliner set cert-1password-field key privkey
            heighliner set cert-1password-field crt fullchain
            heighliner set cert-1password-field chain.pem ca-bundle

          Example:
            heighliner set cert-1password Vault/Dev-Certs
            heighliner set http-suffix local.mydomain.com

          This will read:
            op read "op://Vault/Dev-Certs/key"       → local.mydomain.com.key
            op read "op://Vault/Dev-Certs/crt"       → local.mydomain.com.crt
            op read "op://Vault/Dev-Certs/chain.pem" → local.mydomain.com.chain.pem

          Make sure the `op` CLI is installed and authenticated on your machine.
        SET_HELP
      end
    end
  end
end
