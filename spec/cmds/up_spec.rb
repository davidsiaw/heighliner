# frozen_string_literal: true

RSpec.describe Heighliner::Cmds::Up do
  describe 'cmd' do
    it 'generates correctly' do
      steerfile = double(Heighliner::Steerfile)
      heighlinerconfig = double(Heighliner::Config)

      allow(Heighliner::Config).to receive(:steerfile).and_return(steerfile)
      allow(Heighliner::Config).to receive(:config).and_return(heighlinerconfig)

      allow(Heighliner::Config).to receive(:work_dir).and_return('somedir')

      envs = double('Hash')
      allow(envs).to receive(:[]).with('somedir').and_return('meow')

      allow(Heighliner::Config.steerfile).to receive(:docker_build_args).and_return({})
      allow(Heighliner::Config.config).to receive(:[]).with(:envnames).and_return(envs)

      obj = described_class.new
      allow(obj).to receive(:current_branch).and_return('master')

      allow(steerfile).to receive(:platform).and_return('')

      expect(obj.build_cmd[0]).to eq 'docker build'
      expect(obj.build_cmd[1]).to eq '-t heighliner:meow-master'
      expect(obj.build_cmd[2]).to eq '-f /meow-dockerfile somedir'
      expect(obj.build_cmd[3].to_s).to eq ''
    end

    it 'generates the appropriate build platform' do
      steerfile = double(Heighliner::Steerfile)
      heighlinerconfig = double(Heighliner::Config)

      allow(Heighliner::Config).to receive(:steerfile).and_return(steerfile)
      allow(Heighliner::Config).to receive(:config).and_return(heighlinerconfig)

      allow(Heighliner::Config).to receive(:work_dir).and_return('somedir')

      envs = double('Hash')
      allow(envs).to receive(:[]).with('somedir').and_return('meow')

      allow(steerfile).to receive(:platform).and_return('linux/catcpu')

      allow(Heighliner::Config.steerfile).to receive(:docker_build_args).and_return({})
      allow(Heighliner::Config.config).to receive(:[]).with(:envnames).and_return(envs)

      obj = described_class.new
      allow(obj).to receive(:current_branch).and_return('master')

      allow(steerfile).to receive(:platform).and_return('linux/catcpu')

      expect(obj.build_cmd[0]).to eq 'docker build'
      expect(obj.build_cmd[1]).to eq '-t heighliner:meow-master'
      expect(obj.build_cmd[2]).to eq '-f /meow-dockerfile somedir'
      expect(obj.build_cmd[3]).to eq '--platform=linux/catcpu'
    end
  end
end
