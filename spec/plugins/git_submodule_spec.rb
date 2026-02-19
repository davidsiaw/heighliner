# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Heighliner::Plugins::GitSubmodule' do
  let(:steerfile) { 'plugin :git_submodule' }

  before { setup_dummy_app }
  after { teardown_dummy_app }

  it 'raises an exception on missing git submodule' do
    create_file 'Steerfile', steerfile

    system <<-GIT_SETUP
    cd #{dummy_app}
    git init --quiet
    git submodule --quiet add https://github.com/davidsiaw/heighliner.git
    rm -rf heighliner
    GIT_SETUP

    expect(run_cmd('heighliner up -v'))
      .to include("Found uninitialized git submodule 'heighliner'")
  end
end
