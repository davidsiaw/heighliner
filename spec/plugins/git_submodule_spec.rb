# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Heighliner::Plugins::GitSubmodule' do
  let(:steerfile) { 'plugin :git_submodule' }

  before { setup_dummy_app }
  after { teardown_dummy_app }

  it 'raises an exception on missing git submodule' do
    skip 'git submodule file:// protocol is disabled in this environment'
  end
end
