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
  end

  context '#dockerfile' do
    let(:dockerfile_name) { 'Dockerfile.heighliner' }
    let(:dockerfile_contents) { 'FROM ruby:alpine' }
    let(:steerfile_contents) { 'dockerfile "Dockerfile.heighliner"' }

    it 'loads the specified dockerfile' do
      steerfile = Heighliner::Steerfile.new('Steerfile')
      expect(steerfile.docker_file_contents).to match(/FROM ruby:alpine/)
    end
  end

  context '#attach_mount' do
    let(:steerfile_contents) { 'attach_mount "bin", "/app/bin"' }

    it 'records the required mount attachments' do
      steerfile = Heighliner::Steerfile.new('Steerfile')
      expect(steerfile.attach_mounts).to contain_exactly(['bin', '/app/bin'])
    end
  end

  context '#db' do
    context 'with no db script' do
      let(:steerfile_contents) { '' }

      it 'sets up the database variable to defaults' do
        steerfile = Heighliner::Steerfile.new('Steerfile')
        expect(steerfile.database[:image]).to eq 'none'
        expect(steerfile.database[:data_dir]).to eq '/tmp/data'
        expect(steerfile.database[:port]).to eq 1234
        expect(steerfile.database[:params]).to eq ''
        expect(steerfile.database[:commands]).to eq 'echo "no db"'
        expect(steerfile.database[:waitscript]).to eq 'echo "no dbwait"'
        expect(steerfile.database[:waitscript_params]).to eq ''
      end
    end

    context 'with a simple db script' do
      let(:steerfile_contents) { <<-STEERFILE }
        db 'somedb:version',
           data_dir: '/var/lib/somedb/data',
           port: 1234

      STEERFILE

      it 'sets up the database variable correctly' do
        steerfile = Heighliner::Steerfile.new('Steerfile')
        expect(steerfile.database[:image]).to eq 'somedb:version'
        expect(steerfile.database[:data_dir]).to eq '/var/lib/somedb/data'
        expect(steerfile.database[:port]).to eq 1234
      end
    end

    context 'with a simple db script with a startup command' do
      let(:steerfile_contents) { <<-STEERFILE }
        db 'somedb:version',
           data_dir: '/var/lib/dbdb',
           port: 1414,
           commands: 'start_db'
      STEERFILE

      it 'sets up the database variable with commands' do
        steerfile = Heighliner::Steerfile.new('Steerfile')
        expect(steerfile.database[:commands]).to eq 'start_db'
      end
    end

    context 'with a simple db script with a waitscript' do
      let(:steerfile_contents) { <<-STEERFILE }
        db 'somedb:version',
           data_dir: '/var/lib/dbdb',
           port: 1414,
           waitscript: 'sh wait_for_db.sh'
      STEERFILE

      it 'sets up the database variable with waitscript commands' do
        steerfile = Heighliner::Steerfile.new('Steerfile')
        expect(steerfile.database[:waitscript]).to eq 'sh wait_for_db.sh'
      end
    end

    context 'with a simple db script with a waitscript and parameters to the waitscript' do
      let(:steerfile_contents) { <<-STEERFILE }
        db 'somedb:version',
           data_dir: '/var/lib/dbdb',
           port: 1414,
           waitscript: 'sh wait_for_db.sh',
           waitscript_params: '-e PORT=1414'
      STEERFILE

      it 'sets up the database variable with waitscript command params' do
        steerfile = Heighliner::Steerfile.new('Steerfile')
        expect(steerfile.database[:waitscript_params]).to eq '-e PORT=1414'
      end
    end
  end

  context '#expose' do
    let(:steerfile_contents) { 'expose 1337' }

    it 'records the port used by the application' do
      steerfile = Heighliner::Steerfile.new('Steerfile')
      expect(steerfile.port).to eq 1337
    end
  end

  context '#app_params' do
    let(:steerfile_contents) { 'app_params "--user me"' }

    it 'records the parameters to the docker container' do
      steerfile = Heighliner::Steerfile.new('Steerfile')
      expect(steerfile.params).to match(/--user me/)
    end

    context 'with two calls to app_params' do
      let(:steerfile_contents) { <<~SCRIPT }
        app_params "-e SOMEPARAM=1"
        app_params "-e ANOTHERPARAM=2"
      SCRIPT

      it 'is additive' do
        steerfile = Heighliner::Steerfile.new('Steerfile')
        expect(steerfile.params).to match(/-e SOMEPARAM=1/)
        expect(steerfile.params).to match(/\s-e ANOTHERPARAM=2/)
      end
    end
  end

  context '#db_reset_command' do
    let(:steerfile_contents) { 'db_reset_command "explosion"' }

    it 'records the database reset command' do
      steerfile = Heighliner::Steerfile.new('Steerfile')
      expect(steerfile.database_reset_command).to eq 'explosion'
    end
  end

  context '#type' do
    context 'when http is specified' do
      let(:steerfile_contents) { 'type :http' }
      it 'sets server type to http' do
        steerfile = Heighliner::Steerfile.new('Steerfile')
        expect(steerfile.server_type).to eq :http
      end
    end

    context 'when anything else specified' do
      let(:steerfile_contents) { 'type :meow' }
      it 'throws an error' do
        expect do
          Heighliner::Steerfile.new('Steerfile')
        end.to raise_error 'Valid server types are: [:http]'
      end
    end
  end

  context '#force_platform' do
    context 'when force_platform is specified' do
      let(:steerfile_contents) { "force_platform 'catcpu'" }

      it 'sets platform' do
        steerfile = Heighliner::Steerfile.new('Steerfile')
        expect(steerfile.platform).to eq('catcpu')
      end
    end

    context 'when force_platform is not specified' do
      let(:steerfile_contents) { '' }

      it 'platform is nil' do
        steerfile = Heighliner::Steerfile.new('Steerfile')
        expect(steerfile.platform).to be_nil
      end
    end
  end

  context '#service' do
    context 'when service is specified' do
      let(:steerfile_contents) { "service 'santaclaus'" }

      it 'adds a service' do
        steerfile = Heighliner::Steerfile.new('Steerfile')
        expect(steerfile.services).to eq('santaclaus' => {
                                            image: 'santaclaus',
                                            command: nil,
                                            binds: {},
                                            env: {}
                                          })
      end
    end

    context 'when service is specified with image name' do
      let(:steerfile_contents) { "service 'santaclaus', image: 'northpole/santaclaus'" }

      it 'adds a service with the image name' do
        steerfile = Heighliner::Steerfile.new('Steerfile')
        expect(steerfile.services).to eq('santaclaus' => {
                                            image: 'northpole/santaclaus',
                                            command: nil,
                                            binds: {},
                                            env: {}
                                          })
      end
    end

    context 'when service is specified with image name and tag' do
      let(:steerfile_contents) { "service 'santaclaus', image: 'northpole/santaclaus:last_christmas'" }

      it 'adds a service with the image name' do
        steerfile = Heighliner::Steerfile.new('Steerfile')
        expect(steerfile.services).to eq('santaclaus' => {
                                            image: 'northpole/santaclaus:last_christmas',
                                            command: nil,
                                            binds: {},
                                            env: {}
                                          })
      end
    end
  end
end
