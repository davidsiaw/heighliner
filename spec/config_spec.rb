# frozen_string_literal: true

require 'tmpdir'

RSpec.describe Heighliner::Config do
  describe '.detect_config_dir' do
    def with_home_containing(*dirs)
      Dir.mktmpdir do |home|
        dirs.each { |d| FileUtils.mkdir_p "#{home}/#{d}" }
        allow(described_class).to receive(:home_dir).and_return(home)
        yield home
      end
    end

    it 'uses ~/.heighliner when nothing exists' do
      with_home_containing do |home|
        expect(described_class.detect_config_dir).to eq "#{home}/.heighliner"
      end
    end

    it 'uses ~/.kaiser when only the old kaiser directory exists' do
      with_home_containing('.kaiser') do |home|
        expect(described_class.detect_config_dir).to eq "#{home}/.kaiser"
      end
    end

    it 'prefers ~/.heighliner when both exist' do
      with_home_containing('.kaiser', '.heighliner') do |home|
        expect(described_class.detect_config_dir).to eq "#{home}/.heighliner"
      end
    end
  end

  describe '.detect_steerfile_name' do
    def with_files(*files)
      allow(File).to receive(:exist?) { |name| files.include?(name) }
    end

    it 'finds a Steerfile' do
      with_files('Steerfile')

      expect(described_class.detect_steerfile_name).to eq 'Steerfile'
    end

    it 'finds a legacy Kaiserfile' do
      with_files('Kaiserfile')

      expect(described_class.detect_steerfile_name).to eq 'Kaiserfile'
    end

    it 'prefers a Steerfile over a Kaiserfile' do
      with_files('Kaiserfile', 'Steerfile')

      expect(described_class.detect_steerfile_name).to eq 'Steerfile'
    end

    it 'prefers heighliner.config over a Kaiserfile' do
      with_files('Kaiserfile', 'heighliner.config')

      expect(described_class.detect_steerfile_name).to eq 'heighliner.config'
    end

    it 'is nil when no steerfile exists' do
      with_files

      expect(described_class.detect_steerfile_name).to be_nil
    end
  end
end
