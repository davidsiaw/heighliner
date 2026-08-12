# frozen_string_literal: true

require 'heighliner/steerfile'

RSpec.describe Heighliner::Steerfile do
  # Defaults
  let(:steerfile_name) { 'Steerfile' }
  let(:dockerfile_name) { 'Dockerfile' }

  let(:steerfile) { '' }
  let(:dockerfile) { '' }

  before do
    allow(File).to receive(:exist?) { true }
    allow(File).to receive(:read).with(steerfile_name) { steerfile_contents }
    allow(File).to receive(:read).with(dockerfile_name) { dockerfile_contents }

    allow(Heighliner::Config).to receive(:steerfile) { Heighliner::Steerfile.new('Steerfile') }
  end

  context 'db platform set' do
    let(:steerfile_contents) { <<-STEERFILE }
        db 'postgres:alpine',
           platform: 'linux/amd64',
           data_dir: '/var/lib/postgresql/data',
           port: 5432

    STEERFILE

    it 'sets the platform' do
      cli = Heighliner::Cli.new
      expect(cli.send(:db_image)).to eq('--platform linux/amd64 postgres:alpine')
    end
  end

  context 'db platform not set' do
    let(:steerfile_contents) { <<-STEERFILE }
        db 'postgres:alpine',
           data_dir: '/var/lib/postgresql/data',
           port: 5432

    STEERFILE

    it 'ignores platform' do
      cli = Heighliner::Cli.new
      expect(cli.send(:db_image)).to eq('postgres:alpine')
    end
  end

  describe '#network_exists?' do
    it 'asks docker about a network, not a container' do
      # `docker inspect NAME` searches containers and misses networks, so an
      # existing network was reported absent and creation was attempted.
      cli = Heighliner::Cli.new
      allow(cli).to receive(:network_inspect_output).with('kaiser_net').and_return('[{"Name":"kaiser_net"}]')

      expect(cli.send(:network_exists?, 'kaiser_net')).to be true
    end

    it 'treats empty output as absent' do
      cli = Heighliner::Cli.new
      allow(cli).to receive(:network_inspect_output).and_return('')

      expect(cli.send(:network_exists?, 'kaiser_net')).to be false
    end

    it 'treats an empty json array as absent' do
      cli = Heighliner::Cli.new
      allow(cli).to receive(:network_inspect_output).and_return('[]')

      expect(cli.send(:network_exists?, 'kaiser_net')).to be false
    end

    it 'assumes present on unparseable output rather than ending the command' do
      cli = Heighliner::Cli.new
      allow(cli).to receive(:network_inspect_output).and_return("WARNING: something\n[]garbage")

      expect(cli.send(:network_exists?, 'kaiser_net')).to be true
    end
  end

  describe '#create_if_network_not_exist' do
    it 'does not create a network that already exists' do
      cli = Heighliner::Cli.new
      allow(cli).to receive(:network_exists?).with('kaiser_net').and_return(true)

      expect(Heighliner::CommandRunner).not_to receive(:run)
      cli.send(:create_if_network_not_exist, 'kaiser_net')
    end

    it 'creates a network that does not exist' do
      cli = Heighliner::Cli.new
      allow(cli).to receive(:network_exists?).with('kaiser_net').and_return(false, true)

      expect(Heighliner::CommandRunner).to receive(:run).with(anything, 'docker network create kaiser_net')
      cli.send(:create_if_network_not_exist, 'kaiser_net')
    end

    it 'tolerates a create that lost a race to another heighliner process' do
      cli = Heighliner::Cli.new
      allow(cli).to receive(:network_exists?).with('kaiser_net').and_return(false, true)
      allow(Heighliner::CommandRunner).to receive(:run).and_return(1)

      expect { cli.send(:create_if_network_not_exist, 'kaiser_net') }.not_to raise_error
    end

    it 'raises when the network is still missing after creating it' do
      cli = Heighliner::Cli.new
      allow(cli).to receive(:network_exists?).with('kaiser_net').and_return(false, false)
      allow(Heighliner::CommandRunner).to receive(:run).and_return(1)

      expect { cli.send(:create_if_network_not_exist, 'kaiser_net') }
        .to raise_error(Heighliner::Error, /could not create docker network kaiser_net/)
    end
  end

  describe '#selenium_node_image' do
    it 'for x86 machines returns normal selenium' do
      cli = Heighliner::Cli.new
      stub_const('RUBY_PLATFORM', 'x86_64-linux')
      expect(cli.send(:selenium_node_image)).to eq('selenium/standalone-chrome-debug')
    end

    it 'for arm machines on mac' do
      cli = Heighliner::Cli.new
      stub_const('RUBY_PLATFORM', 'arm64-darwin23')
      expect(cli.send(:selenium_node_image)).to eq('seleniarm/standalone-chromium')
    end

    it 'for arm machines on linux' do
      cli = Heighliner::Cli.new
      stub_const('RUBY_PLATFORM', 'aarch64-linux')
      expect(cli.send(:selenium_node_image)).to eq('seleniarm/standalone-chromium')
    end
  end
end
