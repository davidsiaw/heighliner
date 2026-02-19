# frozen_string_literal: true

require 'heighliner/plugin'

RSpec.describe Heighliner::Plugin do
  it 'loads plugin classes correctly' do
    class Dummy101And202Test < Heighliner::Plugin; end
    class DummyTest101 < Heighliner::Plugin; end
    class Dummy < Heighliner::Plugin; end

    expect(Heighliner::Plugin.loaded?(:dummy_101_and_202_test)).to be_truthy
    expect(Heighliner::Plugin.loaded?(:dummy_test_101)).to be_truthy
    expect(Heighliner::Plugin.loaded?(:dummy)).to be_truthy
    expect(Heighliner::Plugin.loaded?(:not_a_plugin)).to be_falsey
  end
end
