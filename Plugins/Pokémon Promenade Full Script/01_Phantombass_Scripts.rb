#===================================
# Level Cap Scripts
#===================================
module Settings
  LEVEL_CAP_SWITCH = 904
  FISHING_AUTO_HOOK     = true
  GAME_VERSION = '1.3.0'
  DISABLE_EVS = 917
end

Essentials::ERROR_TEXT += "[Pokémon Promenade v#{Settings::GAME_VERSION}]\r\n"

class Game_System
  attr_accessor :level_cap
  alias initialize_cap initialize
  def initialize
    initialize_cap
    @level_cap          = 0
  end
  def level_cap
    return @level_cap
  end
end

LEVEL_CAP = [7,15,19,25,29,36,40,43,45,50,53,54,58,59,61,64,68,69,70,71,78,80,85,90,100]

module Game
  def self.level_cap_update
    $game_system.level_cap += 1
    $game_system.level_cap = LEVEL_CAP.size-1 if $game_system.level_cap >= LEVEL_CAP.size
    $game_variables[106] = LEVEL_CAP[$game_system.level_cap]
  end
  def self.start_new
    if $game_map && $game_map.events
      $game_map.events.each_value { |event| event.clear_starting }
    end
    $game_temp.common_event_id = 0 if $game_temp
    $PokemonTemp.begunNewGame = true
    $game_system.initialize
    $scene = Scene_Map.new
    SaveData.load_new_game_values
    $MapFactory = PokemonMapFactory.new($data_system.start_map_id)
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    $PokemonEncounters = PokemonEncounters.new
    $PokemonEncounters.setup($game_map.map_id)
    $game_map.autoplay
    $game_map.update
  end
end

module DailyWeather
  Variable = 27
  TimeNow = 28
  LastTime = 99
end

Events.onMapChange += proc {| sender, e |
    $game_switches[350] = false
    vroad = [255,259,260,264,265,266,267,268]
    if vroad.include?($game_map.map_id)
      $GameSpeed = 0
      $CanToggle = false
    end
    final_release
    # Weather Setting
    time = pbGetTimeNow
    $game_variables[DailyWeather::LastTime] = time.day
    dailyWeather = $game_variables[DailyWeather::Variable]
    if $game_variables[DailyWeather::TimeNow] > $game_variables[DailyWeather::LastTime] || $game_variables[DailyWeather::TimeNow]<$game_variables[DailyWeather::LastTime]
      $game_variables[DailyWeather::Variable] = 1+rand(100)
      $game_variables[DailyWeather::TimeNow] = $game_variables[DailyWeather::LastTime]
    end
}

def pbDailyWeather(weather1,weather2,weather3)
  weather = $game_variables[DailyWeather::Variable]
  if weather >= 96
    $game_screen.weather(weather1,9,20)
  elsif weather >= 86
    $game_screen.weather(weather2,9,20)
  else
    $game_screen.weather(weather3,9,20)
  end
end
Events.onMapUpdate+=proc {|sender,e|
  $repel_toggle = true if $game_switches[114]
}

Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon = e[0]
  if pokemon.level > $game_variables[LvlCap::LevelCap]
    $game_switches[81] = true
  end
  abilRand = rand(100)
  if abilRand > 80 && $game_map.map_id == 281 && $currentDexSearch == nil
    pokemon.ability_index = 2
  end
  mlv = $Trainer.party.map { |e| e.level  }.max
  if $game_switches[114]
    level = mlv - 1 - rand(2)
    pokemon.level = level <= 0 ? 1 : level
    pokemon.calc_stats
    pokemon.reset_moves
  end
}

Events.onEndBattle += proc { |_sender,e|
  $game_switches[81] = false
  $repel_toggle = true
}

def pbStartOver(gameover=false)
  if pbInBugContest?
    pbBugContestStartOver
    return
  end
  $Trainer.heal_party
  if $PokemonGlobal.pokecenterMapId && $PokemonGlobal.pokecenterMapId>=0
    if gameover
      pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]After the unfortunate defeat, you scurry back to a Pokémon Center."))
    else
      if $game_switches[73] == true
        pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]After losing the Nuzlocke, you scurry back to a Pokémon Center, protecting your exhausted Pokémon from any further harm..."))
      else
        pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]You scurry back to a Pokémon Center, protecting your exhausted Pokémon from any further harm..."))
      end
    end
    pbCancelVehicles
    pbRemoveDependencies
    $game_switches[Settings::STARTING_OVER_SWITCH] = true
    $game_switches[73] = false
    $CanToggle = true
    $game_temp.player_new_map_id    = $PokemonGlobal.pokecenterMapId
    $game_temp.player_new_x         = $PokemonGlobal.pokecenterX
    $game_temp.player_new_y         = $PokemonGlobal.pokecenterY
    $game_temp.player_new_direction = $PokemonGlobal.pokecenterDirection
    $scene.transfer_player if $scene.is_a?(Scene_Map)
    $game_map.refresh
  else
    homedata = GameData::Metadata.get.home
    if homedata && !pbRgssExists?(sprintf("Data/Map%03d.rxdata",homedata[0]))
      if $DEBUG
        pbMessage(_ISPRINTF("Can't find the map 'Map{1:03d}' in the Data folder. The game will resume at the player's position.",homedata[0]))
      end
      $Trainer.heal_party
      return
    end
    if gameover
      pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]After the unfortunate defeat, you scurry back home."))
    else
      if $game_switches[73] == true
        pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]After losing the Nuzlocke, you scurry back home, protecting your exhausted Pokémon from any further harm..."))
      else
        pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]You scurry back home, protecting your exhausted Pokémon from any further harm..."))
      end
    end
    if homedata
      pbCancelVehicles
      pbRemoveDependencies
      $game_switches[Settings::STARTING_OVER_SWITCH] = true
      $game_switches[73] = false
      $CanToggle = true
      $game_temp.player_new_map_id    = homedata[0]
      $game_temp.player_new_x         = homedata[1]
      $game_temp.player_new_y         = homedata[2]
      $game_temp.player_new_direction = homedata[3]
      $scene.transfer_player if $scene.is_a?(Scene_Map)
      $game_map.refresh
    else
      $Trainer.heal_party
    end
  end
  pbEraseEscapePoint
end

class Trainer
  def heal_party
    if $game_switches[73] == true
      pbEachPokemon { |poke,_box| poke.heal if !poke.fainted?}
    else
      pbEachPokemon { |poke,_box| poke.heal}
    end
  end
end

class PokemonTemp
  def pbPrepareBattle(battle)
    battleRules = $PokemonTemp.battleRules
    # The size of the battle, i.e. how many Pokémon on each side (default: "single")
    battle.setBattleMode(battleRules["size"]) if !battleRules["size"].nil?
    # Whether the game won't black out even if the player loses (default: false)
    battle.canLose = battleRules["canLose"] if !battleRules["canLose"].nil?
    # Whether the player can choose to run from the battle (default: true)
    battle.canRun = battleRules["canRun"] if !battleRules["canRun"].nil?
    # Whether wild Pokémon always try to run from battle (default: nil)
    battle.rules["alwaysflee"] = battleRules["roamerFlees"]
    # Whether Pokémon gain Exp/EVs from defeating/catching a Pokémon (default: true)
    battle.expGain = battleRules["expGain"] if !battleRules["expGain"].nil?
    # Whether the player gains/loses money at the end of the battle (default: true)
    battle.moneyGain = battleRules["moneyGain"] if !battleRules["moneyGain"].nil?
    # Whether the player is able to switch when an opponent's Pokémon faints
    battle.switchStyle = ($PokemonSystem.battlestyle==0)
    battle.switchStyle = battleRules["switchStyle"] if !battleRules["switchStyle"].nil?
    # Whether battle animations are shown
    battle.showAnims = ($PokemonSystem.battlescene==0)
    battle.showAnims = battleRules["battleAnims"] if !battleRules["battleAnims"].nil?
    # Terrain
    battle.defaultTerrain = battleRules["defaultTerrain"] if !battleRules["defaultTerrain"].nil?
    # Weather
    if battleRules["defaultWeather"].nil?
      battle.defaultWeather = $game_screen.weather_type
    else
      battle.defaultWeather = battleRules["defaultWeather"]
    end
    # Environment
    if battleRules["environment"].nil?
      battle.environment = pbGetEnvironment
    else
      battle.environment = battleRules["environment"]
    end
    # Backdrop graphic filename
    if !battleRules["backdrop"].nil?
      backdrop = battleRules["backdrop"]
    elsif $PokemonGlobal.nextBattleBack
      backdrop = $PokemonGlobal.nextBattleBack
    elsif $PokemonGlobal.surfing
      backdrop = "water"   # This applies wherever you are, including in caves
    elsif GameData::MapMetadata.exists?($game_map.map_id)
      back = GameData::MapMetadata.get($game_map.map_id).battle_background
      backdrop = back if back && back != ""
    end
    backdrop = "indoor1" if !backdrop
    battle.backdrop = backdrop
    # Choose a name for bases depending on environment
    if battleRules["base"].nil?
      environment_data = GameData::Environment.try_get(battle.environment)
      base = environment_data.battle_base if environment_data
    else
      base = battleRules["base"]
    end
    battle.backdropBase = base if base
    # Time of day
    if GameData::MapMetadata.exists?($game_map.map_id) &&
       GameData::MapMetadata.get($game_map.map_id).battle_environment == :Cave
      battle.time = 2   # This makes Dusk Balls work properly in caves
    elsif Settings::TIME_SHADING
      timeNow = pbGetTimeNow
      if PBDayNight.isNight?(timeNow);      battle.time = 2
      elsif PBDayNight.isEvening?(timeNow); battle.time = 1
      else;                                 battle.time = 0
      end
    end
  end
end

class PokeBattle_Battle
  def pbStartBattleCore
    # Set up the battlers on each side
    sendOuts = pbSetUpSides
    olditems = []
    pbParty(0).each_with_index do |pkmn,i|
      item = pkmn.item_id
      olditems.push(item)
    end
    $olditems = olditems
    # Create all the sprites and play the battle intro animation
    @field.weather = $game_screen.weather_type
    @scene.pbStartBattle(self)
    # Show trainers on both sides sending out Pokémon
    pbStartBattleSendOut(sendOuts)
    # Weather announcement
    weather_data = GameData::BattleWeather.try_get(@field.weather)
    pbCommonAnimation(weather_data.animation) if weather_data
    case @field.weather
    when :Sun         then pbDisplay(_INTL("The sunlight is strong."))
    when :Rain        then pbDisplay(_INTL("It is raining."))
    when :Sandstorm   then pbDisplay(_INTL("A sandstorm is raging."))
    when :Hail        then pbDisplay(_INTL("Hail is falling."))
    when :HarshSun    then pbDisplay(_INTL("The sunlight is extremely harsh."))
    when :HeavyRain   then pbDisplay(_INTL("It is raining heavily."))
    when :StrongWinds then pbDisplay(_INTL("The wind is strong."))
    when :ShadowSky   then pbDisplay(_INTL("The sky is shadowy."))
    when :Starstorm  then pbDisplay(_INTL("Stars fill the sky."))
    when :Thunder    then pbDisplay(_INTL("Lightning flashes in the sky."))
    when :Storm      then pbDisplay(_INTL("A thunderstorm rages. The ground became electrified!"))
    when :Humid      then pbDisplay(_INTL("The air is humid."))
    when :Overcast   then pbDisplay(_INTL("The sky is overcast."))
    when :Eclipse    then pbDisplay(_INTL("The sky is dark."))
    when :Fog        then pbDisplay(_INTL("The fog is deep."))
    when :AcidRain   then pbDisplay(_INTL("Acid rain is falling."))
    when :VolcanicAsh then pbDisplay(_INTL("Volcanic Ash sprinkles down."))
    when :Rainbow    then pbDisplay(_INTL("A rainbow crosses the sky."))
    when :Borealis   then pbDisplay(_INTL("The sky is ablaze with color."))
    when :TimeWarp   then pbDisplay(_INTL("Time has stopped."))
    when :Reverb     then pbDisplay(_INTL("A dull echo hums."))
    when :DClear     then pbDisplay(_INTL("The sky is distorted."))
    when :DRain      then pbDisplay(_INTL("Rain is falling upward."))
    when :DWind      then pbDisplay(_INTL("The wind is haunting."))
    when :DAshfall   then pbDisplay(_INTL("Ash floats in midair."))
    when :Sleet      then pbDisplay(_INTL("Sleet began to fall."))
    when :Windy      then pbDisplay(_INTL("There is a slight breeze."))
    when :HeatLight  then pbDisplay(_INTL("Static fills the air."))
    when :DustDevil  then pbDisplay(_INTL("A dust devil approaches."))
    end
    # Terrain announcement
    terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
    pbCommonAnimation(terrain_data.animation) if terrain_data
    case @field.terrain
    when :Electric
      pbDisplay(_INTL("An electric current runs across the battlefield!"))
    when :Grassy
      pbDisplay(_INTL("Grass is covering the battlefield!"))
    when :Misty
      pbDisplay(_INTL("Mist swirls about the battlefield!"))
    when :Psychic
      pbDisplay(_INTL("The battlefield is weird!"))
    end
    # Abilities upon entering battle
    pbOnActiveAll
    # Main battle loop
    pbBattleLoop
  end

  def pbEndOfBattle
    oldDecision = @decision
    @decision = 4 if @decision==1 && wildBattle? && @caughtPokemon.length>0
    case oldDecision
    ##### WIN #####
    when 1
      PBDebug.log("")
      PBDebug.log("***Player won***")
      if trainerBattle?
        @scene.pbTrainerBattleSuccess
        case @opponent.length
        when 1
          pbDisplayPaused(_INTL("You defeated {1}!",@opponent[0].full_name))
        when 2
          pbDisplayPaused(_INTL("You defeated {1} and {2}!",@opponent[0].full_name,
             @opponent[1].full_name))
        when 3
          pbDisplayPaused(_INTL("You defeated {1}, {2} and {3}!",@opponent[0].full_name,
             @opponent[1].full_name,@opponent[2].full_name))
        end
        @opponent.each_with_index do |_t,i|
          @scene.pbShowOpponent(i)
          msg = (@endSpeeches[i] && @endSpeeches[i]!="") ? @endSpeeches[i] : "..."
          pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/,pbPlayer.name))
        end
      end
      # Gain money from winning a trainer battle, and from Pay Day
      pbGainMoney if @decision!=4
      # Hide remaining trainer
      @scene.pbShowOpponent(@opponent.length) if trainerBattle? && @caughtPokemon.length>0
    ##### LOSE, DRAW #####
    when 2, 5
      PBDebug.log("")
      PBDebug.log("***Player lost***") if @decision==2
      PBDebug.log("***Player drew with opponent***") if @decision==5
      if @internalBattle
        pbDisplayPaused(_INTL("You have no more Pokémon that can fight!"))
        if trainerBattle?
          case @opponent.length
          when 1
            pbDisplayPaused(_INTL("You lost against {1}!",@opponent[0].full_name))
          when 2
            pbDisplayPaused(_INTL("You lost against {1} and {2}!",
               @opponent[0].full_name,@opponent[1].full_name))
          when 3
            pbDisplayPaused(_INTL("You lost against {1}, {2} and {3}!",
               @opponent[0].full_name,@opponent[1].full_name,@opponent[2].full_name))
          end
        end
        # Lose money from losing a battle
        pbLoseMoney
        pbDisplayPaused(_INTL("You blacked out!")) if !@canLose
      elsif @decision==2
        if @opponent
          @opponent.each_with_index do |_t,i|
            @scene.pbShowOpponent(i)
            msg = (@endSpeechesWin[i] && @endSpeechesWin[i]!="") ? @endSpeechesWin[i] : "..."
            pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/,pbPlayer.name))
          end
        end
      end
    ##### CAUGHT WILD POKÉMON #####
    when 4
      @scene.pbWildBattleSuccess if !Settings::GAIN_EXP_FOR_CAPTURE
    end
    # Register captured Pokémon in the Pokédex, and store them
    pbRecordAndStoreCaughtPokemon
    # Collect Pay Day money in a wild battle that ended in a capture
    pbGainMoney if @decision==4
    # Pass on Pokérus within the party
    if @internalBattle
      infected = []
      $Trainer.party.each_with_index do |pkmn,i|
        infected.push(i) if pkmn.pokerusStage==1
      end
      infected.each do |idxParty|
        strain = $Trainer.party[idxParty].pokerusStrain
        if idxParty>0 && $Trainer.party[idxParty-1].pokerusStage==0
          $Trainer.party[idxParty-1].givePokerus(strain) if rand(3)==0   # 33%
        end
        if idxParty<$Trainer.party.length-1 && $Trainer.party[idxParty+1].pokerusStage==0
          $Trainer.party[idxParty+1].givePokerus(strain) if rand(3)==0   # 33%
        end
      end
    end
    # Clean up battle stuff
    @scene.pbEndBattle(@decision)
    @battlers.each do |b|
      next if !b
      if b.ability == :BAROMETRIC
        b.form = 0
      end
      pbCancelChoice(b.index)   # Restore unused items to Bag
      BattleHandlers.triggerAbilityOnSwitchOut(b.ability,b,true) if b.abilityActive?
    end
    pbParty(0).each_with_index do |pkmn,i|
      next if !pkmn
      @peer.pbOnLeavingBattle(self,pkmn,@usedInBattle[0][i],true)   # Reset form
      if @opponent
        pkmn.item = $olditems[i]
      else
        pkmn.item = @initialItems[0][i]
      end
    end
    @scene.pbTrainerBattleSpeech("loss") if @decision == 2
    # reset all the EBDX queues
    EliteBattle.reset(:nextBattleScript, :wildSpecies, :wildLevel, :wildForm, :nextBattleBack, :nextUI, :nextBattleData,
                     :wildSpecies, :wildLevel, :wildForm, :setBoss, :cachedBattler, :tviewport)
    EliteBattle.set(:setBoss, false)
    EliteBattle.set(:colorAlpha, 0)
    EliteBattle.set(:smAnim, false)
    $game_switches[81] = false
    # return final output
    return @decision
  end

  def pbGainEVsOne(idxParty,defeatedBattler)
    if !$game_switches[Settings::DISABLE_EVS]
      pkmn = pbParty(0)[idxParty]   # The Pokémon gaining EVs from defeatedBattler
      evYield = defeatedBattler.pokemon.evYield
      # Num of effort points pkmn already has
      evTotal = 0
      GameData::Stat.each_main { |s| evTotal += pkmn.ev[s.id] }
      # Modify EV yield based on pkmn's held item
      if !BattleHandlers.triggerEVGainModifierItem(pkmn.item,pkmn,evYield)
        BattleHandlers.triggerEVGainModifierItem(@initialItems[0][idxParty],pkmn,evYield)
      end
      # Double EV gain because of Pokérus
      if pkmn.pokerusStage>=1   # Infected or cured
        evYield.each_key { |stat| evYield[stat] *= 2 }
      end
      # Gain EVs for each stat in turn
      if pkmn.shadowPokemon? && pkmn.saved_ev
        pkmn.saved_ev.each_value { |e| evTotal += e }
        GameData::Stat.each_main do |s|
          evGain = evYield[s.id].clamp(0, Pokemon::EV_STAT_LIMIT - pkmn.ev[s.id] - pkmn.saved_ev[s.id])
          evGain = evGain.clamp(0, Pokemon::EV_LIMIT - evTotal)
          pkmn.saved_ev[s.id] += evGain
          evTotal += evGain
        end
      else
        GameData::Stat.each_main do |s|
          evGain = evYield[s.id].clamp(0, Pokemon::EV_STAT_LIMIT - pkmn.ev[s.id])
          evGain = evGain.clamp(0, Pokemon::EV_LIMIT - evTotal)
          pkmn.ev[s.id] += evGain
          evTotal += evGain
        end
      end
    end
  end

  def pbGainExpOne(idxParty,defeatedBattler,numPartic,expShare,expAll,showMessages=true)
    pkmn = pbParty(0)[idxParty]   # The Pokémon gaining EVs from defeatedBattler
    growth_rate = pkmn.growth_rate
    # Don't bother calculating if gainer is already at max Exp
    if pkmn.exp>=growth_rate.maximum_exp
      pkmn.calc_stats   # To ensure new EVs still have an effect
      return
    end
    isPartic    = defeatedBattler.participants.include?(idxParty)
    hasExpShare = expShare.include?(idxParty)
    level = defeatedBattler.level
    level_cap = LEVEL_CAP[$game_system.level_cap]
    level_cap_gap = growth_rate.exp_values[level_cap] - pkmn.exp
    # Main Exp calculation
    exp = 0
    a = level*defeatedBattler.pokemon.base_exp
    if expShare.length>0 && (isPartic || hasExpShare)
      if numPartic==0   # No participants, all Exp goes to Exp Share holders
        exp = a / (Settings::SPLIT_EXP_BETWEEN_GAINERS ? expShare.length : 1)
      elsif Settings::SPLIT_EXP_BETWEEN_GAINERS   # Gain from participating and/or Exp Share
        exp = a/(2*numPartic) if isPartic
        exp += a/(2*expShare.length) if hasExpShare
      else   # Gain from participating and/or Exp Share (Exp not split)
        exp = (isPartic) ? a : a/2
      end
    elsif isPartic   # Participated in battle, no Exp Shares held by anyone
      exp = a / (Settings::SPLIT_EXP_BETWEEN_GAINERS ? numPartic : 1)
    elsif expAll   # Didn't participate in battle, gaining Exp due to Exp All
      # NOTE: Exp All works like the Exp Share from Gen 6+, not like the Exp All
      #       from Gen 1, i.e. Exp isn't split between all Pokémon gaining it.
      exp = a/2
    end
    return if exp<=0
    # Pokémon gain more Exp from trainer battles
    exp = (exp*1.5).floor if trainerBattle?
    # Scale the gained Exp based on the gainer's level (or not)
    if Settings::SCALED_EXP_FORMULA
      exp /= 5
      levelAdjust = (2*level+10.0)/(pkmn.level+level+10.0)
      levelAdjust = levelAdjust**5
      levelAdjust = Math.sqrt(levelAdjust)
      exp *= levelAdjust
      exp = exp.floor
      exp += 1 if isPartic || hasExpShare
      if pkmn.level >= level_cap
        exp /= 250
      end
      if exp >= level_cap_gap
        exp = level_cap_gap + 1
      end
    else
      if a = level_cap_gap
        exp = a
      else
        exp /= 7
      end
    end
    # Foreign Pokémon gain more Exp
    isOutsider = (pkmn.owner.id != pbPlayer.id ||
                 (pkmn.owner.language != 0 && pkmn.owner.language != pbPlayer.language))
    if isOutsider
      if pkmn.owner.language != 0 && pkmn.owner.language != pbPlayer.language
        exp = (exp*1.7).floor
      else
        exp = (exp*1.5).floor
      end
    end
    # Modify Exp gain based on pkmn's held item
    i = BattleHandlers.triggerExpGainModifierItem(pkmn.item,pkmn,exp)
    if i<0
      i = BattleHandlers.triggerExpGainModifierItem(@initialItems[0][idxParty],pkmn,exp)
    end
    exp = i if i>=0
    # Make sure Exp doesn't exceed the maximum
    expFinal = growth_rate.add_exp(pkmn.exp, exp)
    expGained = expFinal-pkmn.exp
    return if expGained<=0
    # "Exp gained" message
    if showMessages
      if isOutsider
        pbDisplayPaused(_INTL("{1} got a boosted {2} Exp. Points!",pkmn.name,expGained))
      else
        pbDisplayPaused(_INTL("{1} got {2} Exp. Points!",pkmn.name,expGained))
      end
    end
    curLevel = pkmn.level
    newLevel = growth_rate.level_from_exp(expFinal)
    if newLevel<curLevel
      debugInfo = "Levels: #{curLevel}->#{newLevel} | Exp: #{pkmn.exp}->#{expFinal} | gain: #{expGained}"
      raise RuntimeError.new(
         _INTL("{1}'s new level is less than its\r\ncurrent level, which shouldn't happen.\r\n[Debug: {2}]",
         pkmn.name,debugInfo))
    end
    # Give Exp
    if pkmn.shadowPokemon?
      pkmn.exp += expGained
      return
    end
    tempExp1 = pkmn.exp
    battler = pbFindBattler(idxParty)
    loop do   # For each level gained in turn...
      # EXP Bar animation
      levelMinExp = growth_rate.minimum_exp_for_level(curLevel)
      levelMaxExp = growth_rate.minimum_exp_for_level(curLevel + 1)
      tempExp2 = (levelMaxExp<expFinal) ? levelMaxExp : expFinal
      pkmn.exp = tempExp2
      @scene.pbEXPBar(battler,levelMinExp,levelMaxExp,tempExp1,tempExp2)
      tempExp1 = tempExp2
      curLevel += 1
      if curLevel>newLevel
        # Gained all the Exp now, end the animation
        pkmn.calc_stats
        battler.pbUpdate(false) if battler
        @scene.pbRefreshOne(battler.index) if battler
        break
      end
      # Levelled up
      pbCommonAnimation("LevelUp",battler) if battler
      oldTotalHP = pkmn.totalhp
      oldAttack  = pkmn.attack
      oldDefense = pkmn.defense
      oldSpAtk   = pkmn.spatk
      oldSpDef   = pkmn.spdef
      oldSpeed   = pkmn.speed
      if battler && battler.pokemon
        battler.pokemon.changeHappiness("levelup")
      end
      pkmn.calc_stats
      battler.pbUpdate(false) if battler
      @scene.pbRefreshOne(battler.index) if battler
      pbDisplayPaused(_INTL("{1} grew to Lv. {2}!",pkmn.name,curLevel))
      @scene.pbLevelUp(pkmn,battler,oldTotalHP,oldAttack,oldDefense,
                                    oldSpAtk,oldSpDef,oldSpeed)
      # Learn all moves learned at this level
      moveList = pkmn.getMoveList
      moveList.each { |m| pbLearnMove(idxParty,m[1]) if m[0]==curLevel }
    end
  end

  def pbOnActiveOne(battler)
    return false if battler.fainted?
    # Introduce Shadow Pokémon
    if battler.opposes? && battler.shadowPokemon?
      pbCommonAnimation("Shadow",battler)
      pbDisplay(_INTL("Oh!\nA Shadow Pokémon!"))
    end
    # Record money-doubling effect of Amulet Coin/Luck Incense
    if !battler.opposes? && [:AMULETCOIN, :LUCKINCENSE].include?(battler.item_id)
      @field.effects[PBEffects::AmuletCoin] = true
    end
    # Update battlers' participants (who will gain Exp/EVs when a battler faints)
    eachBattler { |b| b.pbUpdateParticipants }
    # Healing Wish
    if @positions[battler.index].effects[PBEffects::HealingWish]
      pbCommonAnimation("HealingWish",battler)
      pbDisplay(_INTL("The healing wish came true for {1}!",battler.pbThis(true)))
      battler.pbRecoverHP(battler.totalhp)
      battler.pbCureStatus(false)
      @positions[battler.index].effects[PBEffects::HealingWish] = false
    end
    # Lunar Dance
    if @positions[battler.index].effects[PBEffects::LunarDance]
      pbCommonAnimation("LunarDance",battler)
      pbDisplay(_INTL("{1} became cloaked in mystical moonlight!",battler.pbThis))
      battler.pbRecoverHP(battler.totalhp)
      battler.pbCureStatus(false)
      battler.eachMove { |m| m.pp = m.total_pp }
      @positions[battler.index].effects[PBEffects::LunarDance] = false
    end
    # Entry hazards
    # Stealth Rock
    if battler.pbOwnSide.effects[PBEffects::CometShards] && battler.takesIndirectDamage? &&
       GameData::Type.exists?(:COSMIC)
      bTypes = battler.pbTypes(true)
      if battler.pbHasType?(:COSMIC)
        battler.pbOwnSide.effects[PBEffects::CometShards] = false
        pbDisplay(_INTL("{1} dissipated the Comet Shards!",battler.pbThis))
      else
        eff = Effectiveness.calculate(:COSMIC, bTypes[0], bTypes[1], bTypes[2])
        if !Effectiveness.ineffective?(eff)
          eff = eff.to_f / Effectiveness::NORMAL_EFFECTIVE
          oldHP = battler.hp
          battler.pbReduceHP(battler.totalhp*eff/8,false)
          pbDisplay(_INTL("Pointed stones dug into {1}!",battler.pbThis))
          battler.pbItemHPHealCheck
          if battler.pbAbilitiesOnDamageTaken(oldHP)   # Switched out
            return pbOnActiveOne(battler)   # For replacement battler
          end
        end
      end
    end
    #Comet Shards
    if battler.pbOwnSide.effects[PBEffects::StealthRock] && battler.takesIndirectDamage? &&
       GameData::Type.exists?(:ROCK)
      bTypes = battler.pbTypes(true)
      eff = Effectiveness.calculate(:ROCK, bTypes[0], bTypes[1], bTypes[2])
      if !Effectiveness.ineffective?(eff)
        eff = eff.to_f / Effectiveness::NORMAL_EFFECTIVE
        oldHP = battler.hp
        battler.pbReduceHP(battler.totalhp*eff/8,false)
        pbDisplay(_INTL("Pointed stones dug into {1}!",battler.pbThis))
        battler.pbItemHPHealCheck
        if battler.pbAbilitiesOnDamageTaken(oldHP)   # Switched out
          return pbOnActiveOne(battler)   # For replacement battler
        end
      end
    end
    # Spikes
    if battler.pbOwnSide.effects[PBEffects::Spikes]>0 && battler.takesIndirectDamage? &&
       !battler.airborne?
      spikesDiv = [8,6,4][battler.pbOwnSide.effects[PBEffects::Spikes]-1]
      oldHP = battler.hp
      battler.pbReduceHP(battler.totalhp/spikesDiv,false)
      pbDisplay(_INTL("{1} is hurt by the spikes!",battler.pbThis))
      battler.pbItemHPHealCheck
      if battler.pbAbilitiesOnDamageTaken(oldHP)   # Switched out
        return pbOnActiveOne(battler)   # For replacement battler
      end
    end
    # Toxic Spikes
    if battler.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 && !battler.fainted? &&
       !battler.airborne?
      if battler.pbHasType?(:POISON)
        battler.pbOwnSide.effects[PBEffects::ToxicSpikes] = 0
        pbDisplay(_INTL("{1} absorbed the poison spikes!",battler.pbThis))
      elsif battler.pbCanPoison?(nil,false)
        if battler.pbOwnSide.effects[PBEffects::ToxicSpikes]==2
          battler.pbPoison(nil,_INTL("{1} was badly poisoned by the poison spikes!",battler.pbThis),true)
        else
          battler.pbPoison(nil,_INTL("{1} was poisoned by the poison spikes!",battler.pbThis))
        end
      end
    end
    # Sticky Web
    if battler.pbOwnSide.effects[PBEffects::StickyWeb] && !battler.fainted? &&
       !battler.airborne?
      pbDisplay(_INTL("{1} was caught in a sticky web!",battler.pbThis))
      if battler.pbCanLowerStatStage?(:SPEED)
        battler.pbLowerStatStage(:SPEED,1,nil)
        battler.pbItemStatRestoreCheck
      end
    end
    # Battler faints if it is knocked out because of an entry hazard above
    if battler.fainted?
      battler.pbFaint
      pbGainExp
      pbJudge
      return false
    end
    battler.pbCheckForm
    return true
  end

  def pbEORWeather(priority)
    # NOTE: Primordial weather doesn't need to be checked here, because if it
    #       could wear off here, it will have worn off already.
    # Count down weather duration
    if @field.weather != $game_screen.weather_type
      @field.weatherDuration -= 1 if @field.weatherDuration>0
    else
      @field.weatherDuration = 1
    end
    # Weather wears off
    if @field.weatherDuration==0
      case @field.weather
      when :Sun       then pbDisplay(_INTL("The sunlight faded."))
      when :Rain      then pbDisplay(_INTL("The rain stopped."))
      when :Sandstorm then pbDisplay(_INTL("The sandstorm subsided."))
      when :Hail      then pbDisplay(_INTL("The hail stopped."))
      when :ShadowSky then pbDisplay(_INTL("The shadow sky faded."))
      when :Starstorm then pbDisplay(_INTL("The stars have faded."))
      when :Storm then pbDisplay(_INTL("The storm has calmed."))
      when :Humid then pbDisplay(_INTL("The humidity has lowered."))
      when :Overcast then pbDisplay(_INTL("The clouds have cleared."))
      when :Eclipse then pbDisplay(_INTL("The sky brightened."))
      when :Fog then pbDisplay(_INTL("The fog has lifted."))
      when :AcidRain then pbDisplay(_INTL("The acid rain has stopped."))
      when :VolcanicAsh then pbDisplay(_INTL("The ash dissolved."))
      when :Rainbow then pbDisplay(_INTL("The rainbow disappeared."))
      when :Borealis then pbDisplay(_INTL("The sky has calmed."))
      when :DClear then pbDisplay(_INTL("The sky returned to normal."))
      when :DRain then pbDisplay(_INTL("The rain has stopped."))
      when :DWind then pbDisplay(_INTL("The wind has passed."))
      when :DAshfall then pbDisplay(_INTL("The ash disintegrated."))
      when :Sleet then pbDisplay(_INTL("The sleet lightened."))
      when :Windy then pbDisplay(_INTL("The wind died down."))
      when :HeatLight then pbDisplay(_INTL("The air has calmed."))
      when :TimeWarp then pbDisplay(_INTL("Time began to move again."))
      when :Reverb then pbDisplay(_INTL("Silence fell once more."))
      when :DustDevil then pbDisplay(_INTL("The dust devil dissipated."))
      end
      @field.weather = :None
      # Check for form changes caused by the weather changing
      eachBattler { |b| b.pbCheckFormOnWeatherChange }
      # Start up the default weather
      pbStartWeather(nil,$game_screen.weather_type) if $game_screen.weather_type != :None
      return if @field.weather == :None
    end
    # Weather continues
    weather_data = GameData::BattleWeather.try_get(@field.weather)
    pbCommonAnimation(weather_data.animation) if weather_data
    case @field.weather
#    when :Sun         then pbDisplay(_INTL("The sunlight is strong."))
#    when :Rain        then pbDisplay(_INTL("Rain continues to fall."))
    when :Sandstorm   then pbDisplay(_INTL("The sandstorm is raging."))
    when :Hail        then pbDisplay(_INTL("The hail is crashing down."))
#    when :HarshSun    then pbDisplay(_INTL("The sunlight is extremely harsh."))
#    when :HeavyRain   then pbDisplay(_INTL("It is raining heavily."))
#    when :StrongWinds then pbDisplay(_INTL("The wind is strong."))
    when :ShadowSky   then pbDisplay(_INTL("The shadow sky continues."))
    end
    # Effects due to weather
    curWeather = pbWeather
    priority.each do |b|
      # Weather-related abilities
      if b.abilityActive?
        BattleHandlers.triggerEORWeatherAbility(b.ability,curWeather,b,self)
        b.pbFaint if b.fainted?
      end
      # Weather damage
      # NOTE:
      case curWeather
      when :Sandstorm
        next if !b.takesSandstormDamage?
        pbDisplay(_INTL("{1} is buffeted by the sandstorm!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :Hail
        next if !b.takesHailDamage?
        pbDisplay(_INTL("{1} is buffeted by the hail!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :ShadowSky
        next if !b.takesShadowSkyDamage?
        pbDisplay(_INTL("{1} is hurt by the shadow sky!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :Starstorm
        next if !b.takesStarstormDamage?
        pbDisplay(_INTL("{1} is hurt by the Starstorm!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :AcidRain
        next if !b.takesAcidRainDamage?
        pbDisplay(_INTL("{1} is scathed by Acid Rain!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :DWind
        next if !b.takesDWindDamage?
        pbDisplay(_INTL("{1} is whipped by the Distorted Wind!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :DustDevil
        next if !b.takesDustDevilDamage?
        pbDisplay(_INTL("{1} is buffeted by the Dust Devil!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :Sleet
        next if !b.takesHailDamage?
        pbDisplay(_INTL("{1} is buffeted by the Sleet!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/8,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :Windy
        next if !b.pbOwnSide.effects[PBEffects::StealthRock] && b.pbOwnSide.effects[PBEffects::Spikes] == 0 && !b.pbOwnSide.effects[PBEffects::CometShards] && !b.pbOwnSide.effects[PBEffects::StickyWeb] && b.pbOwnSide.effects[PBEffects::ToxicSpikes] == 0
        b.removeAllHazards
      end
    end
  end
end

module PokeBattle_BattleCommon
  def pbThrowPokeBall(idxBattler,ball,catch_rate=nil,showPlayer=false)
    # Determine which Pokémon you're throwing the Poké Ball at
    battler = nil
    if opposes?(idxBattler)
      battler = @battlers[idxBattler]
    else
      battler = @battlers[idxBattler].pbDirectOpposing(true)
    end
    if battler.fainted?
      battler.eachAlly do |b|
        battler = b
        break
      end
    end
    # Messages
    itemName = GameData::Item.get(ball).name
    if battler.fainted?
      if itemName.starts_with_vowel?
        pbDisplay(_INTL("{1} threw an {2}!",pbPlayer.name,itemName))
      else
        pbDisplay(_INTL("{1} threw a {2}!",pbPlayer.name,itemName))
      end
      pbDisplay(_INTL("But there was no target..."))
      return
    end
    if itemName.starts_with_vowel?
      pbDisplayBrief(_INTL("{1} threw an {2}!",pbPlayer.name,itemName))
    else
      pbDisplayBrief(_INTL("{1} threw a {2}!",pbPlayer.name,itemName))
    end
    # Animation of opposing trainer blocking Poké Balls (unless it's a Snag Ball
    # at a Shadow Pokémon)
    if trainerBattle? && !(GameData::Item.get(ball).is_snag_ball? && battler.shadowPokemon?)
      @scene.pbThrowAndDeflect(ball,1)
      pbDisplay(_INTL("The Trainer blocked your Poké Ball! Don't be a thief!"))
      return
    end
    # Calculate the number of shakes (4=capture)
    pkmn = battler.pokemon
    @criticalCapture = false
    numShakes = pbCaptureCalc(pkmn,battler,catch_rate,ball)
    PBDebug.log("[Threw Poké Ball] #{itemName}, #{numShakes} shakes (4=capture)")
    # Animation of Ball throw, absorb, shake and capture/burst out
    @scene.pbThrow(ball,numShakes,@criticalCapture,battler.index,showPlayer)
    # Ball Fetch
    
    # Outcome message
    case numShakes
    when 0
      pbDisplay(_INTL("Oh no! The Pokémon broke free!"))
      BallHandlers.onFailCatch(ball,self,battler)
    when 1
      pbDisplay(_INTL("Aww! It appeared to be caught!"))
      BallHandlers.onFailCatch(ball,self,battler)
    when 2
      pbDisplay(_INTL("Aargh! Almost had it!"))
      BallHandlers.onFailCatch(ball,self,battler)
    when 3
      pbDisplay(_INTL("Gah! It was so close, too!"))
      BallHandlers.onFailCatch(ball,self,battler)
    when 4
      pbDisplayBrief(_INTL("Gotcha! {1} was caught!",pkmn.name))
      @scene.pbThrowSuccess   # Play capture success jingle
      pbRemoveFromParty(battler.index,battler.pokemonIndex)
      # Gain Exp
      if Settings::GAIN_EXP_FOR_CAPTURE
        battler.captured = true
        pbGainExp
        battler.captured = false
      end
      battler.pbReset
      if pbAllFainted?(battler.index)
        @decision = (trainerBattle?) ? 1 : 4   # Battle ended by win/capture
      end
      # Modify the Pokémon's properties because of the capture
      if GameData::Item.get(ball).is_snag_ball?
        pkmn.owner = Pokemon::Owner.new_from_trainer(pbPlayer)
      end
      BallHandlers.onCatch(ball,self,pkmn)
      pkmn.poke_ball = ball
      pkmn.makeUnmega if pkmn.mega?
      pkmn.makeUnprimal
      pkmn.update_shadow_moves if pkmn.shadowPokemon?
      pkmn.record_first_moves
      if $game_switches[75]
        for key in pkmn.iv.keys
          pkmn.iv[key] = 31
        end
      end
      # Reset form
      pkmn.forced_form = nil if MultipleForms.hasFunction?(pkmn.species,"getForm")
      @peer.pbOnLeavingBattle(self,pkmn,true,true)
      # Make the Poké Ball and data box disappear
      @scene.pbHideCaptureBall(idxBattler)
      pbSetBattled(battler)
      # Save the Pokémon for storage at the end of battle
      @caughtPokemon.push(pkmn)
    end
  end
end