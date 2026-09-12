# frozen_string_literal: true

RSpec.describe Heighliner::Cmds::Set do
  subject(:cmd) { described_class.new }

  let(:config) { {} }

  before do
    allow(Heighliner::Config).to receive(:config).and_return(config)
    allow(cmd).to receive(:save_config)
  end

  def run(*args)
    stub_const('ARGV', args)
    cmd.execute({})
  end

  describe 'cert-1password-field' do
    it 'sets a field name from two plain words' do
      run('cert-1password-field', 'key', 'privkey')

      expect(config[:cert_source]['1password-fields']).to eq('key' => 'privkey')
    end

    it 'keeps fields set by earlier calls' do
      run('cert-1password-field', 'key', 'privkey')
      run('cert-1password-field', 'chain.pem', 'ca-bundle')

      expect(config[:cert_source]['1password-fields']).to eq(
        'key' => 'privkey',
        'chain.pem' => 'ca-bundle'
      )
    end

    it 'keeps the 1password item that was already set' do
      run('cert-1password', 'Vault/Item')
      run('cert-1password-field', 'crt', 'fullchain')

      expect(config[:cert_source][:'1password']).to eq('Vault/Item')
      expect(config[:cert_source]['1password-fields']).to eq('crt' => 'fullchain')
    end

    # Field names come from the certificate file extensions, so `chain` is a
    # typo for `chain.pem` and used to be silently ignored at `up` time.
    it 'rejects a field name that is not a certificate file' do
      expect(Optimist).to receive(:die).with(/Unknown certificate field: 'chain'/)

      run('cert-1password-field', 'chain', 'ca-bundle')
    end

    it 'rejects a missing value' do
      expect(Optimist).to receive(:die).with(/No value given for field 'key'/)

      run('cert-1password-field', 'key')
    end
  end

  describe 'cert-1password-fields' do
    it 'still accepts a JSON object' do
      run('cert-1password-fields', '{"key":"privkey","crt":"fullchain"}')

      expect(config[:cert_source]['1password-fields']).to eq(
        'key' => 'privkey',
        'crt' => 'fullchain'
      )
    end

    # Used to raise NoMethodError on nil when no cert source was set yet.
    it 'works before a certificate source is set' do
      expect { run('cert-1password-fields', '{"key":"privkey"}') }.not_to raise_error

      expect(config[:cert_source]['1password-fields']).to eq('key' => 'privkey')
    end

    # This is what a shell that ate the quotes produces.
    it 'explains itself when the quotes were stripped' do
      expect(Optimist).to receive(:die).with(/shell may have eaten the quotes/)

      run('cert-1password-fields', '{key:privkey,crt:fullchain}')
    end

    it 'rejects unknown field names' do
      expect(Optimist).to receive(:die).with(/Unknown certificate fields: chain/)

      run('cert-1password-fields', '{"chain":"ca-bundle"}')
    end
  end

  describe 'other subcommands' do
    it 'sets the http suffix' do
      run('http-suffix', 'local.aweso.me')

      expect(config[:http_suffix]).to eq('local.aweso.me')
    end

    it 'replaces a 1password source when a url is set' do
      run('cert-1password', 'Vault/Item')
      run('cert-url', 'https://example.com/certs')

      expect(config[:cert_source]).to eq(url: 'https://example.com/certs')
    end

    it 'dies on an unknown subcommand' do
      expect(Optimist).to receive(:die).with(/Unknown subcommand: 'nope'/)

      run('nope')
    end
  end
end
