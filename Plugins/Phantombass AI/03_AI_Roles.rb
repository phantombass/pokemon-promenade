module GameData
  class Role
    attr_reader :id
    attr_reader :id_number
    attr_reader :real_name

    DATA = {}

    extend ClassMethods
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id           = hash[:id]
      @id_number    = hash[:id_number]    || -1
      @real_name    = hash[:name]         || "Unnamed"
    end

    # @return [String] the translated name of this Role
    def name
      return _INTL(@real_name)
    end
  end
end

GameData::Role.register({
  :id           => :PHYSICALWALL,
  :id_number    => 0,
  :name         => _INTL("Physical Wall")
})

GameData::Role.register({
  :id           => :SPECIALWALL,
  :id_number    => 1,
  :name         => _INTL("Special Wall")
})

GameData::Role.register({
  :id           => :STALLBREAKER,
  :id_number    => 2,
  :name         => _INTL("Stallbreaker")
})

GameData::Role.register({
  :id           => :PHYSICALBREAKER,
  :id_number    => 3,
  :name         => _INTL("Physical Breaker")
})

GameData::Role.register({
  :id           => :SPECIALBREAKER,
  :id_number    => 4,
  :name         => _INTL("Special Breaker")
})

GameData::Role.register({
  :id           => :SUICIDELEAD,
  :id_number    => 5,
  :name         => _INTL("Suicide Lead")
})

GameData::Role.register({
  :id           => :HAZARDLEAD,
  :id_number    => 6,
  :name         => _INTL("Hazard Lead")
})

GameData::Role.register({
  :id           => :CLERIC,
  :id_number    => 7,
  :name         => _INTL("Cleric")
})

GameData::Role.register({
  :id           => :REVENGEKILLER,
  :id_number    => 8,
  :name         => _INTL("Revenge Killer")
})

GameData::Role.register({
  :id           => :WINCON,
  :id_number    => 9,
  :name         => _INTL("Win Condition")
})

GameData::Role.register({
  :id           => :TOXICSTALLER,
  :id_number    => 10,
  :name         => _INTL("Toxic Staller")
})

GameData::Role.register({
  :id           => :SETUPSWEEPER,
  :id_number    => 11,
  :name         => _INTL("Setup Sweeper")
})

GameData::Role.register({
  :id           => :HAZARDREMOVAL,
  :id_number    => 12,
  :name         => _INTL("Hazard Removal")
})

GameData::Role.register({
  :id           => :PIVOT,
  :id_number    => 13,
  :name         => _INTL("Pivot")
})

GameData::Role.register({
  :id           => :SPEEDCONTROL,
  :id_number    => 14,
  :name         => _INTL("Speed Control")
})

GameData::Role.register({
  :id           => :SCREENS,
  :id_number    => 15,
  :name         => _INTL("Screens")
})

GameData::Role.register({
  :id           => :NONE,
  :id_number    => 16,
  :name         => _INTL("None")
})

GameData::Role.register({
  :id           => :TARGETALLY,
  :id_number    => 17,
  :name         => _INTL("Target Ally")
})

GameData::Role.register({
  :id           => :REDIRECTION,
  :id_number    => 18,
  :name         => _INTL("Redirection")
})

GameData::Role.register({
  :id           => :TRICKROOMSETTER,
  :id_number    => 19,
  :name         => _INTL("Trick Room Setter")
})

module Compiler
  def compile_trainers(path = "PBS/trainers.txt")
    GameData::Trainer::DATA.clear
    schema = GameData::Trainer::SCHEMA
    max_level = GameData::GrowthRate.max_level
    trainer_names             = []
    trainer_lose_texts        = []
    trainer_hash              = nil
    trainer_id                = -1
    current_pkmn              = nil
    old_format_current_line   = 0
    old_format_expected_lines = 0
    # Read each line of trainers.txt at a time and compile it as a trainer property
    pbCompilerEachPreppedLine(path) { |line, line_no|
      if line[/^\s*\[\s*(.+)\s*\]\s*$/]
        # New section [trainer_type, name] or [trainer_type, name, version]
        if trainer_hash
          if old_format_current_line > 0
            raise _INTL("Previous trainer not defined with as many Pokémon as expected.\r\n{1}", FileLineData.linereport)
          end
          if !current_pkmn
            raise _INTL("Started new trainer while previous trainer has no Pokémon.\r\n{1}", FileLineData.linereport)
          end
          # Add trainer's data to records
          trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
          GameData::Trainer.register(trainer_hash)
        end
        trainer_id += 1
        line_data = pbGetCsvRecord($~[1], line_no, [0, "esU", :TrainerType])
        # Construct trainer hash
        trainer_hash = {
          :id_number    => trainer_id,
          :trainer_type => line_data[0],
          :name         => line_data[1],
          :version      => line_data[2] || 0,
          :pokemon      => []
        }
        current_pkmn = nil
        trainer_names[trainer_id] = trainer_hash[:name]
      elsif line[/^\s*(\w+)\s*=\s*(.*)$/]
        # XXX=YYY lines
        if !trainer_hash
          raise _INTL("Expected a section at the beginning of the file.\r\n{1}", FileLineData.linereport)
        end
        property_name = $~[1]
        line_schema = schema[property_name]
        next if !line_schema
        property_value = pbGetCsvRecord($~[2], line_no, line_schema)
        # Error checking in XXX=YYY lines
        case property_name
        when "Items"
          property_value = [property_value] if !property_value.is_a?(Array)
          property_value.compact!
        when "Pokemon"
          if property_value[1] > max_level
            raise _INTL("Bad level: {1} (must be 1-{2}).\r\n{3}", property_value[1], max_level, FileLineData.linereport)
          end
        when "Name"
          if property_value.length > Pokemon::MAX_NAME_SIZE
            raise _INTL("Bad nickname: {1} (must be 1-{2} characters).\r\n{3}", property_value, Pokemon::MAX_NAME_SIZE, FileLineData.linereport)
          end
        when "Moves"
          property_value = [property_value] if !property_value.is_a?(Array)
          property_value.uniq!
          property_value.compact!
        when "IV"
          property_value = [property_value] if !property_value.is_a?(Array)
          property_value.compact!
          property_value.each do |iv|
            next if iv <= Pokemon::IV_STAT_LIMIT
            raise _INTL("Bad IV: {1} (must be 0-{2}).\r\n{3}", iv, Pokemon::IV_STAT_LIMIT, FileLineData.linereport)
          end
        when "EV"
          property_value = [property_value] if !property_value.is_a?(Array)
          property_value.compact!
          property_value.each do |ev|
            next if ev <= Pokemon::EV_STAT_LIMIT
            raise _INTL("Bad EV: {1} (must be 0-{2}).\r\n{3}", ev, Pokemon::EV_STAT_LIMIT, FileLineData.linereport)
          end
          ev_total = 0
          GameData::Stat.each_main do |s|
            next if s.pbs_order < 0
            ev_total += (property_value[s.pbs_order] || property_value[0])
          end
          if ev_total > Pokemon::EV_LIMIT
            raise _INTL("Total EVs are greater than allowed ({1}).\r\n{2}", Pokemon::EV_LIMIT, FileLineData.linereport)
          end
        when "Happiness"
          if property_value > 255
            raise _INTL("Bad happiness: {1} (must be 0-255).\r\n{2}", property_value, FileLineData.linereport)
          end
        end
        # Record XXX=YYY setting
        case property_name
        when "Items", "LoseText"
          trainer_hash[line_schema[0]] = property_value
          trainer_lose_texts[trainer_id] = property_value if property_name == "LoseText"
        when "Pokemon"
          current_pkmn = {
            :species => property_value[0],
            :level   => property_value[1]
          }
          trainer_hash[line_schema[0]].push(current_pkmn)
        else
          if !current_pkmn
            raise _INTL("Pokémon hasn't been defined yet!\r\n{1}", FileLineData.linereport)
          end
          case property_name
          when "Ability"
            if property_value[/^\d+$/]
              current_pkmn[:ability_index] = property_value.to_i
            elsif !GameData::Ability.exists?(property_value.to_sym)
              raise _INTL("Value {1} isn't a defined Ability.\r\n{2}", property_value, FileLineData.linereport)
            else
              current_pkmn[line_schema[0]] = property_value.to_sym
            end
          when "Role"
            if property_value[/^\d+$/]
              current_pkmn[:role] = property_value.to_i
            elsif !GameData::Role.exists?(property_value.to_sym)
              raise _INTL("Value {1} isn't a defined Role.\r\n{2}", property_value, FileLineData.linereport)
            else
              current_pkmn[line_schema[0]] = property_value.to_sym
            end
          when "IV", "EV"
            value_hash = {}
            GameData::Stat.each_main do |s|
              next if s.pbs_order < 0
              value_hash[s.id] = property_value[s.pbs_order] || property_value[0]
            end
            current_pkmn[line_schema[0]] = value_hash
          when "Ball"
            if property_value[/^\d+$/]
              current_pkmn[line_schema[0]] = pbBallTypeToItem(property_value.to_i).id
            elsif !GameData::Item.exists?(property_value.to_sym) ||
               !GameData::Item.get(property_value.to_sym).is_poke_ball?
              raise _INTL("Value {1} isn't a defined Poké Ball.\r\n{2}", property_value, FileLineData.linereport)
            else
              current_pkmn[line_schema[0]] = property_value.to_sym
            end
          else
            current_pkmn[line_schema[0]] = property_value
          end
        end
      else
        # Old format - backwards compatibility is SUCH fun!
        if old_format_current_line == 0   # Started an old trainer section
          if trainer_hash
            if !current_pkmn
              raise _INTL("Started new trainer while previous trainer has no Pokémon.\r\n{1}", FileLineData.linereport)
            end
            # Add trainer's data to records
            trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
            GameData::Trainer.register(trainer_hash)
          end
          trainer_id += 1
          old_format_expected_lines = 3
          # Construct trainer hash
          trainer_hash = {
            :id_number    => trainer_id,
            :trainer_type => nil,
            :name         => nil,
            :version      => 0,
            :pokemon      => []
          }
          current_pkmn = nil
        end
        # Evaluate line and add to hash
        old_format_current_line += 1
        case old_format_current_line
        when 1   # Trainer type
          line_data = pbGetCsvRecord(line, line_no, [0, "e", :TrainerType])
          trainer_hash[:trainer_type] = line_data
        when 2   # Trainer name, version number
          line_data = pbGetCsvRecord(line, line_no, [0, "sU"])
          line_data = [line_data] if !line_data.is_a?(Array)
          trainer_hash[:name]    = line_data[0]
          trainer_hash[:version] = line_data[1] if line_data[1]
          trainer_names[trainer_hash[:id_number]] = line_data[0]
        when 3   # Number of Pokémon, items
          line_data = pbGetCsvRecord(line, line_no,
             [0, "vEEEEEEEE", nil, :Item, :Item, :Item, :Item, :Item, :Item, :Item, :Item])
          line_data = [line_data] if !line_data.is_a?(Array)
          line_data.compact!
          old_format_expected_lines += line_data[0]
          line_data.shift
          trainer_hash[:items] = line_data if line_data.length > 0
        else   # Pokémon lines
          line_data = pbGetCsvRecord(line, line_no,
             [0, "evEEEEEUEUBEUUSBU", :Species, nil, :Item, :Move, :Move, :Move, :Move, nil,
                                      {"M" => 0, "m" => 0, "Male" => 0, "male" => 0, "0" => 0,
                                      "F" => 1, "f" => 1, "Female" => 1, "female" => 1, "1" => 1},
                                      nil, nil, :Nature, nil, nil, nil, nil, nil])
          current_pkmn = {
            :species => line_data[0]
          }
          trainer_hash[:pokemon].push(current_pkmn)
          # Error checking in properties
          line_data.each_with_index do |value, i|
            next if value.nil?
            case i
            when 1   # Level
              if value > max_level
                raise _INTL("Bad level: {1} (must be 1-{2}).\r\n{3}", value, max_level, FileLineData.linereport)
              end
            when 12   # IV
              if value > Pokemon::IV_STAT_LIMIT
                raise _INTL("Bad IV: {1} (must be 0-{2}).\r\n{3}", value, Pokemon::IV_STAT_LIMIT, FileLineData.linereport)
              end
            when 13   # Happiness
              if value > 255
                raise _INTL("Bad happiness: {1} (must be 0-255).\r\n{2}", value, FileLineData.linereport)
              end
            when 14   # Nickname
              if value.length > Pokemon::MAX_NAME_SIZE
                raise _INTL("Bad nickname: {1} (must be 1-{2} characters).\r\n{3}", value, Pokemon::MAX_NAME_SIZE, FileLineData.linereport)
              end
            end
          end
          # Write all line data to hash
          moves = [line_data[3], line_data[4], line_data[5], line_data[6]]
          moves.uniq!.compact!
          ivs = {}
          if line_data[12]
            GameData::Stat.each_main do |s|
              ivs[s.id] = line_data[12] if s.pbs_order >= 0
            end
          end
          current_pkmn[:level]         = line_data[1]
          current_pkmn[:item]          = line_data[2] if line_data[2]
          current_pkmn[:moves]         = moves if moves.length > 0
          current_pkmn[:ability_index] = line_data[7] if line_data[7]
          current_pkmn[:gender]        = line_data[8] if line_data[8]
          current_pkmn[:form]          = line_data[9] if line_data[9]
          current_pkmn[:shininess]     = line_data[10] if line_data[10]
          current_pkmn[:nature]        = line_data[11] if line_data[11]
          current_pkmn[:iv]            = ivs if ivs.length > 0
          current_pkmn[:happiness]     = line_data[13] if line_data[13]
          current_pkmn[:name]          = line_data[14] if line_data[14] && !line_data[14].empty?
          current_pkmn[:shadowness]    = line_data[15] if line_data[15]
          current_pkmn[:poke_ball]     = line_data[16] if line_data[16]
          # Check if this is the last expected Pokémon
          old_format_current_line = 0 if old_format_current_line >= old_format_expected_lines
        end
      end
    }
    if old_format_current_line > 0
      raise _INTL("Unexpected end of file, last trainer not defined with as many Pokémon as expected.\r\n{1}", FileLineData.linereport)
    end
    # Add last trainer's data to records
    if trainer_hash
      trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
      GameData::Trainer.register(trainer_hash)
    end
    # Save all data
    GameData::Trainer.save
    MessageTypes.setMessagesAsHash(MessageTypes::TrainerNames, trainer_names)
    MessageTypes.setMessagesAsHash(MessageTypes::TrainerLoseText, trainer_lose_texts)
    Graphics.update
  end
end

class Pokemon
  attr_accessor :role
  def role
    @role = :NONE if (@role == "" || @role == nil)
    return GameData::Role.try_get(@role)
  end

  def role=(value)
    return if value && !GameData::Role.exists?(value)
    @role = :NONE if !value
    @role = (value) ? GameData::Role.get(value).id : value
  end
end

class PokeBattle_Battler
  attr_accessor :role
  def role
    @role = :NONE if (@role == "" || @role == nil)
    return GameData::Role.try_get(@role)
  end

  def role=(value)
    new_role = GameData::Role.try_get(value)
    @role = (new_role) ? new_role.id : nil
  end
end