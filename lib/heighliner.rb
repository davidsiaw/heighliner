# frozen_string_literal: true

require 'heighliner/error'
require 'heighliner/version'
require 'heighliner/steerfile'
require 'heighliner/cli_options'
require 'heighliner/cli'
require 'heighliner/after_dotter'
require 'heighliner/dotter'

require 'heighliner/config'

require 'heighliner/cmds/init'
require 'heighliner/cmds/deinit'
require 'heighliner/cmds/up'
require 'heighliner/cmds/down'
require 'heighliner/cmds/shutdown'
require 'heighliner/cmds/db_save'
require 'heighliner/cmds/db_load'
require 'heighliner/cmds/db_reset'
require 'heighliner/cmds/db_reset_hard'
require 'heighliner/cmds/logs'
require 'heighliner/cmds/attach'
require 'heighliner/cmds/login'
require 'heighliner/cmds/show'
require 'heighliner/cmds/set'
require 'heighliner/cmds/root'

require 'heighliner/plugin'

require 'heighliner/service'

# Heighliner
module Heighliner
  SUB_COMMANDS = {
    init: Heighliner::Cmds::Init,
    deinit: Heighliner::Cmds::Deinit,
    up: Heighliner::Cmds::Up,
    down: Heighliner::Cmds::Down,
    shutdown: Heighliner::Cmds::Shutdown,
    db_save: Heighliner::Cmds::DbSave,
    db_load: Heighliner::Cmds::DbLoad,
    db_reset: Heighliner::Cmds::DbReset,
    db_reset_hard: Heighliner::Cmds::DbResetHard,
    logs: Heighliner::Cmds::Logs,
    attach: Heighliner::Cmds::Attach,
    login: Heighliner::Cmds::Login,
    show: Heighliner::Cmds::Show,
    set: Heighliner::Cmds::Set,
    root: Heighliner::Cmds::Root
  }.freeze
end
