# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Heighliner::Plugins::Database' do
  before do
    # stub out call that isnt supposed to be there anyway
    require 'optimist'
    allow(Optimist).to receive(:die)
  end

  let(:dockerfile_name) { 'Dockerfile.heighliner' }
  let(:steerfile_name) { 'Steerfile' }
  let(:dockerfile) { 'FROM ruby:alpine' }
  let(:steerfile) { <<~STEERFILE }
    plugin :database
    dockerfile "Dockerfile.heighliner"
  STEERFILE

  before do
    allow(File).to receive(:exist?) { true }
    allow(File).to receive(:read).with(steerfile_name) { steerfile }
    allow(File).to receive(:read).with(dockerfile_name) { dockerfile }
  end

  it 'throws an exception if nonexistent driver' do
    steerfile = Heighliner::Steerfile.new('Steerfile')

    expect { steerfile.def_db :nobase }.to raise_error "Unknown database 'nobase'"
  end

  context 'given a driver' do
    let(:db_class) { Class.new }
    let(:db_driver) { instance_double('Heighliner::Databases::Somebase') }

    before do
      stub_const('Heighliner::Databases::Somebase', db_class)
    end

    it 'accepts a symbol and loads the appropriate driver' do
      steerfile = Heighliner::Steerfile.new('Steerfile')
      allow(steerfile).to receive(:require).with('heighliner/databases/somebase') { true }

      expect(db_class).to receive(:new) { db_driver }
      expect(db_driver).to receive(:options_hash) { { port: 1234 } }
      expect(db_driver).to receive(:image_name) { '' }
      expect(steerfile).to receive(:db).with('', port: 1234)

      steerfile.def_db :somebase
    end

    it 'accepts a hash and loads the appropriate driver' do
      steerfile = Heighliner::Steerfile.new('Steerfile')
      allow(steerfile).to receive(:require).with('heighliner/databases/somebase') { true }

      expect(db_class).to receive(:new) { db_driver }.with({ hello: :meow })
      expect(db_driver).to receive(:options_hash) { { port: 1234 } }
      expect(db_driver).to receive(:image_name) { '' }
      expect(steerfile).to receive(:db).with('', port: 1234)

      steerfile.def_db somebase: { hello: :meow }
    end
  end
end
