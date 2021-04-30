#===================================
# Level Cap Scripts
#===================================
Events.onMapChange += proc {| sender, e |
  badges = $Trainer.badge_count
  if $game_switches[112] == true
    if badges == 0
      $game_variables[106] = 15
    elsif badges == 1
      $game_variables[106] = 22
    elsif badges == 2
      $game_variables[106] = 27
    elsif badges == 3
      $game_variables[106] = 32
    elsif badges == 4
      if $game_variables[110] == 6
        $game_variables[106] = 64
      elsif $game_variables[110] == 5
        $game_variables[106] = 61
      elsif $game_variables[110] == 4
        $game_variables[106] = 58
      elsif $game_variables[110] == 3
        $game_variables[106] = 55
      elsif $game_variables[110] == 2
        $game_variables[106] = 46
      elsif $game_variables[110] == 1
        $game_variables[106] = 43
      else
      $game_variables[106] = 40
      end
    elsif badges == 5
      if $game_variables[110] == 9
        $game_variables[106] = 78
      elsif $game_variables[110] == 8
        $game_variables[106] = 75
      elsif $game_variables[110] == 7
        $game_variables[106] = 72
      else
      $game_variables[106] = 68
      end
    elsif badges == 6
      $game_variables[106] = 81
    elsif badges == 7
      if $game_variables[110] == 13
        $game_variables[106] = 95
      elsif $game_variables[110] == 12
        $game_variables[106] = 93
      elsif $game_variables[110] == 11
        $game_variables[106] = 90
      elsif $game_variables[110] == 10
        $game_variables[106] = 87
      else
      $game_variables[106] = 84
      end
    elsif badges == 8
    if $game_variables[110] == 14
      $game_variables[106] = 120
    else
      $game_variables[106] = 100
    end
    elsif $game_switches[12] == true
      $game_variables[106] = 150
    end
  end
    $game_switches[350] = false
    #$game_switches[184] = true
    if $game_switches[142] == false && $game_switches[128] == true
        $game_switches[141] = true
    end
    if $game_switches[141] == true && $game_switches[142] == false
        pbMessage(_INTL("You are now ready to play past the demo! Go to Mauselynx Alley to continue your journey!"))
        $game_switches[142] = true
    end
    if $game_switches[184] == true && $game_switches[187] == false && $game_switches[161] == true
      pbMessage(_INTL("Victory Road is now open to you! Go complete your journey!"))
      $game_switches[187] = true
    end
    # Weather Setting
    time = pbGetTimeNow
    $game_variables[99] = time.day
    dailyWeather = $game_variables[27]
    if $game_variables[28] > $game_variables[99] || $game_variables[28]<$game_variables[99]
      $game_variables[27] = 1+rand(100)
      $game_variables[28] = $game_variables[99]
    end
}

Events.onStepTaken += proc {| sender, e |
  badges = $Trainer.badge_count
  if $game_switches[112] == true
    if badges == 0
      $game_variables[106] = 15
    elsif badges == 1
      $game_variables[106] = 22
    elsif badges == 2
      $game_variables[106] = 27
    elsif badges == 3
      $game_variables[106] = 32
    elsif badges == 4
      if $game_variables[110] == 6
        $game_variables[106] = 64
      elsif $game_variables[110] == 5
        $game_variables[106] = 61
      elsif $game_variables[110] == 4
        $game_variables[106] = 58
      elsif $game_variables[110] == 3
        $game_variables[106] = 55
      elsif $game_variables[110] == 2
        $game_variables[106] = 46
      elsif $game_variables[110] == 1
        $game_variables[106] = 43
      else
      $game_variables[106] = 40
      end
    elsif badges == 5
      if $game_variables[110] == 9
        $game_variables[106] = 78
      elsif $game_variables[110] == 8
        $game_variables[106] = 75
      elsif $game_variables[110] == 7
        $game_variables[106] = 72
      else
      $game_variables[106] = 68
      end
    elsif badges == 6
      $game_variables[106] = 81
    elsif badges == 7
      if $game_variables[110] == 13
        $game_variables[106] = 95
      elsif $game_variables[110] == 12
        $game_variables[106] = 93
      elsif $game_variables[110] == 11
        $game_variables[106] = 90
      elsif $game_variables[110] == 10
        $game_variables[106] = 87
      else
      $game_variables[106] = 84
      end
    elsif badges == 8
    if $game_variables[110] == 14
      $game_variables[106] = 120
    else
      $game_variables[106] = 100
    end
    elsif $game_switches[12] == true
      $game_variables[106] = 150
    end
  end
}
#===================================
# Mid Battle Status Scripts
#===================================
def poisonAllPokemon(event=nil)
    for pkmn in $Trainer.ablePokemonParty
       next if pkmn.hasType?(:POISON)  || pkmn.hasType?(:STEEL) ||
          pkmn.hasAbility?(:COMATOSE)  || pkmn.hasAbility?(:SHIELDSDOWN) || pkmn.hasAbility?(:IMMUNITY)
          pkmn.status!=0
       pkmn.status = 2
       pkmn.statusCount = 1
     end
end

def paralyzeAllPokemon(event=nil)
    for pkmn in $Trainer.ablePokemonParty
       next if pkmn.hasType?(:ELECTRIC) ||
          pkmn.hasAbility?(:COMATOSE)  || pkmn.hasAbility?(:SHIELDSDOWN) || pkmn.hasAbility?(:LIMBER)
          pkmn.status!=0
       pkmn.status = 4
     end
end

def burnAllPokemon(event=nil)
    for pkmn in $Trainer.ablePokemonParty
       next if pkmn.hasType?(:FIRE) ||
          pkmn.hasAbility?(:COMATOSE)  || pkmn.hasAbility?(:SHIELDSDOWN) || pkmn.hasAbility?(:WATERBUBBLE) || pkmn.hasAbility?(:WATERVEIL)
          pkmn.status!=0
       pkmn.status = 3
     end
end
#===================================
# Weather Scripts
#===================================
GameData::Weather.register({
  :id               => :AcidRain,
  :id_number        => 17,
  :category         => :AcidRain,
  :graphics         => [["acidrain_1", "acidrain_2", "acidrain_3", "acidrain_4"]],   # Last is splash
  :particle_delta_x => -300,
  :particle_delta_y => 1200,
  :tone_proc        => proc { |strength|
    next Tone.new(-strength * 3 / 4, -strength * 3 / 4, -strength * 3 / 4, 10)
  }
})
GameData::Weather.register({
  :id               => :VolcanicAsh,
  :id_number        => 27,
  :category         => :VolcanicAsh,
  :graphics         => [["volc_1", "volc_2", "volc_3"]],
  :particle_delta_x => -120,
  :particle_delta_y => 120,
  :tone_proc        => proc { |strength|
    next Tone.new(-strength * 3 / 4, -strength * 3 / 4, -strength * 3 / 4, 20)
  }
})
GameData::Weather.register({
  :id               => :DAshfall,
  :id_number        => 25,
  :category         => :DAshfall,
  :graphics         => [["volc_1", "volc_2", "volc_3"]],
  :particle_delta_x => -2400,
  :particle_delta_y => -480,
  :tone_proc        => proc { |strength|
    next Tone.new(-strength * 6 / 4, -strength * 6 / 4, -strength * 6 / 4, 20)
  }
})
GameData::Weather.register({
  :id               => :Starstorm,
  :id_number        => 9,
  :category         => :Starstorm,
  :graphics         => [["hail_1", "hail_2", "hail_3"]],
  :particle_delta_x => -240,
  :particle_delta_y => 10,
  :tone_proc        => proc { |strength|
    next Tone.new(-strength * 3 / 2, -strength * 3 / 2, -strength * 3 / 2, 20)
  }
})
GameData::Weather.register({
  :id               => :HarshSun,
  :id_number        => 31,
  :category         => :HarshSun,
  :tone_proc        => proc { |strength|
    next Tone.new(172, 64, 32, 0)
  }
})
GameData::Weather.register({
  :id               => :Overcast,
  :id_number        => 8,
  :category         => :Overcast,
  :tone_proc        => proc{ |strength|
    next Tone.new(-strength * 6 / 4, -strength * 6 / 4, -strength * 6 / 4, 20)
  }
})
GameData::Weather.register({
  :id               => :Eclipse,
  :id_number        => 13,
  :category         => :Eclipse,
  :tone_proc        => proc{ |strength|
    next Tone.new(-strength * 11 / 4, -strength * 11 / 4, -strength * 11 / 4, 20)
  }
})
GameData::Weather.register({
  :id               => :Windy,
  :id_number        => 15,   # Must be 1 (preset RMXP weather)
  :category         => :Windy,
  :graphics         => [["windy_1", "windy_2", "windy_3"]],   # Last is splash
  :particle_delta_x => -120,
  :particle_delta_y => 10,
  :tone_proc        => proc { |strength|
    next Tone.new(-strength * 3 / 4, -strength * 3 / 4, -strength * 3 / 4, 20)
  }
})
GameData::Weather.register({
  :id               => :Humid,
  :id_number        => 18,
  :category         => :Humid,
  :graphics         => [["hail_1", "hail_2", "hail_3"]],
  :particle_delta_x => -10,
  :particle_delta_y => 10,
  :tone_proc        => proc { |strength|
    next Tone.new(0,128,45,0)
  }
})
GameData::Weather.register({
  :id               => :Sleet,
  :id_number        => 11,
  :category         => :Sleet,
  :graphics         => [["blizzard_1", "blizzard_2", "blizzard_3", "blizzard_4"], ["blizzard_tile"]],
  :particle_delta_x => -960,
  :particle_delta_y => 240,
  :tile_delta_x     => -1440,
  :tile_delta_y     => 0,
  :tone_proc        => proc { |strength|
    next Tone.new(strength * 3 / 4, strength * 3 / 4, strength * 3 / 4, 0)
  }
})
GameData::Weather.register({
  :id               => :Storm,
  :id_number        => 2,   # Must be 2 (preset RMXP weather)
  :category         => :Storm,
  :graphics         => [["storm_1", "storm_2", "storm_3", "storm_4"]],   # Last is splash
  :particle_delta_x => -4800,
  :particle_delta_y => 4800,
  :tone_proc        => proc { |strength|
    next Tone.new(-strength * 3 / 2, -strength * 3 / 2, -strength * 3 / 2, 20)
  }
})
GameData::Weather.register({
  :id               => :DustDevil,
  :id_number        => 22,
  :category         => :DustDevil,
  :graphics         => [["sandstorm_1", "sandstorm_2", "sandstorm_3", "sandstorm_4"], ["sandstorm_tile"]],
  :particle_delta_x => -150,
  :particle_delta_y => -15,
  :tile_delta_x     => -320,
  :tile_delta_y     => 0,
  :tone_proc        => proc { |strength|
    next Tone.new(strength / 2, 0, -strength / 2, 0)
  }
})
GameData::Weather.register({
  :id               => :StrongWinds,
  :id_number        => 15,   # Must be 1 (preset RMXP weather)
  :category         => :StrongWinds,
  :graphics         => [["windy_1", "windy_2", "windy_3"]],   # Last is splash
  :particle_delta_x => -650,
  :particle_delta_y => 20,
  :tone_proc        => proc { |strength|
    next Tone.new(0,76,36,15)
  }
})
GameData::Weather.register({
  :id               => :Fog,
  :category         => :Fog,
  :id_number        => 12,
  :tile_delta_x     => -32,
  :tile_delta_y     => 0,
  :graphics         => [nil, ["fog_tile"]]
})
GameData::Weather.register({
  :id               => :HeatLight,
  :id_number        => 20,   # Must be 2 (preset RMXP weather)
  :category         => :HeatLight,
  :tone_proc        => proc { |strength|
    next Tone.new(255,0,0,100)
  }
})
GameData::Weather.register({
  :id               => :Borealis,
  :id_number        => 28,
  :category         => :Borealis,
  :graphics         => [["hail_1", "hail_2", "hail_3"]],
  :particle_delta_x => -10,
  :particle_delta_y => 10,
  :tone_proc        => proc { |strength|
    next Tone.new(64,0,255,15)
  }
})
GameData::Weather.register({
  :id               => :TimeWarp,
  :id_number        => 29,
  :category         => :TimeWarp,
  :tone_proc        => proc { |strength|
    next Tone.new(20,-74,-60,0)
  }
})
GameData::Weather.register({
  :id               => :Reverb,
  :id_number        => 30,
  :category         => :Reverb,
  :tone_proc        => proc { |strength|
    next Tone.new(20,44,80,0)
  }
})

GameData::BattleWeather.register({
  :id        => :Starstorm,
  :name      => _INTL("Starstorm"),
  :animation => "ShadowSky"
})
GameData::BattleWeather.register({
  :id        => :Overcast,
  :name      => _INTL("Overcast"),
})
GameData::BattleWeather.register({
  :id        => :Sleet,
  :name      => _INTL("Sleet"),
  :animation => "Hail"
})
GameData::BattleWeather.register({
  :id        => :Fog,
  :name      => _INTL("Fog"),
  :animation => "Fog"
})
GameData::BattleWeather.register({
  :id        => :Eclipse,
  :name      => _INTL("Eclipse"),
  :animation => "ShadowSky"
})
GameData::BattleWeather.register({
  :id        => :Windy,
  :name      => _INTL("Windy"),
})
GameData::BattleWeather.register({
  :id        => :Storm,
  :name      => _INTL("Storm"),
  :animation => "HeavyRain"
})
GameData::BattleWeather.register({
  :id        => :AcidRain,
  :name      => _INTL("Acid Rain"),
  :animation => "Rain"
})
GameData::BattleWeather.register({
  :id        => :Humid,
  :name      => _INTL("Humid"),
})
GameData::BattleWeather.register({
  :id        => :HeatLight,
  :name      => _INTL("Heat Lightning"),
})
GameData::BattleWeather.register({
  :id        => :Rainbow,
  :name      => _INTL("Rainbow"),
})
GameData::BattleWeather.register({
  :id        => :DustDevil,
  :name      => _INTL("Dust Devil"),
  :animation => "Sandstorm"
})
GameData::BattleWeather.register({
  :id        => :DAshfall,
  :name      => _INTL("Distorted Ashfall")
})
GameData::BattleWeather.register({
  :id        => :VolcanicAsh,
  :name      => _INTL("Volcanic Ash"),
})
GameData::BattleWeather.register({
  :id        => :Borealis,
  :name      => _INTL("Northern Lights"),
})
GameData::BattleWeather.register({
  :id        => :TimeWarp,
  :name      => _INTL("Temporal Rift"),
})
GameData::BattleWeather.register({
  :id        => :Reverb,
  :name      => _INTL("Echo Chamber"),
})

class PokeBattle_Battle
  def removeAllHazards
    if @battlers[0].pbOwnSide.effects[PBEffects::StealthRock] || @battlers[0].pbOpposingSide.effects[PBEffects::StealthRock]
      @battlers[0].pbOwnSide.effects[PBEffects::StealthRock]      = false
      @battlers[0].pbOpposingSide.effects[PBEffects::StealthRock] = false
    end
    if @battlers[0].pbOwnSide.effects[PBEffects::Spikes]>0 || @battlers[0].pbOpposingSide.effects[PBEffects::Spikes]>0
      @battlers[0].pbOwnSide.effects[PBEffects::Spikes]      = 0
      @battlers[0].pbOpposingSide.effects[PBEffects::Spikes] = 0
    end
    if @battlers[0].pbOwnSide.effects[PBEffects::CometShards] || @battlers[0].pbOpposingSide.effects[PBEffects::CometShards]
      @battlers[0].pbOwnSide.effects[PBEffects::CometShards]      = false
      @battlers[0].pbOpposingSide.effects[PBEffects::CometShards] = false
    end
    if @battlers[0].pbOwnSide.effects[PBEffects::ToxicSpikes]>0 || @battlers[0].pbOpposingSide.effects[PBEffects::ToxicSpikes]>0
      @battlers[0].pbOwnSide.effects[PBEffects::ToxicSpikes]      = 0
      @battlers[0].pbOpposingSide.effects[PBEffects::ToxicSpikes] = 0
    end
    if @battlers[0].pbOwnSide.effects[PBEffects::StickyWeb] || @battlers[0].pbOpposingSide.effects[PBEffects::StickyWeb]
      @battlers[0].pbOwnSide.effects[PBEffects::StickyWeb]      = false
      @battlers[0].pbOpposingSide.effects[PBEffects::StickyWeb] = false
    end
  end

  def pbStartWeather(user,newWeather,fixedDuration=false,showAnim=true)
    return if @field.weather==newWeather
    @field.weather = newWeather
    duration = (fixedDuration) ? 5 : -1
    if duration>0 && user && user.itemActive?
      duration = BattleHandlers.triggerWeatherExtenderItem(user.item,
         @field.weather,duration,user,self)
    end
    @field.weatherDuration = duration
    weather_data = GameData::BattleWeather.try_get(@field.weather)
    pbCommonAnimation(weather_data.animation) if showAnim && weather_data
    pbHideAbilitySplash(user) if user
    case @field.weather
    when :Sun         then pbDisplay(_INTL("The sunlight turned harsh!"))
    when :Rain        then pbDisplay(_INTL("It started to rain!"))
    when :Sandstorm   then pbDisplay(_INTL("A sandstorm brewed!"))
    when :Hail        then pbDisplay(_INTL("It started to hail!"))
    when :HarshSun    then pbDisplay(_INTL("The sunlight turned extremely harsh!"))
    when :HeavyRain   then pbDisplay(_INTL("A heavy rain began to fall!"))
    when :StrongWinds then pbDisplay(_INTL("Mysterious strong winds are protecting Flying-type Pokémon!"))
    when :ShadowSky   then pbDisplay(_INTL("A shadow sky appeared!"))
    when :Starstorm   then pbDisplay(_INTL("Stars fill the sky."))
    when :Thunder     then pbDisplay(_INTL("Lightning flashes in th sky."))
    when :Storm       then pbDisplay(_INTL("A thunderstorm rages. The ground became electrified!"))
    when :Humid       then pbDisplay(_INTL("The air is humid."))
    when :Overcast    then pbDisplay(_INTL("The sky is overcast."))
    when :Eclipse     then pbDisplay(_INTL("The sky is dark."))
    when :Fog         then pbDisplay(_INTL("The fog is deep."))
    when :AcidRain    then pbDisplay(_INTL("Acid rain is falling."))
    when :VolcanicAsh then pbDisplay(_INTL("Volcanic Ash sprinkles down."))
    when :Rainbow     then pbDisplay(_INTL("A rainbow crosses the sky."))
    when :Borealis    then pbDisplay(_INTL("The sky is ablaze with color."))
    when :TimeWarp    then pbDisplay(_INTL("Time has stopped."))
    when :Reverb      then pbDisplay(_INTL("A dull echo hums."))
    when :DClear      then pbDisplay(_INTL("The sky is distorted."))
    when :DRain       then pbDisplay(_INTL("Rain is falling upward."))
    when :DWind       then pbDisplay(_INTL("The wind is haunting."))
    when :DAshfall    then pbDisplay(_INTL("Ash floats in midair."))
    when :Sleet       then pbDisplay(_INTL("Sleet began to fall."))
    when :Windy       then pbDisplay(_INTL("There is a slight breeze."))
    when :HeatLight   then pbDisplay(_INTL("Static fills the air."))
    when :DustDevil   then pbDisplay(_INTL("A dust devil approaches."))
    end
    # Check for end of primordial weather, and weather-triggered form changes
    eachBattler { |b| b.pbCheckFormOnWeatherChange }
    pbEndPrimordialWeather
  end

  def pbEndPrimordialWeather
    oldWeather = @field.weather
    # End Primordial Sea, Desolate Land, Delta Stream
    case @field.weather
    when :HarshSun
      if !pbCheckGlobalAbility(:DESOLATELAND) && @field.defaultWeather != :HarshSun
        @field.weather = :None
        pbDisplay("The harsh sunlight faded!")
      end
    when :HeavyRain
      if !pbCheckGlobalAbility(:PRIMORDIALSEA) && @field.defaultWeather != :HeavyRain
        @field.weather = :None
        pbDisplay("The heavy rain has lifted!")
      end
    when :StrongWinds
      if !pbCheckGlobalAbility(:DELTASTREAM)  && @field.defaultWeather != :StrongWinds
        @field.weather = :None
        pbDisplay("The mysterious air current has dissipated!")
      end
    end
    if @field.weather!=oldWeather
      # Check for form changes caused by the weather changing
      eachBattler { |b| b.pbCheckFormOnWeatherChange }
      # Start up the default weather
      pbStartWeather(nil,@field.defaultWeather) if @field.defaultWeather != :None
    end
  end

  def pbItemMenu(idxBattler,firstAction)
    if !@internalBattle || @opponent
      pbDisplay(_INTL("Items can't be used here."))
      return false
    end
    ret = false
    @scene.pbItemMenu(idxBattler,firstAction) { |item,useType,idxPkmn,idxMove,itemScene|
      next false if !item
      battler = pkmn = nil
      case useType
      when 1, 2, 6, 7   # Use on Pokémon/Pokémon's move
        next false if !ItemHandlers.hasBattleUseOnPokemon(item)
        battler = pbFindBattler(idxPkmn,idxBattler)
        pkmn    = pbParty(idxBattler)[idxPkmn]
        next false if !pbCanUseItemOnPokemon?(item,pkmn,battler,itemScene)
      when 3, 8   # Use on battler
        next false if !ItemHandlers.hasBattleUseOnBattler(item)
        battler = pbFindBattler(idxPkmn,idxBattler)
        pkmn    = battler.pokemon if battler
        next false if !pbCanUseItemOnPokemon?(item,pkmn,battler,itemScene)
      when 4, 9   # Poké Balls
        next false if idxPkmn<0
        battler = @battlers[idxPkmn]
        pkmn    = battler.pokemon if battler
      when 5, 10   # No target (Poké Doll, Guard Spec., Launcher items)
        battler = @battlers[idxBattler]
        pkmn    = battler.pokemon if battler
      else
        next false
      end
      next false if !pkmn
      next false if !ItemHandlers.triggerCanUseInBattle(item,
         pkmn,battler,idxMove,firstAction,self,itemScene)
      next false if !pbRegisterItem(idxBattler,item,idxPkmn,idxMove)
      ret = true
      next true
    }
    return ret
  end
end

Settings::TIME_SHADING = false
Settings::SPEECH_WINDOWSKINS = [
#    "speech hgss 1",
#    "speech hgss 2",
#    "speech hgss 3",
#    "speech hgss 4",
#    "speech hgss 5",
#    "speech hgss 6",
#    "speech hgss 7",
#    "speech hgss 8",
#    "speech hgss 9",
#    "speech hgss 10",
#    "speech hgss 11",
#    "speech hgss 12",
#    "speech hgss 13",
#    "speech hgss 14",
#    "speech hgss 15",
#    "speech hgss 16",
#    "speech hgss 17",
#    "speech hgss 18",
#    "speech hgss 19",
#    "speech hgss 20",
#    "speech pl 18",
    "frlgtextskin"
  ]
Settings::MENU_WINDOWSKINS = [
#    "choice 1",
#    "choice 2",
#    "choice 3",
#    "choice 4",
#    "choice 5",
#    "choice 6",
#    "choice 7",
#    "choice 8",
#    "choice 9",
#    "choice 10",
#    "choice 11",
#    "choice 12",
#    "choice 13",
#    "choice 14",
#    "choice 15",
#    "choice 16",
#    "choice 17",
#    "choice 18",
#    "choice 19",
#    "choice 20",
#    "choice 21",
#    "choice 22",
#    "choice 23",
#    "choice 24",
#    "choice 25",
#    "choice 26",
#    "choice 27",
#    "choice 28",
    "frlgtextskin"
  ]
Settings::FIELD_MOVES_COUNT_BADGES = false
Settings::MAXIMUM_LEVEL = 200
Settings::GAME_VERSION = "0.9.0"

module Settings
  def self.storage_creator_name
    return _INTL("Lyptus")
  end

  def self.pokedex_names
    return [
      [_INTL("Zharo Pokédex"), 0],
      _INTL("National Pokédex")
    ]
  end
end

begin
  module PBFieldWeather
    None        = 0   # None must be 0 (preset RMXP weather)
    Rain        = 1   # Rain must be 1 (preset RMXP weather)
    Storm       = 2   # Storm must be 2 (preset RMXP weather)
    Snow        = 3   # Snow must be 3 (preset RMXP weather)
    Blizzard    = 4
    Sandstorm   = 5
    HeavyRain   = 6
    Sun = Sunny = 7 #8 is ShadowSky so we leave that blank
    ShadowSky   = 8
    Starstorm   = 9
    Overcast    = 10
    Sleet       = 11
    Fog         = 12
    Eclipse     = 13
    StrongWinds = 14
    Windy       = 15
    Thunder     = 16 # Thunderstorm
    AcidRain    = 17
    Humid       = 18
    Supercell   = 19
    HeatLight   = 20 # Heat Lightning
    Rainbow     = 21
    DustDevil   = 22
    DClear      = 23 # Distortion World - Clear
    DWind       = 24 # Distortion World - Windy
    DAshfall    = 25 # Distortion World - Ashfall
    DRain       = 26 # Distortion World - Rain
    VolcanicAsh = 27
    Borealis    = 28 # Northern Lights
    TimeWarp    = 29
    Reverb      = 30
    HarshSun    = 31

    def PBFieldWeather.maxValue; return 31; end
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end

module Readouts
  Count = 29
  Rain = 52
  Hail = 53
  Sun = 54
  Sand = 55
  HeavyRain = 56
  HarshSun = 57
  StrongWinds = 58
  Starstorm = 59
  Overcast = 60
  Sleet = 75
  Fog = 72
  Eclipse = 61
  Windy = 63
  AcidRain = 62
  Humid = 65
  HeatLightning = 64
  Rainbow = 66
  DustDevil = 67
  DClear = 68
  DRain = 70
  DWind = 69
  DAshfall = 71
  VolcanicAsh = 73
  NorthernLights = 74
  TemporalRift = 111
  EchoChamber = 112
  Readout = 400
end

def hasReadout?
  return $game_switches[Readouts::Readout]
end

def pbReadout(text)
  if hasReadout? == false
    pbMessage(_INTL("You do not have the Weather Reader to install this Readout into!"))
  else
    case text
    when "Rain"
      readoutName = text
      $game_variables[Readouts::Rain] = 1
    when "Hail"
      readoutName = text
      $game_variables[Readouts::Hail] = 1
    when "Sun"
      readoutName = text
      $game_variables[Readouts::Sun] = 1
    when "Sandstorm"
      readoutName = text
      $game_variables[Readouts::Sand] = 1
    when "Sleet"
      readoutName = text
      $game_variables[Readouts::Sleet] = 1
    when "Starstorm"
      readoutName = text
      $game_variables[Readouts::Starstorm] = 1
    when "Overcast"
      readoutName = text
      $game_variables[Readouts::Overcast] = 1
    when "Humid"
      readoutName = text
      $game_variables[Readouts::Humid] = 1
    when "Fog"
      readoutName = text
      $game_variables[Readouts::Fog] = 1
    when "Windy"
      readoutName = text
      $game_variables[Readouts::Windy] = 1
    when "Eclipse"
      readoutName = text
      $game_variables[Readouts::Eclipse] = 1
    when "Rainbow"
      readoutName = text
      $game_variables[Readouts::Rainbow] = 1
    when "HeavyRain"
      readoutName = "Heavy Rain"
      $game_variables[Readouts::HeavyRain] = 1
    when "HarshSun"
      readoutName = "Harsh Sun"
      $game_variables[Readouts::HarshSun] = 1
    when "StrongWinds"
      readoutName = "Strong Winds"
      $game_variables[Readouts::StrongWinds] = 1
    when "AcidRain"
      readoutName = "Acid Rain"
      $game_variables[Readouts::AcidRain] = 1
    when "HeatLightning"
      readoutName = "Heat Lightning"
      $game_variables[Readouts::HeatLightning] = 1
    when "DustDevil"
      readoutName = "Dust Devil"
      $game_variables[Readouts::DustDevil] = 1
    when "DAshfall"
      readoutName = "Distorted Ashfall"
      $game_variables[Readouts::DAshfall] = 1
    when "VolcanicAsh"
      readoutName = "Volcanic Ash"
      $game_variables[Readouts::VolcanicAsh] = 1
    when "NorthernLights"
      readoutName = "Northern Lights"
      $game_variables[Readouts::NorthernLights] = 1
    when "TemporalRift"
      readoutName = "Temporal Rift"
      $game_variables[Readouts::TemporalRift] = 1
    when "EchoChamber"
      readoutName = "Echo Chamber"
      $game_variables[Readouts::EchoChamber] = 1
    end
    meName = "Key item get"
    pbMessage(_INTL("\\me[{1}]\\PN found a Readout for \\c[1]{2}\\c[0] Weather!\\wtnp[30]",meName,readoutName))
    pbMessage(_INTL("\\PN installed it into the \\c[1]Weather Reader\\c[0]!"))
    $game_variables[Readouts::Count] += 1
    if $game_variables[Readouts::Count] == 24
      meComplete = "Voltorb flip win"
      pbMessage(_INTL("\\me[{1}]\\PN has found all of the \\c[1]Weather Readouts\\c[0]!"))
      completeQuest(0)
    end
    pbSetSelfSwitch(@event_id,"A",true)
  end
end

class PokemonLoadScreen
  def initialize(scene)
    @scene = scene
    if SaveData.exists?
      @save_data = load_save_file(SaveData::FILE_PATH)
    else
      @save_data = {}
    end
  end

  # @param file_path [String] file to load save data from
  # @return [Hash] save data
  def load_save_file(file_path)
    save_data = SaveData.read_from_file(file_path)
    unless SaveData.valid?(save_data)
      if File.file?(file_path + '.bak')
        pbMessage(_INTL('The save file is corrupt. A backup will be loaded.'))
        save_data = load_save_file(file_path + '.bak')
      else
        self.prompt_save_deletion
        return {}
      end
    end
    return save_data
  end

  # Called if all save data is invalid.
  # Prompts the player to delete the save files.
  def prompt_save_deletion
    pbMessage(_INTL('The save file is corrupt, or is incompatible with this game.'))
    exit unless pbConfirmMessageSerious(
      _INTL('Do you want to delete the save file and start anew?')
    )
    self.delete_save_data
    $game_system   = Game_System.new
    $PokemonSystem = PokemonSystem.new
  end

  def pbStartDeleteScreen
    @scene.pbStartDeleteScene
    @scene.pbStartScene2
    if SaveData.exists?
      if pbConfirmMessageSerious(_INTL("Delete all saved data?"))
        pbMessage(_INTL("Once data has been deleted, there is no way to recover it.\1"))
        if pbConfirmMessageSerious(_INTL("Delete the saved data anyway?"))
          pbMessage(_INTL("Deleting all data. Don't turn off the power.\\wtnp[0]"))
          self.delete_save_data
        end
      end
    else
      pbMessage(_INTL("No save file was found."))
    end
    @scene.pbEndScene
    $scene = pbCallTitle
  end

  def delete_save_data
    begin
      SaveData.delete_file
      pbMessage(_INTL('The saved data was deleted.'))
    rescue SystemCallError
      pbMessage(_INTL('All saved data could not be deleted.'))
    end
  end

  def pbStartLoadScreen
    commands = []
    cmd_continue     = -1
    cmd_new_game     = -1
    cmd_options      = -1
    cmd_language     = -1
    cmd_mystery_gift = -1
    cmd_debug        = -1
    cmd_quit         = -1
    show_continue = !@save_data.empty?
    if show_continue
      commands[cmd_continue = commands.length] = _INTL('Continue')
      if @save_data[:player].mystery_gift_unlocked
        commands[cmd_mystery_gift = commands.length] = _INTL('Mystery Gift')
      end
    end
    commands[cmd_new_game = commands.length]  = _INTL('New Game')
    commands[cmd_options = commands.length]   = _INTL('Options')
    commands[cmd_language = commands.length]  = _INTL('Language') if Settings::LANGUAGES.length >= 2
    commands[cmd_debug = commands.length]     = _INTL('Debug') if $DEBUG
    commands[cmd_quit = commands.length]      = _INTL('Quit Game')
    map_id = show_continue ? @save_data[:map_factory].map.map_id : 0
    @scene.pbStartScene(commands, show_continue, @save_data[:player],
                        @save_data[:frame_count] || 0, map_id)
    @scene.pbSetParty(@save_data[:player]) if show_continue
    @scene.pbStartScene2
    loop do
      command = @scene.pbChoose(commands)
      pbPlayDecisionSE if command != cmd_quit
      case command
      when cmd_continue
        $currentDexSearch = nil
        @scene.pbEndScene
        Game.load(@save_data)
        return
      when cmd_new_game
        @scene.pbEndScene
        Game.start_new
        return
      when cmd_mystery_gift
        pbFadeOutIn { pbDownloadMysteryGift(@save_data[:player]) }
      when cmd_options
        pbFadeOutIn do
          scene = PokemonOption_Scene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen(true)
        end
      when cmd_language
        @scene.pbEndScene
        $PokemonSystem.language = pbChooseLanguage
        pbLoadMessages('Data/' + Settings::LANGUAGES[$PokemonSystem.language][1])
        if show_continue
          @save_data[:pokemon_system] = $PokemonSystem
          File.open(SaveData::FILE_PATH, 'wb') { |file| Marshal.dump(@save_data, file) }
        end
        $scene = pbCallTitle
        return
      when cmd_debug
        pbFadeOutIn { pbDebugMenu(false) }
      when cmd_quit
        pbPlayCloseMenuSE
        @scene.pbEndScene
        $scene = nil
        return
      else
        pbPlayBuzzerSE
      end
    end
  end
end

class PokemonWeather_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(commands)
    @commands = commands
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/bg")
    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(
       _INTL("Weather Reader"),2,-18,256,64,@viewport)
    @sprites["header"].baseColor   = Color.new(248,248,248)
    @sprites["header"].shadowColor = Color.new(0,0,0)
    @sprites["header"].windowskin  = nil
    @sprites["commands"] = Window_CommandPokemon.newWithSize(@commands,
       94,92,324,224,@viewport)
    @sprites["commands"].baseColor   = Color.new(248,248,248)
    @sprites["commands"].shadowColor = Color.new(0,0,0)
    @sprites["commands"].windowskin = nil
    pbFadeInAndShow(@sprites) { pbUpdate }
  end


  def pbScene
    ret = -1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::B)
        break
      elsif Input.trigger?(Input::C)
        ret = @sprites["commands"].index
        break
      end
    end
    return ret
  end

  def pbSetCommands(newcommands,newindex)
    @sprites["commands"].commands = (!newcommands) ? @commands : newcommands
    @sprites["commands"].index    = newindex
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class PokemonWeatherScreen

  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    commands = []
    cmdNone    = -1
    cmdRain    = -1
    cmdSnow    = -1
    cmdSun     = -1
    cmdSand    = -1
    cmdHeavyR  = -1
    cmdHarshS  = -1
    cmdDelta   = -1
    cmdStar    = -1
    cmdOver    = -1
    cmdSleet   = -1
    cmdFog     = -1
    cmdEclipse = -1
    cmdWindy   = -1
    cmdAcidR   = -1
    cmdHumid   = -1
    cmdHeatL   = -1
    cmdRainbow = -1
    cmdDust    = -1
    cmdDClear  = -1
    cmdDRain   = -1
    cmdDWind   = -1
    cmdDAsh    = -1
    cmdVolc    = -1
    cmdNLight  = -1
    cmdRift    = -1
    cmdEcho    = -1
    commands[cmdNone = commands.length]   = _INTL("Clear")
    commands[cmdRain = commands.length] = _INTL("Rain") if $game_variables[52] >0
    commands[cmdSnow = commands.length]     = _INTL("Hail") if $game_variables[53]>0
    commands[cmdSun = commands.length]  = _INTL("Sun") if $game_variables[54]>0
    commands[cmdSand = commands.length]  = _INTL("Sand") if $game_variables[55] >0
    commands[cmdHeavyR = commands.length]  = _INTL("Heavy Rain") if $game_variables[56] >0
    commands[cmdHarshS = commands.length]  = _INTL("Harsh Sun") if $game_variables[57] >0
    commands[cmdDelta = commands.length] = _INTL("Strong Winds") if $game_variables[58] >0
    commands[cmdStar = commands.length]  = _INTL("Starstorm") if $game_variables[59] >0
    commands[cmdOver = commands.length]  = _INTL("Overcast") if $game_variables[60] >0
    commands[cmdSleet = commands.length]  = _INTL("Sleet") if $game_variables[75] >0
    commands[cmdFog = commands.length]  = _INTL("Fog") if $game_variables[72] >0
    commands[cmdEclipse = commands.length]  = _INTL("Eclipse") if $game_variables[61] >0
    commands[cmdWindy = commands.length]  = _INTL("Windy") if $game_variables[63] >0
    commands[cmdAcidR = commands.length]  = _INTL("Acid Rain") if $game_variables[62] >0
    commands[cmdHumid = commands.length]  = _INTL("Humid") if $game_variables[65] >0
    commands[cmdHeatL = commands.length]  = _INTL("Heat Lightning") if $game_variables[64] >0
    commands[cmdRainbow = commands.length]  = _INTL("Rainbow") if $game_variables[66] >0
    commands[cmdDust = commands.length]  = _INTL("Dust Devil") if $game_variables[67] >0
    commands[cmdDClear = commands.length]  = _INTL("Distortion World - Clear") if $game_variables[68] >0
    commands[cmdDRain = commands.length]  = _INTL("Distortion World - Rain") if $game_variables[70] >0
    commands[cmdDWind = commands.length]  = _INTL("Distortion World - Windy") if $game_variables[69] >0
    commands[cmdDAsh = commands.length]  = _INTL("Distortion World - Ashfall") if $game_variables[71] >0
    commands[cmdVolc = commands.length]  = _INTL("Volcanic Ash") if $game_variables[73] >0
    commands[cmdNLight = commands.length]  = _INTL("Northern Lights") if $game_variables[74] >0
    commands[cmdRift = commands.length]  = _INTL("Temporal Rift") if $game_variables[111] >0
    commands[cmdEcho = commands.length]  = _INTL("Echo Chamber") if $game_variables[112] >0
    commands[commands.length]              = _INTL("Exit")
    @scene.pbStartScene(commands)
    loop do
      cmd = @scene.pbScene
        if cmd<0
        pbPlayCloseMenuSE
          break
        elsif cmdNone>=0 && cmd==cmdNone
          pbPlayDecisionSE
          if $game_variables[51]>=1
            pbMessage(_INTL("Weather: Clear"))
            pbMessage(_INTL("Weather Ball Type: Normal"))
            pbMessage(_INTL("Additional Effects: None"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdRain
          pbPlayDecisionSE
          if $game_variables[52]>=1
          pbMessage(_INTL("Weather: Rain"))
          pbMessage(_INTL("Weather Ball Type: Water"))
          pbMessage(_INTL("Additional Effects: Water x 1.5, Fire x .5"))
          pbMessage(_INTL("Thunder and Hurricane 100% accurate"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdSnow
          pbPlayDecisionSE
          if $game_variables[53]>=1
          pbMessage(_INTL("Weather: Hail"))
          pbMessage(_INTL("Weather Ball Type: Ice"))
          pbMessage(_INTL("Additional Effects: Non-Ice types take 1/16 damage"))
          pbMessage(_INTL("Blizzard 100% accurate"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdSun
          pbPlayDecisionSE
          if $game_variables[54]>=1
          pbMessage(_INTL("Weather: Sun"))
          pbMessage(_INTL("Weather Ball Type: Fire"))
          pbMessage(_INTL("Additional Effects: Fire x 1.5, Water x .5"))
          pbMessage(_INTL("Solar Beam and Solar Blade require no charge"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdSand
          pbPlayDecisionSE
          if $game_variables[55]>=1
          pbMessage(_INTL("Weather: Sandstorm"))
          pbMessage(_INTL("Weather Ball Type: Rock"))
          pbMessage(_INTL("Additional Effects: Non-Rock Ground or Steel types take 1/16 damage"))
          pbMessage(_INTL("Rock types gain 30% SpDef boost"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdHeavyR
          pbPlayDecisionSE
	  if $game_variables[56]>=1
          pbMessage(_INTL("Weather: Heavy Rain"))
          pbMessage(_INTL("Weather Ball Type: Water"))
          pbMessage(_INTL("Additional Effects: Water x 1.5, Fire ineffective"))
          pbMessage(_INTL("Thunder and Hurricane 100% accurate"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdHarshS
          pbPlayDecisionSE
	  if $game_variables[57]>=1
          pbMessage(_INTL("Weather: Harsh Sun"))
          pbMessage(_INTL("Weather Ball Type: Fire"))
          pbMessage(_INTL("Additional Effects: Fire x 1.5, Water ineffective"))
          pbMessage(_INTL("Solar Beam and Solar blade require no charge"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdDelta
          pbPlayDecisionSE
	  if $game_variables[58]>=1
          pbMessage(_INTL("Weather: Strong Winds"))
          pbMessage(_INTL("Weather Ball Type: Dragon"))
          pbMessage(_INTL("Additional Effects: Dragon's and Flying's weaknesses are removed"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdStar
          pbPlayDecisionSE
	  if $game_variables[59]>=1
          pbMessage(_INTL("Weather: Starstorm"))
          pbMessage(_INTL("Weather Ball Type: Cosmic"))
          pbMessage(_INTL("Additional Effects: Non-Cosmic types take 1/16 damage"))
          pbMessage(_INTL("Cosmic x 1.5, Fairy/Dragon/Steel x .5"))
          pbMessage(_INTL("Meteor Shower requires no charge"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdOver
          pbPlayDecisionSE
	  if $game_variables[60]>=1
          pbMessage(_INTL("Weather: Overcast"))
          pbMessage(_INTL("Weather Ball Type: Ghost"))
          pbMessage(_INTL("Additional Effects: Ghost x 1.5, Dark x .5"))
          pbMessage(_INTL("Shadow Force and Phantom Force require no charge"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdSleet
          pbPlayDecisionSE
	  if $game_variables[75]>=1
          pbMessage(_INTL("Weather: Sleet"))
          pbMessage(_INTL("Weather Ball Type: Ice"))
          pbMessage(_INTL("Additional Effects: Non-Ice types take 1/8 damage"))
          pbMessage(_INTL("Blizzard 100% accurate"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdFog
          pbPlayDecisionSE
	  if $game_variables[72]>=1
          pbMessage(_INTL("Weather: Fog"))
          pbMessage(_INTL("Weather Ball Type: Fairy"))
          pbMessage(_INTL("Additional Effects: Fairy x 1.5, Dragon x .5"))
          pbMessage(_INTL("All moves that check accuracy are 67% accurate"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdEclipse
          pbPlayDecisionSE
	  if $game_variables[61]>=1
          pbMessage(_INTL("Weather: Eclipse"))
          pbMessage(_INTL("Weather Ball Type: Dark"))
          pbMessage(_INTL("Additional Effects: Dark x 1.5, Ghost x 1.5"))
          pbMessage(_INTL("Additional Effects: Fairy x .5, Psychic x .5"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdWindy
          pbPlayDecisionSE
	  if $game_variables[63]>=1
          pbMessage(_INTL("Weather: Windy"))
          pbMessage(_INTL("Weather Ball Type: Flying"))
          pbMessage(_INTL("Additional Effects: Flying x 1.5, Rock x .5"))
          pbMessage(_INTL("Hazards fail to be set, and all hazards are removed"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdAcidR
          pbPlayDecisionSE
	  if $game_variables[62]>=1
          pbMessage(_INTL("Weather: Acid Rain"))
          pbMessage(_INTL("Weather Ball Type: Poison"))
          pbMessage(_INTL("Additional Effects: Non-Poison and Steel types take 1/16 damage"))
          pbMessage(_INTL("Poison types gain 30% Defense boost"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdHumid
          pbPlayDecisionSE
	  if $game_variables[65]>=1
          pbMessage(_INTL("Weather: Humid"))
          pbMessage(_INTL("Weather Ball Type: Bug"))
          pbMessage(_INTL("Fire x .5"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdHeatL
          pbPlayDecisionSE
	  if $game_variables[64]>=1
          pbMessage(_INTL("Weather: Heat Lightning"))
          pbMessage(_INTL("Weather Ball Type: Electric"))
          pbMessage(_INTL("Additional Effects: Electric x 1.5"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdRainbow
          pbPlayDecisionSE
	  if $game_variables[66]>=1
          pbMessage(_INTL("Weather: Rainbow"))
          pbMessage(_INTL("Weather Ball Type: Grass"))
          pbMessage(_INTL("Additional Effects: Grass x 1.5, Dark and Ghost x .5"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdDust
          pbPlayDecisionSE
	  if $game_variables[67]>=1
          pbMessage(_INTL("Weather: Dust Devil"))
          pbMessage(_INTL("Weather Ball Type: Ground"))
          pbMessage(_INTL("Additional Effects: Non-Ground and Flying types take 1/16 damage"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdDClear
          pbPlayDecisionSE
	  if $game_variables[68]>=1
          pbMessage(_INTL("Weather: Distortion World - Clear"))
          pbMessage(_INTL("Weather Ball Type: Cosmic"))
          pbMessage(_INTL("Additional Effects: Cosmic x 1.5"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdDRain
          pbPlayDecisionSE
	  if $game_variables[70]>=1
          pbMessage(_INTL("Weather: Distortion World - Rain"))
          pbMessage(_INTL("Weather Ball Type: Poison"))
          pbMessage(_INTL("Additional Effects: All non-Poison and Steel types take 1/16 damage"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdDWind
          pbPlayDecisionSE
	  if $game_variables[69]>=1
          pbMessage(_INTL("Weather: Distortion World - Windy"))
          pbMessage(_INTL("Weather Ball Type: Ghosts"))
          pbMessage(_INTL("Additional Effects: All non-Cosmic, Ghost or Flying types take 1/16 damage"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdDAsh
          pbPlayDecisionSE
	  if $game_variables[71]>=1
          pbMessage(_INTL("Weather: Distortion World - Ashfall"))
          pbMessage(_INTL("Weather Ball Type: Fighting"))
          pbMessage(_INTL("Additional Effects: Fighting types gain a 30% boost in Defense"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdVolc
          pbPlayDecisionSE
	  if $game_variables[73]>=1
          pbMessage(_INTL("Weather: Distorted Ashfall"))
          pbMessage(_INTL("Weather Ball Type: Steel"))
          pbMessage(_INTL("Additional Effects: Removes Steel's weaknesses"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdNLight
          pbPlayDecisionSE
	  if $game_variables[74]>=1
          pbMessage(_INTL("Weather: Northern Lights"))
          pbMessage(_INTL("Weather Ball Type: Psychic"))
          pbMessage(_INTL("Additional Effects: Psychic x 1.5, Ghost and Dark x .5"))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdRift
          pbPlayDecisionSE
    if $game_variables[111]>=1
          pbMessage(_INTL("Weather: Temporal Rift"))
          pbMessage(_INTL("Weather Ball Type: Time"))
          pbMessage(_INTL("Additional Effects: Time x 1.5, Poison and Dark x .5"))
          pbMessage(_INTL("Trick Room lasts 2 more turns when set in this weather."))
          else
            pbMessage(_INTL("No Readout Installed for this Weather"))
          end
        elsif cmdNone>=0 && cmd==cmdEcho
            pbPlayDecisionSE
      if $game_variables[112]>=1
            pbMessage(_INTL("Weather: Echo Chamber"))
            pbMessage(_INTL("Weather Ball Type: Sound"))
            pbMessage(_INTL("Additional Effects: Sound x 1.5"))
            pbMessage(_INTL("Sound moves hit a second time at a lesser power."))
            else
              pbMessage(_INTL("No Readout Installed for this Weather"))
            end
        else# Exit
        pbPlayCloseMenuSE
        break
      end
    end

    @scene.pbEndScene
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
        if pkmn.level >= $game_variables[106]
          exp = a/1000
        else
          exp = (isPartic) ? a : a/2
        end
      end
    elsif isPartic   # Participated in battle, no Exp Shares held by anyone
      if pkmn.level >= $game_variables[106]
        exp = a/1000
      else
        exp = a / (Settings::SPLIT_EXP_BETWEEN_GAINERS ? numPartic : 1)
      end
    elsif expAll   # Didn't participate in battle, gaining Exp due to Exp All
      # NOTE: Exp All works like the Exp Share from Gen 6+, not like the Exp All
      #       from Gen 1, i.e. Exp isn't split between all Pokémon gaining it.
      if pkmn.level >= $game_variables[106]
        exp = a/1000
      else
        exp = a/2
      end
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
    else
      exp /= 7
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
#===================================
# Alternate Forms
#===================================
MultipleForms.register(:CASTFORM,{
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    next 0
  }
})

MultipleForms.copy(:CASTFORM,:FORMETEOS,:ALTEMPER)

MultipleForms.register(:RIOLU,{
  "getFormOnCreation" => proc { |pkmn|
    next if pkmn.form_simple >= 3
    if $game_map
      map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
      next 2 if map_metadata && map_metadata.town_map_position &&
                map_metadata.town_map_position[0] == 1   # Zharo region
    end
    next 0
  }
})

MultipleForms.copy(:RIOLU,:LUCARIO,:BUNEARY,:LOPUNNY,:NUMEL,:CAMERUPT,:ROCKRUFF,:LYCANROC,:YAMASK,:COFAGRIGUS)

MultipleForms.register(:CACNEA,{
  "getFormOnCreation" => proc { |pkmn|
    next if pkmn.form_simple >= 2
    if $game_map
      map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
      next 1 if map_metadata && map_metadata.town_map_position &&
                map_metadata.town_map_position[0] == 1   # Zharo region
    end
    next 0
  }
})

MultipleForms.copy(:CACNEA,:CACTURNE,:SANDYGAST,:PALOSSAND,:DEINO,:ZWEILOUS,:HYDREIGON,:TRAPINCH,:HORSEA,:SEADRA,:EXEGGCUTE,:EXEGGUTOR,:SEEL,:DEWGONG,:QWILFISH,:LUVDISC)

GameData::Evolution.register({
  :id            => :Ferrocuda,
  :parameter     => Integer,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    if $game_switches[116] == true
      next $game_map.map_id == parameter
    end
  }
})

GameData::Evolution.register({
  :id            => :Friocuda,
  :parameter     => Integer,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    if $game_switches[117] == true
      next $game_map.map_id == parameter
    end
  }
})

GameData::Evolution.register({
  :id            => :Flarocuda,
  :parameter     => Integer,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    if $game_switches[118] == true
      next $game_map.map_id == parameter
    end
  }
})

GameData::Evolution.register({
  :id            => :Fearocuda,
  :parameter     => Integer,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    if $game_switches[119] == true
      next $game_map.map_id == parameter
    end
  }
})

GameData::Evolution.register({
  :id            => :Fairicuda,
  :parameter     => Integer,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    if $game_switches[120] == true
      next $game_map.map_id == parameter
    end
  }
})

GameData::Evolution.register({
  :id            => :Floracuda,
  :parameter     => Integer,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    if $game_switches[121] == true
      next $game_map.map_id == parameter
    end
  }
})

GameData::Evolution.register({
  :id            => :ZharoPoochyena,
  :parameter     => Integer,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    return false if $game_map.map_id != 0
    next pkmn.level >= parameter
  }
})

GameData::Evolution.register({
  :id            => :ZharoPhanpy,
  :parameter     => Integer,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    return false if $game_map.map_id != 0
    next pkmn.level >= parameter
  }
})

GameData::Evolution.register({
  :id            => :ZharoDrowzee,
  :parameter     => Integer,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    return false if $game_map.map_id != 0
    next pkmn.level >= parameter
  }
})
#===================================
# Move Scripts
#===================================
class PokeBattle_Move
    def beamMove?;          return @flags[/p/]; end
end

class PokeBattle_Move_103 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.pbOpposingSide.effects[PBEffects::Spikes]>=3
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if battle.field.weather==:Windy
      @battle.pbDisplay(_INTL("The Wind prevented the hazards from being set!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOpposingSide.effects[PBEffects::Spikes] += 1
    @battle.pbDisplay(_INTL("Spikes were scattered all around {1}'s feet!",
       user.pbOpposingTeam(true)))
  end
end

class PokeBattle_Move_104 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.pbOpposingSide.effects[PBEffects::ToxicSpikes]>=2
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if battle.field.weather==:Windy
      @battle.pbDisplay(_INTL("The Wind prevented the hazards from being set!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOpposingSide.effects[PBEffects::ToxicSpikes] += 1
    @battle.pbDisplay(_INTL("Poison spikes were scattered all around {1}'s feet!",
       user.pbOpposingTeam(true)))
  end
end

class PokeBattle_Move_105 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.pbOpposingSide.effects[PBEffects::StealthRock] || user.pbOpposingSide.effects[PBEffects::CometShards]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if battle.field.weather==:Windy
      @battle.pbDisplay(_INTL("The Wind prevented the hazards from being set!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOpposingSide.effects[PBEffects::StealthRock] = true
    @battle.pbDisplay(_INTL("Pointed stones float in the air around {1}!",
       user.pbOpposingTeam(true)))
  end
end

class PokeBattle_Move_153 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.pbOpposingSide.effects[PBEffects::StickyWeb]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if battle.field.weather==:Windy
      @battle.pbDisplay(_INTL("The Wind prevented the hazards from being set!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOpposingSide.effects[PBEffects::StickyWeb] = true
    @battle.pbDisplay(_INTL("A sticky web has been laid out beneath {1}'s feet!",
       user.pbOpposingTeam(true)))
  end
end

class PokeBattle_Move_178 < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    if @battle.choices[target.index][0]!=:None &&
       ((@battle.choices[target.index][0]!=:UseMove &&
       @battle.choices[target.index][0]==:Shift) || target.movedThisRound?)
    else
      baseDmg *= 2
    end
    return baseDmg
  end
end

class PokeBattle_Move_17C < PokeBattle_Move_0BD
  def pbNumHits(user,targets)
    return 1 if targets.length > 1
    return 2
  end
end

class PokeBattle_Move_17D < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    if target.effects[PBEffects::JawLockUser] ==-1 && !target.effects[PBEffects::JawLock] &&
      user.effects[PBEffects::JawLockUser] ==-1 && !user.effects[PBEffects::JawLock]
      user.effects[PBEffects::JawLock] = true
      target.effects[PBEffects::JawLock] = true
      user.effects[PBEffects::JawLockUser] = user.index
      target.effects[PBEffects::JawLockUser] = user.index
      @battle.pbDisplay(_INTL("Neither Pokémon can run away!"))
    end
  end
end

class PokeBattle_Move_17E < PokeBattle_Move
  def healingMove?; return true; end
  def worksWithNoTargets?; return true; end

  def pbMoveFailed?(user,targets)
    failed = true
    @battle.eachSameSideBattler(user) do |b|
      next if b.hp == b.totalhp
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    if target.hp==target.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",target.pbThis))
      return true
    elsif !target.canHeal?
      @battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    hpGain = (target.totalhp/4.0).round
    target.pbRecoverHP(hpGain)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",target.pbThis))
  end

  def pbHealAmount(user)
    return (user.totalhp/4.0).round
  end
end

class PokeBattle_Move_188 < PokeBattle_Move_0A0
  def multiHitMove?;           return true; end
  def pbNumHits(user,targets); return 3;    end
end

class PokeBattle_Move_18C < PokeBattle_Move
end

class PokeBattle_Move_18D < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if @battle.field.terrain==:Electric &&
                    !target.airborne?
    return baseDmg
  end
end

class PokeBattle_Move_190 < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 1.5 if @battle.field.terrain==:Psychic
    return baseDmg
  end
end

class PokeBattle_Move_500 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.pbOpposingSide.effects[PBEffects::CometShards] || user.pbOpposingSide.effects[PBEffects::StealthRock]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if battle.field.weather==:Windy
      @battle.pbDisplay(_INTL("The Wind prevented the hazards from being set!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOpposingSide.effects[PBEffects::CometShards] = true
    @battle.pbDisplay(_INTL("Comet shards float in the air around {1}!",
       user.pbOpposingTeam(true)))
  end
end

class PokeBattle_Move_501 < PokeBattle_Move_163

  def pbCalcTypeModSingle(moveType,defType,user,target)
    retur Effectiveness::NORMAL_EFFECTIVE_ONE if moveType == :ELECTRIC &&
                                                        defType == :GROUND
    return super
  end
end

class PokeBattle_Move_502 <PokeBattle_WeatherMove
  def initialize(battle,move)
    super
    @weatherType = :Starstorm
  end
end

class PokeBattle_Move_503 < PokeBattle_TwoTurnMove
  def pbIsChargingTurn?(user)
    ret = super
    if user.effects[PBEffects::TwoTurnAttack]==0
      w = @battle.pbWeather
      if w==:Starstorm
        @powerHerb = false
        @chargingTurn = true
        @damagingTurn = true
        return false
      end
    end
    return ret
  end

  def pbChargingTurnMessage(user,targets)
    @battle.pbDisplay(_INTL("{1} took in starlight!",user.pbThis))
  end
end

class PokeBattle_Move_504 < PokeBattle_Move_163

  def pbCalcTypeModSingle(moveType,defType,user,target)
    return Effectiveness::NORMAL_EFFECTIVE_ONE if moveType == :DRAGON &&
                                                        defType == :FAIRY
    return super
  end
end

class PokeBattle_Move_505 < PokeBattle_Move
  def pbCalcTypeModSingle(moveType,defType,user,target)
    return Effectiveness::SUPER_EFFECTIVE_ONE if defType == :ELECTRIC
    return super
  end
end

class PokeBattle_Move_506 < PokeBattle_HealingMove
  def pbHealAmount(user)
    return (user.totalhp*2/3.0).round if user.effects[PBEffects::Charge] > 0
    return (user.totalhp/2.0).round
  end
end

class PokeBattle_Move_507 < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::LeechSeed] = user.index
    @battle.pbDisplay(_INTL("{1} was sapped!",target.pbThis))
  end
end

class PokeBattle_Move_508 < PokeBattle_HealingMove
  def pbOnStartUse(user,targets)
    case @battle.pbWeather
    when :Overcast, :Eclipse, :Fog, :Starstorm, :DClear, :Borealis
      @healAmount = (user.totalhp*2/3.0).round
    when :None, :StrongWinds, :Windy
      @healAmount = (user.totalhp/2.0).round
    else
      @healAmount = (user.totalhp/4.0).round
    end
  end

  def pbHealAmount(user)
    return @healAmount
  end
end

class PokeBattle_Move_0D8 < PokeBattle_HealingMove
  def pbOnStartUse(user,targets)
    case @battle.pbWeather
    when :Sun, :HarshSun, :Rainbow, :Borealis
      @healAmount = (user.totalhp*2/3.0).round
    when :None, :StrongWinds, :Windy, :HeatLight
      @healAmount = (user.totalhp/2.0).round
    else
      @healAmount = (user.totalhp/4.0).round
    end
  end

  def pbHealAmount(user)
    return @healAmount
  end
end

class PokeBattle_Move_509 <PokeBattle_WeatherMove
  def initialize(battle,move)
    super
    @weatherType = :TimeWarp
  end
end

class PokeBattle_Move_510 <PokeBattle_WeatherMove
  def initialize(battle,move)
    super
    @weatherType = :Reverb
  end
end

class PokeBattle_Move_511 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,3]
  end
end

#===================================
# Ability Scripts
#===================================

class PokeBattle_Battler
  def pbLowerSpAtkStatStageMindGames(user)
    return false if fainted?
    # NOTE: Substitute intentially blocks Intimidate even if self has Contrary.
    if @effects[PBEffects::Substitute]>0
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} is protected by its substitute!",pbThis))
      else
        @battle.pbDisplay(_INTL("{1}'s substitute protected it from {2}'s {3}!",
           pbThis,user.pbThis(true),user.abilityName))
      end
      return false
    end
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      return pbLowerStatStageByAbility(:SPECIAL_ATTACK,1,user,false)
    end
    # NOTE: These checks exist to ensure appropriate messages are shown if
    #       Intimidate is blocked somehow (i.e. the messages should mention the
    #       Intimidate ability by name).
    if !hasActiveAbility?(:CONTRARY)
      if pbOwnSide.effects[PBEffects::Mist]>0
        @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by Mist!",
           pbThis,user.pbThis(true),user.abilityName))
        return false
      end
      if abilityActive?
        if BattleHandlers.triggerStatLossImmunityAbility(@ability,self,:SPECIAL_ATTACK,@battle,false) ||
           BattleHandlers.triggerStatLossImmunityAbilityNonIgnorable(@ability,self,:SPECIAL_ATTACK,@battle,false) ||
           BattleHandlers.triggerStatLossImmunityAbilityNonIgnorableSandy(@ability,self,:SPECIAL_ATTACK,@battle,false)
          @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
             pbThis,abilityName,user.pbThis(true),user.abilityName))
          return false
        end
      end
      eachAlly do |b|
        next if !b.abilityActive?
        if BattleHandlers.triggerStatLossImmunityAllyAbility(b.ability,b,self,:SPECIAL_ATTACK,@battle,false)
          @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by {4}'s {5}!",
             pbThis,user.pbThis(true),user.abilityName,b.pbThis(true),b.abilityName))
          return false
        end
      end
    end
    return false if !pbCanLowerStatStage?(:SPECIAL_ATTACK,user)
    return pbLowerStatStageByCause(:SPECIAL_ATTACK,1,user,user.abilityName)
  end
  def pbLowerSpeedStatStageMedusoid(user)
    return false if fainted?
    # NOTE: Substitute intentially blocks Intimidate even if self has Contrary.
    if @effects[PBEffects::Substitute]>0
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} is protected by its substitute!",pbThis))
      else
        @battle.pbDisplay(_INTL("{1}'s substitute protected it from {2}'s {3}!",
           pbThis,user.pbThis(true),user.abilityName))
      end
      return false
    end
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      return pbLowerStatStageByAbility(:SPEED,1,user,false)
    end
    # NOTE: These checks exist to ensure appropriate messages are shown if
    #       Intimidate is blocked somehow (i.e. the messages should mention the
    #       Intimidate ability by name).
    if !hasActiveAbility?(:CONTRARY)
      if pbOwnSide.effects[PBEffects::Mist]>0
        @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by Mist!",
           pbThis,user.pbThis(true),user.abilityName))
        return false
      end
      if abilityActive?
        if BattleHandlers.triggerStatLossImmunityAbility(@ability,self,:SPEED,@battle,false) ||
           BattleHandlers.triggerStatLossImmunityAbilityNonIgnorable(@ability,self,:SPEED,@battle,false) ||
           BattleHandlers.triggerStatLossImmunityAbilityNonIgnorableSandy(@ability,self,:SPEED,@battle,false)
          @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
             pbThis,abilityName,user.pbThis(true),user.abilityName))
          return false
        end
      end
      eachAlly do |b|
        next if !b.abilityActive?
        if BattleHandlers.triggerStatLossImmunityAllyAbility(b.ability,b,self,:SPEED,@battle,false)
          @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by {4}'s {5}!",
             pbThis,user.pbThis(true),user.abilityName,b.pbThis(true),b.abilityName))
          return false
        end
      end
    end
    return false if !pbCanLowerStatStage?(:SPEED,user)
    return pbLowerStatStageByCause(:SPEED,1,user,user.abilityName)
  end
  def pbCanInflictStatus?(newStatus,user,showMessages,move=nil,ignoreStatus=false)
    return false if fainted?
    selfInflicted = (user && user.index==@index)
    # Already have that status problem
    if self.status==newStatus && !ignoreStatus
      if showMessages
        msg = ""
        case self.status
        when :SLEEP     then msg = _INTL("{1} is already asleep!", pbThis)
        when :POISON    then msg = _INTL("{1} is already poisoned!", pbThis)
        when :BURN      then msg = _INTL("{1} already has a burn!", pbThis)
        when :PARALYSIS then msg = _INTL("{1} is already paralyzed!", pbThis)
        when :FROZEN    then msg = _INTL("{1} is already frozen solid!", pbThis)
        end
        @battle.pbDisplay(msg)
      end
      return false
    end
    # Trying to replace a status problem with another one
    if self.status != :NONE && !ignoreStatus && !selfInflicted
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    # Trying to inflict a status problem on a Pokémon behind a substitute
    if @effects[PBEffects::Substitute]>0 && !(move && move.ignoresSubstitute?(user)) &&
       !selfInflicted
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    # Weather immunity
    if newStatus == :FROZEN && [:Sun, :HarshSun].include?(@battle.pbWeather)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    # Terrains immunity
    if affectedByTerrain?
      case @battle.field.terrain
      when :Electric
        if newStatus == :SLEEP
          @battle.pbDisplay(_INTL("{1} surrounds itself with electrified terrain!",
             pbThis(true))) if showMessages
          return false
        end
      when :Misty
        @battle.pbDisplay(_INTL("{1} surrounds itself with misty terrain!",pbThis(true))) if showMessages
        return false
      end
    end
    # Uproar immunity
    if newStatus == :SLEEP && !(hasActiveAbility?(:SOUNDPROOF) && !@battle.moldBreaker)
      @battle.eachBattler do |b|
        next if b.effects[PBEffects::Uproar]==0
        @battle.pbDisplay(_INTL("But the uproar kept {1} awake!",pbThis(true))) if showMessages
        return false
      end
    end
    # Cacophony Immunity
    if newStatus == :SLEEP && hasActiveAbility?(:CACOPHONY)
      @battle.eachBattler do |b|
        next if hasActiveAbility?(:SOUNDPROOF)
        @battle.pbDisplay(_INTL("But the uproar kept {1} awake!",pbThis(true))) if showMessages
        return false
      end
    end
    # Type immunities
    hasImmuneType = false
    case newStatus
    when :SLEEP
      # No type is immune to sleep
    when :POISON
      if !(user && user.hasActiveAbility?(:CORROSION))
        hasImmuneType |= pbHasType?(:POISON)
        hasImmuneType |= pbHasType?(:STEEL)
      end
    when :BURN
      hasImmuneType |= pbHasType?(:FIRE)
    when :PARALYSIS
      hasImmuneType |= pbHasType?(:ELECTRIC) && Settings::MORE_TYPE_EFFECTS
    when :FROZEN
      hasImmuneType |= pbHasType?(:ICE)
    end
    if hasImmuneType
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    # Ability immunity
    immuneByAbility = false; immAlly = nil
    if BattleHandlers.triggerStatusImmunityAbilityNonIgnorable(self.ability,self,newStatus)
      immuneByAbility = true
    elsif selfInflicted || !@battle.moldBreaker
      if abilityActive? && BattleHandlers.triggerStatusImmunityAbility(self.ability,self,newStatus)
        immuneByAbility = true
      else
        eachAlly do |b|
          next if !b.abilityActive?
          next if !BattleHandlers.triggerStatusImmunityAllyAbility(b.ability,self,newStatus)
          immuneByAbility = true
          immAlly = b
          break
        end
      end
    end
    if immuneByAbility
      if showMessages
        @battle.pbShowAbilitySplash(immAlly || self)
        msg = ""
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          case newStatus
          when :SLEEP     then msg = _INTL("{1} stays awake!", pbThis)
          when :POISON    then msg = _INTL("{1} cannot be poisoned!", pbThis)
          when :BURN      then msg = _INTL("{1} cannot be burned!", pbThis)
          when :PARALYSIS then msg = _INTL("{1} cannot be paralyzed!", pbThis)
          when :FROZEN    then msg = _INTL("{1} cannot be frozen solid!", pbThis)
          end
        elsif immAlly
          case newStatus
          when :SLEEP
            msg = _INTL("{1} stays awake because of {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          when :POISON
            msg = _INTL("{1} cannot be poisoned because of {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          when :BURN
            msg = _INTL("{1} cannot be burned because of {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          when :PARALYSIS
            msg = _INTL("{1} cannot be paralyzed because of {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          when :FROZEN
            msg = _INTL("{1} cannot be frozen solid because of {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          end
        else
          case newStatus
          when :SLEEP     then msg = _INTL("{1} stays awake because of its {2}!", pbThis, abilityName)
          when :POISON    then msg = _INTL("{1}'s {2} prevents poisoning!", pbThis, abilityName)
          when :BURN      then msg = _INTL("{1}'s {2} prevents burns!", pbThis, abilityName)
          when :PARALYSIS then msg = _INTL("{1}'s {2} prevents paralysis!", pbThis, abilityName)
          when :FROZEN    then msg = _INTL("{1}'s {2} prevents freezing!", pbThis, abilityName)
          end
        end
        @battle.pbDisplay(msg)
        @battle.pbHideAbilitySplash(immAlly || self)
      end
      return false
    end
    # Safeguard immunity
    if pbOwnSide.effects[PBEffects::Safeguard]>0 && !selfInflicted && move &&
       !(user && user.hasActiveAbility?(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end
  def unstoppableAbility?(abil = nil)
    abil = @ability_id if !abil
    abil = GameData::Ability.try_get(abil)
    return false if !abil
    ability_blacklist = [
      # Form-changing abilities
      :BATTLEBOND,
      :DISGUISE,
#      :FLOWERGIFT,                                        # This can be stopped
      :FORECAST,
      :MULTITYPE,
      :POWERCONSTRUCT,
      :SCHOOLING,
      :SHIELDSDOWN,
      :STANCECHANGE,
      :ZENMODE,
      :DUAT,
      :BAROMETRIC,
      :ACCLIMATE,
      # Abilities intended to be inherent properties of a certain species
      :COMATOSE,
      :RKSSYSTEM
    ]
    return ability_blacklist.include?(abil.id)
  end
  def ungainableAbility?(abil = nil)
    abil = @ability_id if !abil
    abil = GameData::Ability.try_get(abil)
    return false if !abil
    ability_blacklist = [
      # Form-changing abilities
      :BATTLEBOND,
      :DISGUISE,
      :FLOWERGIFT,
      :FORECAST,
      :MULTITYPE,
      :POWERCONSTRUCT,
      :SCHOOLING,
      :SHIELDSDOWN,
      :STANCECHANGE,
      :ZENMODE,
      :ACCLIMATE,
      :BAROMETRIC,
      :DUAT,
      # Appearance-changing abilities
      :ILLUSION,
      :IMPOSTER,
      # Abilities intended to be inherent properties of a certain species
      :COMATOSE,
      :RKSSYSTEM
    ]
    return ability_blacklist.include?(abil.id)
  end
  def takesDustDevilDamage?
    return false if !takesIndirectDamage?
    return false if pbHasType?(:GROUND) || pbHasType?(:FLYING)
    return false if inTwoTurnAttack?("0CA","0CB")   # Dig, Dive
    return false if hasActiveAbility?([:OVERCOAT,:SANDFORCE,:SANDRUSH,:SANDVEIL])
    return false if hasActiveItem?(:SAFETYGOGGLES)
    return true
  end
  def takesAcidRainDamage?
    return false if !takesIndirectDamage?
    return false if pbHasType?(:POISON) || pbHasType?(:STEEL)
    return false if inTwoTurnAttack?("0CA","0CB")   # Dig, Dive
    return false if hasActiveAbility?([:OVERCOAT,:SANDFORCE,:SANDRUSH,:SANDVEIL])
    return false if hasActiveItem?(:SAFETYGOGGLES)
    return true
  end
  def takesStarstormDamage?
    return false if !takesIndirectDamage?
    return false if pbHasType?(:COSMIC)
    return false if inTwoTurnAttack?("0CA","0CB")   # Dig, Dive
    return false if hasActiveAbility?([:OVERCOAT,:ICEBODY,:SNOWCLOAK])
    return false if hasActiveItem?(:SAFETYGOGGLES)
    return true
  end
  def pbCheckFormOnWeatherChange
    return if fainted? || @effects[PBEffects::Transform]
    # Castform - Forecast
    if isSpecies?(:CASTFORM)
      if hasActiveAbility?(:FORECAST)
        newForm = 0
        case @battle.pbWeather
        when :Fog;                        newForm = 4
        when :Overcast, :DWind; newForm = 5
        when :Starstorm;   			        	newForm = 6
        when :DClear; 				          	newForm = 6
        when :Eclipse;                    newForm = 7
        when :Windy;                      newForm = 8
        when :HeatLight;                  newForm = 9
        when :StrongWinds;                newForm = 10
        when :AcidRain, :DRain; newForm = 11
        when :Sandstorm;                  newForm = 12
        when :Rainbow;                    newForm = 13
        when :DustDevil;                  newForm = 14
        when :DAshfall;                   newForm = 15
        when :VolcanicAsh;                newForm = 16
        when :Borealis;                   newForm = 17
        when :Humid;                      newForm = 18
        when :TimeWarp;                   newForm = 19
        when :Reverb;                     newForm = 20
        when :Sun, :HarshSun;   newForm = 1
        when :Rain, :Storm, :HeavyRain; newForm = 2
        when :Hail, :Sleet;     newForm = 3
        end
        if @form!=newForm
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(newForm,_INTL("{1} transformed!",pbThis))
        end
      else
        pbChangeForm(0,_INTL("{1} transformed!",pbThis))
      end
    end
      if isSpecies?(:FORMETEOS)
        if hasActiveAbility?(:ACCLIMATE)
          newForm = 0
          case @battle.pbWeather
          when :Fog;                        newForm = 4
          when :Overcast, :DWind; newForm = 5
          when :Starstorm;   			        	newForm = 6
          when :DClear; 				          	newForm = 6
          when :Eclipse;                    newForm = 7
          when :Windy;                      newForm = 8
          when :HeatLight;                  newForm = 9
          when :StrongWinds;                newForm = 10
          when :AcidRain, :DRain; newForm = 11
          when :Sandstorm;                  newForm = 12
          when :Rainbow;                    newForm = 13
          when :DustDevil;                  newForm = 14
          when :DAshfall;                   newForm = 15
          when :VolcanicAsh;                newForm = 16
          when :Borealis;                   newForm = 17
          when :Humid;                      newForm = 18
          when :TimeWarp;                   newForm = 19
          when :Reverb;                     newForm = 20
          when :Sun, :HarshSun;   newForm = 1
          when :Rain, :Storm, :HeavyRain; newForm = 2
          when :Hail, :Sleet;     newForm = 3
          end
          if @form!=newForm
            @battle.pbShowAbilitySplash(self,true)
            @battle.pbHideAbilitySplash(self)
            pbChangeForm(newForm,_INTL("{1} transformed!",pbThis))
          end
        else
          pbChangeForm(0,_INTL("{1} transformed!",pbThis))
        end
      end
      if isSpecies?(:ALTEMPER)
        if hasActiveAbility?(:BAROMETRIC)
          newForm = 0
          case @battle.pbWeather
          when :Fog;                        newForm = 4
          when :Overcast, :DWind; newForm = 5
          when :Starstorm;   			        	newForm = 6
          when :DClear; 				          	newForm = 6
          when :Eclipse;                    newForm = 7
          when :Windy;                      newForm = 8
          when :HeatLight;                  newForm = 9
          when :StrongWinds;                newForm = 10
          when :AcidRain, :DRain; newForm = 11
          when :Sandstorm;                  newForm = 12
          when :Rainbow;                    newForm = 13
          when :DustDevil;                  newForm = 14
          when :DAshfall;                   newForm = 15
          when :VolcanicAsh;                newForm = 16
          when :Borealis;                   newForm = 17
          when :Humid;                      newForm = 18
          when :TimeWarp;                   newForm = 19
          when :Reverb;                     newForm = 20
          when :Sun, :HarshSun;   newForm = 1
          when :Rain, :Storm, :HeavyRain; newForm = 2
          when :Hail, :Sleet;     newForm = 3
          end
          if @form!=newForm
            @battle.pbShowAbilitySplash(self,true)
            case @battle.pbWeather
            when :Fog;                        @effects[PBEffects::Type3] = :FAIRY
            when :None;                       @effects[PBEffects::Type3] = :NORMAL
            when :Overcast, :DWind; @effects[PBEffects::Type3] = :GHOST
            when :Eclipse;                    @effects[PBEffects::Type3] = :DARK
            when :Windy;                      @effects[PBEffects::Type3] = :FLYING
            when :HeatLight;                  @effects[PBEffects::Type3] = :ELECTRIC
            when :StrongWinds;                @effects[PBEffects::Type3] = :DRAGON
            when :AcidRain, :DRain; @effects[PBEffects::Type3] = :POISON
            when :Sandstorm;                  @effects[PBEffects::Type3] = :ROCK
            when :Rainbow;                    @effects[PBEffects::Type3] = :GRASS
            when :DustDevil;                  @effects[PBEffects::Type3] = :GROUND
            when :DAshfall;                   @effects[PBEffects::Type3] = :FIGHTING
            when :VolcanicAsh;                @effects[PBEffects::Type3] = :STEEL
            when :Borealis;                   @effects[PBEffects::Type3] = :PSYCHIC
            when :Humid;                      @effects[PBEffects::Type3] = :BUG
            when :Reverb;                     @effects[PBEffects::Type3] = :SOUND
            when :Sun, :HarshSun;   @effects[PBEffects::Type3] = :FIRE
            when :Rain, :Storm, :HeavyRain; @effects[PBEffects::Type3] = :WATER
            when :Hail, :Sleet;     @effects[PBEffects::Type3] = :ICE
            end
            @battle.pbHideAbilitySplash(self)
            pbChangeForm(newForm,_INTL("{1} transformed!",pbThis))
          end
        else
          pbChangeForm(0,_INTL("{1} transformed!",pbThis))
        end
      end
    # Cherrim - Flower Gift
    if isSpecies?(:CHERRIM)
      if hasActiveAbility?(:FLOWERGIFT)
        newForm = 0
        case @battle.pbWeather
        when :Sun, :HarshSun; newForm = 1
        end
        if @form!=newForm
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(newForm,_INTL("{1} transformed!",pbThis))
        end
      else
        pbChangeForm(0,_INTL("{1} transformed!",pbThis))
      end
    end
  end
end

class PokeBattle_Move
  def pbChangeUsageCounters(user,specialUsage)
    user.effects[PBEffects::FuryCutter]   = 0
    user.effects[PBEffects::ParentalBond] = 0
    user.effects[PBEffects::ProtectRate]  = 1
    user.effects[PBEffects::EchoChamber] = 0
    @battle.field.effects[PBEffects::FusionBolt]  = false
    @battle.field.effects[PBEffects::FusionFlare] = false
  end

  def pbBeamMove?;            return beamMove?; end
  def pbSoundMove?;           return soundMove?; end

  def pbNumHits(user,targets)
    if user.hasActiveAbility?(:PARENTALBOND) && pbDamagingMove? &&
       !chargingTurnMove? && targets.length==1
      # Record that Parental Bond applies, to weaken the second attack
      user.effects[PBEffects::ParentalBond] = 3
      return 2
    elsif pbSoundMove? && @battle.field.weather == :Reverb &&
       !chargingTurnMove? && targets.length==1
      # Record that Parental Bond applies, to weaken the second attack
      user.effects[PBEffects::EchoChamber] = 3
      return 2
    else
      return 1
    end
    return 1
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    return if !showAnimation
    if user.effects[PBEffects::ParentalBond]==1 || user.effects[PBEffects::EchoChamber]==1
      @battle.pbCommonAnimation("ParentalBond",user,targets)
    else
      @battle.pbAnimation(id,user,targets,hitNum)
    end
  end
  #=============================================================================
  # Move's type calculation
  #=============================================================================
  def pbBaseType(user)
    ret = @type
    if ret && user.abilityActive?
      ret = BattleHandlers.triggerMoveBaseTypeModifierAbility(user.ability,user,self,ret)
    end
    return ret
  end

  def pbCalcType(user)
    @powerBoost = false
    ret = pbBaseType(user)
    if ret && GameData::Type.exists?(:ELECTRIC)
      if @battle.field.effects[PBEffects::IonDeluge] && ret == :NORMAL
        ret = :ELECTRIC
        @powerBoost = false
      end
      if user.effects[PBEffects::Electrify]
        ret = :ELECTRIC
        @powerBoost = false
      end
    end
    return ret
  end

  #=============================================================================
  # Type effectiveness calculation
  #=============================================================================
  def pbCalcTypeModSingle(moveType,defType,user,target)
    ret = Effectiveness.calculate_one(moveType, defType)
    # Ring Target
    if target.hasActiveItem?(:RINGTARGET)
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if Effectiveness.ineffective_type?(moveType, defType)
    end
    # Foresight
    if user.hasActiveAbility?(:SCRAPPY) || target.effects[PBEffects::Foresight]
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :GHOST &&
                                                   Effectiveness.ineffective_type?(moveType, defType)
    end
    # Miracle Eye
    if target.effects[PBEffects::MiracleEye]
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :DARK &&
                                                   Effectiveness.ineffective_type?(moveType, defType)
    end
    # Delta Stream's weather
    if @battle.pbWeather == :StrongWinds
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :FLYING &&
                                                   Effectiveness.super_effective_type?(moveType, defType)
    end
    if @battle.pbWeather == :StrongWinds
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :DRAGON &&
                                                   Effectiveness.super_effective_type?(moveType, defType)
    end
    # Volcanic Ash's weather
    if @battle.pbWeather == :VolcanicAsh
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :STEEL &&
                                                   Effectiveness.super_effective_type?(moveType, defType)
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !target.airborne?
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :FLYING && moveType == :GROUND
    end
    return ret
  end

  def pbCalcTypeMod(moveType,user,target)
    return Effectiveness::NORMAL_EFFECTIVE if !moveType
    return Effectiveness::NORMAL_EFFECTIVE if moveType == :GROUND &&
       target.pbHasType?(:FLYING) && target.hasActiveItem?(:IRONBALL)
    # Determine types
    tTypes = target.pbTypes(true)
    # Get effectivenesses
    typeMods = [Effectiveness::NORMAL_EFFECTIVE_ONE] * 3   # 3 types max
    if moveType == :SHADOW
      if target.shadowPokemon?
        typeMods[0] = Effectiveness::NOT_VERY_EFFECTIVE_ONE
      else
        typeMods[0] = Effectiveness::SUPER_EFFECTIVE_ONE
      end
    else
      tTypes.each_with_index do |type,i|
        typeMods[i] = pbCalcTypeModSingle(moveType,type,user,target)
      end
    end
    # Multiply all effectivenesses together
    ret = 1
    typeMods.each { |m| ret *= m }
    return ret
  end

  #=============================================================================
  # Accuracy check
  #=============================================================================
  def pbBaseAccuracy(user,target); return @accuracy; end

  # Accuracy calculations for one-hit KO moves and "always hit" moves are
  # handled elsewhere.
  def pbAccuracyCheck(user,target)
    # "Always hit" effects and "always hit" accuracy
    return true if target.effects[PBEffects::Telekinesis]>0
    return true if target.effects[PBEffects::Minimize] && tramplesMinimize?(1)
    baseAcc = pbBaseAccuracy(user,target)
    return true if baseAcc==0
    # Calculate all multiplier effects
    modifiers = {}
    modifiers[:base_accuracy]  = baseAcc
    modifiers[:accuracy_stage] = user.stages[:ACCURACY]
    modifiers[:evasion_stage]  = target.stages[:EVASION]
    modifiers[:accuracy_multiplier] = 1.0
    modifiers[:evasion_multiplier]  = 1.0
    pbCalcAccuracyModifiers(user,target,modifiers)
    # Check if move can't miss
    return true if modifiers[:base_accuracy] == 0
    # Calculation
    accStage = [[modifiers[:accuracy_stage], -6].max, 6].min + 6
    evaStage = [[modifiers[:evasion_stage], -6].max, 6].min + 6
    stageMul = [3,3,3,3,3,3, 3, 4,5,6,7,8,9]
    stageDiv = [9,8,7,6,5,4, 3, 3,3,3,3,3,3]
    accuracy = 100.0 * stageMul[accStage] / stageDiv[accStage]
    evasion  = 100.0 * stageMul[evaStage] / stageDiv[evaStage]
    accuracy = (accuracy * modifiers[:accuracy_multiplier]).round
    evasion  = (evasion  * modifiers[:evasion_multiplier]).round
    evasion = 1 if evasion < 1
    # Calculation
    return @battle.pbRandom(100) < modifiers[:base_accuracy] * accuracy / evasion
  end

  def pbCalcAccuracyModifiers(user,target,modifiers)
    # Ability effects that alter accuracy calculation
    if user.abilityActive?
      BattleHandlers.triggerAccuracyCalcUserAbility(user.ability,
         modifiers,user,target,self,@calcType)
    end
    user.eachAlly do |b|
      next if !b.abilityActive?
      BattleHandlers.triggerAccuracyCalcUserAllyAbility(b.ability,
         modifiers,user,target,self,@calcType)
    end
    if target.abilityActive? && !@battle.moldBreaker
      BattleHandlers.triggerAccuracyCalcTargetAbility(target.ability,
         modifiers,user,target,self,@calcType)
    end
    # Item effects that alter accuracy calculation
    if user.itemActive?
      BattleHandlers.triggerAccuracyCalcUserItem(user.item,
         modifiers,user,target,self,@calcType)
    end
    if target.itemActive?
      BattleHandlers.triggerAccuracyCalcTargetItem(target.item,
         modifiers,user,target,self,@calcType)
    end
    # Other effects, inc. ones that set accuracy_multiplier or evasion_stage to
    # specific values
    if @battle.field.effects[PBEffects::Gravity] > 0
      modifiers[:accuracy_multiplier] *= 5 / 3.0
    end
    if @battle.pbWeather == :Fog
      if !user.pbHasType?(:FAIRY)
        modifiers[:accuracy_multiplier] *= 0.75
      end
    end
    if user.effects[PBEffects::MicleBerry]
      user.effects[PBEffects::MicleBerry] = false
      modifiers[:accuracy_multiplier] *= 1.2
    end
    modifiers[:evasion_stage] = 0 if target.effects[PBEffects::Foresight] && modifiers[:evasion_stage] > 0
    modifiers[:evasion_stage] = 0 if target.effects[PBEffects::MiracleEye] && modifiers[:evasion_stage] > 0
  end

  #=============================================================================
  # Critical hit check
  #=============================================================================
  # Return values:
  #   -1: Never a critical hit.
  #    0: Calculate normally.
  #    1: Always a critical hit.
  def pbCritialOverride(user,target); return 0; end

  # Returns whether the move will be a critical hit.
  def pbIsCritical?(user,target)
    return false if target.pbOwnSide.effects[PBEffects::LuckyChant]>0
    # Set up the critical hit ratios
    ratios = (Settings::NEW_CRITICAL_HIT_RATE_MECHANICS) ? [24,8,2,1] : [16,8,4,3,2]
    c = 0
    # Ability effects that alter critical hit rate
    if c>=0 && user.abilityActive?
      c = BattleHandlers.triggerCriticalCalcUserAbility(user.ability,user,target,c)
    end
    if c>=0 && target.abilityActive? && !@battle.moldBreaker
      c = BattleHandlers.triggerCriticalCalcTargetAbility(target.ability,user,target,c)
    end
    # Item effects that alter critical hit rate
    if c>=0 && user.itemActive?
      c = BattleHandlers.triggerCriticalCalcUserItem(user.item,user,target,c)
    end
    if c>=0 && target.itemActive?
      c = BattleHandlers.triggerCriticalCalcTargetItem(target.item,user,target,c)
    end
    return false if c<0
    # Move-specific "always/never a critical hit" effects
    case pbCritialOverride(user,target)
    when 1  then return true
    when -1 then return false
    end
    # Other effects
    return true if c>50   # Merciless
    return true if user.effects[PBEffects::LaserFocus]>0
    c += 1 if highCriticalRate?
    c += user.effects[PBEffects::FocusEnergy]
    c += 1 if user.inHyperMode? && @type == :SHADOW
    c = ratios.length-1 if c>=ratios.length
    # Calculation
    return @battle.pbRandom(ratios[c])==0
  end

  #=============================================================================
  # Damage calculation
  #=============================================================================
  def pbBaseDamage(baseDmg,user,target);              return baseDmg;    end
  def pbBaseDamageMultiplier(damageMult,user,target); return damageMult; end
  def pbModifyDamage(damageMult,user,target);         return damageMult; end

  def pbGetAttackStats(user,target)
    if specialMove?
      return user.spatk, user.stages[:SPECIAL_ATTACK]+6
    end
    return user.attack, user.stages[:ATTACK]+6
  end

  def pbGetDefenseStats(user,target)
    if specialMove?
      return target.spdef, target.stages[:SPECIAL_DEFENSE]+6
    end
    return target.defense, target.stages[:DEFENSE]+6
  end

  def pbCalcDamage(user,target,numTargets=1)
    return if statusMove?
    if target.damageState.disguise
      target.damageState.calcDamage = 1
      return
    end
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    # Get the move's type
    type = @calcType   # nil is treated as physical
    # Calculate whether this hit deals critical damage
    target.damageState.critical = pbIsCritical?(user,target)
    # Calcuate base power of move
    baseDmg = pbBaseDamage(@baseDamage,user,target)
    # Calculate user's attack stat
    atk, atkStage = pbGetAttackStats(user,target)
    if !target.hasActiveAbility?(:UNAWARE) || @battle.moldBreaker
      atkStage = 6 if target.damageState.critical && atkStage<6
      atk = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
    end
    # Calculate target's defense stat
    defense, defStage = pbGetDefenseStats(user,target)
    if !user.hasActiveAbility?(:UNAWARE)
      defStage = 6 if target.damageState.critical && defStage>6
      defense = (defense.to_f*stageMul[defStage]/stageDiv[defStage]).floor
    end
    # Calculate all multiplier effects
    multipliers = {
      :base_damage_multiplier  => 1.0,
      :attack_multiplier       => 1.0,
      :defense_multiplier      => 1.0,
      :final_damage_multiplier => 1.0
    }
    pbCalcDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
    # Main damage calculation
    baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
    atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
    defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
    damage  = (((2.0 * user.level / 5 + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
    damage  = [(damage  * multipliers[:final_damage_multiplier]).round, 1].max
    target.damageState.calcDamage = damage
  end

  def pbCalcDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
    # Global abilities
    if (@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
       (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY) ||
       (@battle.pbCheckGlobalAbility(:GAIAFORCE) && type == :GROUND)
      if @battle.pbCheckGlobalAbility(:AURABREAK)
        multipliers[:base_damage_multiplier] *= 2 / 3.0
      else
        multipliers[:base_damage_multiplier] *= 4 / 3.0
      end
    end
    # Ability effects that alter damage
    if user.abilityActive?
      BattleHandlers.triggerDamageCalcUserAbility(user.ability,
         user,target,self,multipliers,baseDmg,type)
    end
    if !@battle.moldBreaker
      # NOTE: It's odd that the user's Mold Breaker prevents its partner's
      #       beneficial abilities (i.e. Flower Gift boosting Atk), but that's
      #       how it works.
      user.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerDamageCalcUserAllyAbility(b.ability,
           user,target,self,multipliers,baseDmg,type)
      end
      if target.abilityActive?
        BattleHandlers.triggerDamageCalcTargetAbility(target.ability,
           user,target,self,multipliers,baseDmg,type) if !@battle.moldBreaker
        BattleHandlers.triggerDamageCalcTargetAbilityNonIgnorable(target.ability,
           user,target,self,multipliers,baseDmg,type)
      end
      target.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerDamageCalcTargetAllyAbility(b.ability,
           user,target,self,multipliers,baseDmg,type)
      end
    end
    # Item effects that alter damage
    if user.itemActive?
      BattleHandlers.triggerDamageCalcUserItem(user.item,
         user,target,self,multipliers,baseDmg,type)
    end
    if target.itemActive?
      BattleHandlers.triggerDamageCalcTargetItem(target.item,
         user,target,self,multipliers,baseDmg,type)
    end
    # Parental Bond's second attack
    if user.effects[PBEffects::ParentalBond]==1
      multipliers[:base_damage_multiplier] /= 4
    end
    if user.effects[PBEffects::EchoChamber]==1
      multipliers[:base_damage_multiplier] /= 4
    end
    # Other
    if user.effects[PBEffects::MeFirst]
      multipliers[:base_damage_multiplier] *= 1.5
    end
    if user.effects[PBEffects::HelpingHand] && !self.is_a?(PokeBattle_Confusion)
      multipliers[:base_damage_multiplier] *= 1.5
    end
    if user.effects[PBEffects::Charge]>0 && type == :ELECTRIC
      multipliers[:base_damage_multiplier] *= 2
    end
    # Mud Sport
    if type == :ELECTRIC
      @battle.eachBattler do |b|
        next if !b.effects[PBEffects::MudSport]
        multipliers[:base_damage_multiplier] /= 3
        break
      end
      if @battle.field.effects[PBEffects::MudSportField]>0
        multipliers[:base_damage_multiplier] /= 3
      end
    end
    # Water Sport
    if type == :FIRE
      @battle.eachBattler do |b|
        next if !b.effects[PBEffects::WaterSport]
        multipliers[:base_damage_multiplier] /= 3
        break
      end
      if @battle.field.effects[PBEffects::WaterSportField]>0
        multipliers[:base_damage_multiplier] /= 3
      end
    end
    # Terrain moves
    case @battle.field.terrain
    when :Electric
      multipliers[:base_damage_multiplier] *= 1.5 if type == :ELECTRIC && user.affectedByTerrain?
    when :Grassy
      multipliers[:base_damage_multiplier] *= 1.5 if type == :GRASS && user.affectedByTerrain?
    when :Psychic
      multipliers[:base_damage_multiplier] *= 1.5 if type == :PSYCHIC && user.affectedByTerrain?
    when :Misty
      multipliers[:base_damage_multiplier] /= 2 if type == :DRAGON && target.affectedByTerrain?
    end
    # Badge multipliers
    if @battle.internalBattle
      if user.pbOwnedByPlayer?
        if physicalMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_ATTACK
          multipliers[:attack_multiplier] *= 1.1
        elsif specialMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPATK
          multipliers[:attack_multiplier] *= 1.1
        end
      end
      if target.pbOwnedByPlayer?
        if physicalMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_DEFENSE
          multipliers[:defense_multiplier] *= 1.1
        elsif specialMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPDEF
          multipliers[:defense_multiplier] *= 1.1
        end
      end
    end
    # Multi-targeting attacks
    if numTargets>1
      multipliers[:final_damage_multiplier] *= 0.75
    end
    # Weather
    case @battle.pbWeather
    when :Sun, :HarshSun
      if type == :FIRE
        multipliers[:final_damage_multiplier] *= 1.5
      elsif type == :WATER && !target.hasActiveAbility?(:STEAMPOWERED)
        multipliers[:final_damage_multiplier] /= 2
      end
    when :Rain, :HeavyRain
      if type == :FIRE && !target.hasActiveAbility?(:STEAMPOWERED)
        multipliers[:final_damage_multiplier] /= 2
      elsif type == :WATER
        multipliers[:final_damage_multiplier] *= 1.5
      end
    when :Starstorm
     if type == :COSMIC
       multipliers[:final_damage_multiplier] *= 1.5
     elsif type == :STEEL
       multipliers[:final_damage_multiplier] /= 2
     elsif target.pbHasType?(:COSMIC) && (physicalMove? || @function="122")
	     multipliers[:defense_multiplier] *= 1.5
     end
    when :Windy
      if type == :FLYING
        multipliers[:final_damage_multiplier] *= 1.5
	    elsif type == :ROCK
        multipliers[:final_damage_multiplier] /= 2
      end
    when :Fog
      if type == :FAIRY
        multipliers[:final_damage_multiplier] *= 1.5
      elsif type == :DRAGON
	      multipliers[:final_damage_multiplier] /= 2
      end
    when :Eclipse
      if type == :DARK
        multipliers[:final_damage_multiplier] *= 1.5
      elsif type == :GHOST
        multipliers[:final_damage_multiplier] *= 1.5
      elsif type == :FAIRY
        multipliers[:final_damage_multiplier] /= 2
      elsif type == :PSYCHIC
        multipliers[:final_damage_multiplier] /= 2
      end
    when :Borealis
      if type == :PSYCHIC
        multipliers[:final_damage_multiplier] *= 1.5
      elsif type == :DARK
        multipliers[:final_damage_multiplier] /= 2
      end
    when :Rainbow
      if type == :GRASS
        multipliers[:final_damage_multiplier] *= 1.5
      elsif type == :ICE
        multipliers[:final_damage_multiplier] /= 2
      end
    when :Overcast
      if type == :GHOST
        multipliers[:final_damage_multiplier] *= 1.5
      end
    when :VolcanicAsh
      if type == :STEEL
        multipliers[:final_damage_multiplier] *= 1.5
      end
    when :Storm
      if type == :FIRE && !target.hasActiveAbility?(:STEAMPOWERED)
        multipliers[:final_damage_multiplier] /= 2
      elsif type == :WATER
        multipliers[:final_damage_multiplier] *= 1.5
      elsif type == :ELECTRIC
        multipliers[:final_damage_multiplier] *= 1.5
      end
    when :Humid
      if type == :BUG
        multipliers[:final_damage_multiplier] *= 1.5
      elsif type == :FIRE
        multipliers[:final_damage_multiplier] /= 2
      end
    when :TimeWarp
      if type == :TIME
        multipliers[:final_damage_multiplier] *= 1.5
      elsif type == :POISON
        multipliers[:final_damage_multiplier] /= 2
      elsif type == :DARK
        multipliers[:final_damage_multiplier] /= 2
      end
    when :Reverb
      if type == :SOUND
        multipliers[:final_damage_multiplier] *= 1.5
      elsif soundMove?
        multipliers[:final_damage_multiplier] *= 1.5
      elsif target.pbHasType?(:SOUND) && (physicalMove? || @function="122")
        multipliers[:defense_multiplier] *= 1.5
      end
    when :Sleet
      if type == :FIRE
        multipliers[:final_damage_multiplier] /= 2
      end
    when :DClear
      if type == :COSMIC
        multipliers[:final_damage_multiplier] *= 1.5
      end
    when :AcidRain
      if type == :POISON
        multipliers[:final_damage_multiplier] *= 1.5
      end
    when :Sandstorm
      if target.pbHasType?(:ROCK) && specialMove? && @function != "122"   # Psyshock
        multipliers[:defense_multiplier] *= 1.5
      end
    end
    # Critical hits
    if target.damageState.critical
      if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
        multipliers[:final_damage_multiplier] *= 1.5
      else
        multipliers[:final_damage_multiplier] *= 2
      end
    end
    # Random variance
    if !self.is_a?(PokeBattle_Confusion)
      random = 85+@battle.pbRandom(16)
      multipliers[:final_damage_multiplier] *= random / 100.0
    end
    # STAB
    if type && user.pbHasType?(type)
      if user.hasActiveAbility?(:ADAPTABILITY)
        multipliers[:final_damage_multiplier] *= 2
      else
        multipliers[:final_damage_multiplier] *= 1.5
      end
    end
    # Type effectiveness
    multipliers[:final_damage_multiplier] *= target.damageState.typeMod.to_f / Effectiveness::NORMAL_EFFECTIVE
    # Burn
    if user.status == :BURN && physicalMove? && damageReducedByBurn? &&
       !user.hasActiveAbility?(:GUTS)
      multipliers[:final_damage_multiplier] /= 2
    end
    # Aurora Veil, Reflect, Light Screen
    if !ignoresReflect? && !target.damageState.critical &&
       !user.hasActiveAbility?(:INFILTRATOR)
      if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
        if @battle.pbSideBattlerCount(target)>1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && physicalMove?
        if @battle.pbSideBattlerCount(target)>1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && specialMove?
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      end
    end
    # Minimize
    if target.effects[PBEffects::Minimize] && tramplesMinimize?(2)
      multipliers[:final_damage_multiplier] *= 2
    end
    # Move-specific base damage modifiers
    multipliers[:base_damage_multiplier] = pbBaseDamageMultiplier(multipliers[:base_damage_multiplier], user, target)
    # Move-specific final damage modifiers
    multipliers[:final_damage_multiplier] = pbModifyDamage(multipliers[:final_damage_multiplier], user, target)
  end

  #=============================================================================
  # Additional effect chance
  #=============================================================================
  def pbAdditionalEffectChance(user,target,effectChance=0)
    return 0 if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
    ret = (effectChance>0) ? effectChance : @addlEffect
    if Settings::MECHANICS_GENERATION >= 6 || @function != "0A4"   # Secret Power
      ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) ||
                  user.pbOwnSide.effects[PBEffects::Rainbow]>0
    end
    ret = 100 if $DEBUG && Input.press?(Input::CTRL)
    return ret
  end

  # NOTE: Flinching caused by a move's effect is applied in that move's code,
  #       not here.
  def pbFlinchChance(user,target)
    return 0 if flinchingMove?
    return 0 if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
    ret = 0
    if user.hasActiveAbility?(:STENCH,true)
      ret = 10
    elsif user.hasActiveItem?([:KINGSROCK,:RAZORFANG],true)
      ret = 10
    end
    ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) ||
                user.pbOwnSide.effects[PBEffects::Rainbow]>0
    return ret
  end
end


BattleHandlers::SpeedCalcAbility.add(:SANDRUSH,
  proc { |ability,battler,mult|
    next mult * 2 if [:Sandstorm, :DustDevil].include?(battler.battle.pbWeather)
  }
)

BattleHandlers::SpeedCalcAbility.add(:SLUSHRUSH,
  proc { |ability,battler,mult|
    next mult * 2 if [:Hail, :Sleet].include?(battler.battle.pbWeather)
  }
)

BattleHandlers::SpeedCalcAbility.add(:STARSPRINT,
  proc { |ability,battler,mult|
    next mult * 2 if [:Starstorm].include?(battler.battle.pbWeather)
  }
)

module BattleHandlers
  StatLossImmunityAbilityNonIgnorableSandy = AbilityHandlerHash.new   # Unshaken
  def self.triggerStatLossImmunityAbilityNonIgnorableSandy(ability,battler,stat,battle,showMessages)
    ret = StatLossImmunityAbilityNonIgnorableSandy.trigger(ability,battler,stat,battle,showMessages)
    return (ret!=nil) ? ret : false
  end
end

BattleHandlers::StatLossImmunityAbilityNonIgnorableSandy.add(:UNSHAKEN,
  proc { |ability,battler,stat,battle,showMessages|
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",battler.pbThis,battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:WATERCOMPACTION,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:WATER,:SPECIAL_DEFENSE,2,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:LEGENDARMOR,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:DRAGON,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:UNTAINTED,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityAbility(user,target,move,type,:DARK,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:CORRUPTION,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityAbility(user,target,move,type,:FAIRY,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:DIMENSIONBLOCK,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityAbility(user,target,move,type,:COSMIC,battle) || pbBattleMoveImmunityAbility(user,target,move,type,:TIME,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:MENTALBLOCK,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityAbility(user,target,move,type,:PSYCHIC,battle)
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:STELLARIZE,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:COSMIC)
    move.powerBoost = true
    next :COSMIC
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:ENTYMATE,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:BUG)
    move.powerBoost = true
    next :BUG
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:AERILATE,:PIXILATE,:REFRIGERATE,:GALVANIZE,:ENTYMATE,:STELLARIZE)

BattleHandlers::DamageCalcUserAbility.add(:COMPOSURE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 2 if move.specialMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:AMPLIFIER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] = (mults[:base_damage_multiplier]*1.5).round if move.soundMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TIGHTFOCUS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] = (mults[:base_damage_multiplier]*1.5).round if move.beamMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:VAMPIRIC,
  proc { |ability,user,target,move,mults,baseDmg,type|
  mults[:base_damage_multiplier] = (mults[:base_damage_multiplier]*1.5).round if move.function=="14F" || move.function=="0DD"
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:ICESCALES,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:defense_multiplier] *= 2 if move.specialMove? || !move.function=="122"   # Psyshock
  }
)

BattleHandlers::EORWeatherAbility.add(:ACCLIMATE,
  proc { |ability,weather,battler,battle|
    newWeather = 0
    oldWeather = battle.field.weather
    newForm = battler.form
    newWeather = newForm
    battle.eachOtherSideBattler(battler.index) do |b|
    targetTypes = b.pbTypes
    type1 = targetTypes[0]
    type2 = targetTypes[1] if targetTypes.length>1
    case type1
    when 0
      case type2
      when 7, 14, 20; newWeather = 7
      when 18; newWeather = 16
      when 2, 21; newWeather = 19
      when 6; newWeather = 1
      when 0,1,3,4,5,8,9,10,11,12,13,15,16,17,19, nil; newWeather = 15
      end
    when 1
      case type2
      when 3, 19; newWeather = 17
      when 8; newWeather = 6
      when 2, 10; newWeather = 19
      when 0,1,4,5,6,7,9,11,12,13,14,15,16,17,18,20,21, nil; newWeather = 4
      end
    when 2
      case type2
      when 4, 15, 16, 21; newWeather = 3
      when 10; newWeather = 19
      when 0,1,2,3,5,6,7,8,9,11,12,13,14,17,18,19,20, nil; newWeather = 9
      end
    when 5
      case type2
      when 15, 17; newWeather = 15
      when 2, 6, 12, 20, 21, 18; newWeather = 16
      when 11, 4; newWeather = 13
      when 10; newWeather = 2
      when 19; newWeather = 19
      when 0, 1, 3, 7, 8, 13, 16, 14, nil; newWeather = 14
      end
    when 4
      case type2
      when 11, 5, 13; newWeather = 13
      when 16, 2, 21; newWeather = 3
      when 19; newWeather = 17
      when 20; newWeather = 5
      when 0,1,3,4,6,7,8,9,10,12,14,15,17,18, nil; newWeather = 2
      end
    when 3
      case type2
      when 17, 8, 13, 5, 10, 14; newWeather = 14
      when 20; newWeather = 16
      when 21; newWeather = 12
      when 7; newWeather = 5
      when 0,1,2,3,4,6,9,11,12,15,16,18,19, nil; newWeather = 17
      end
    when 6
      case type2
      when 4, 11, 1; newWeather = 8
      when 12, 8, 19; newWeather = 1
      when 20; newWeather = 16
      when 0,2,3,5,6,7,9,10,13,14,15,16,17,18,21, nil; newWeather = 12
      end
    when 7
      case type2
      when 1, 17; newWeather = 4
      when 18; newWeather = 16
      when 6; newWeather = 1
      when 0,2,3,4,5,7,8,9,10,11,12,13,14,15,16,19,20,21, nil; newWeather = 7
      end
    when 8
      case type2
      when 11; newWeather = 9
      when 20; newWeather = 7
      when 10, 5; newWeather = 14
      when 17, 0; newWeather = 15
      when 16; newWeather = 6
      when 2,3,4,6,7,8,9,12,13,14,15,18,19,21, nil; newWeather = 1
      end
    when 12
      case type2
      when 8, 19, 15; newWeather = 1
      when 20, 18; newWeather = 11
      when 16, 4, 2, 21, 13; newWeather = 3
      when 17, 14; newWeather = 18
      when 5; newWeather = 16
      when 0, 1, 3, 6, 7, 10, 11, nil; newWeather = 8
      end
    when 10
      case type2
      when 12; newWeather = 8
      when 11; newWeather = 9
      when 19, 5, 1, 2, 21; newWeather = 19
      when 20; newWeather = 7
      when 16, 13; newWeather = 14
      when 0,3,4,6,7,8,9,10,14,15,17,18, nil; newWeather = 2
      end
    when 11
      case type2
      when 10, 2; newWeather = 9
      when 7; newWeather = 7
      when 4, 5; newWeather = 13
      when 14; newWeather = 20
      when 0,1,3,6,8,9,11,12,13,15,16,17,18,19,20,21, nil; newWeather = 6
      end
    when 13
      case type2
      when 2, 12; newWeather = 3
      when 20; newWeather = 5
      when 6; newWeather = 1
      when 0,1,3,4,5,7,8,9,10,11,13,14,15,16,17,18,19,21, nil; newWeather = 14
      end
    when 15
      case type2
      when 7, 14; newWeather = 7
      when 20, 18, 5; newWeather = 16
      when 21, 10, 2, 3; newWeather = 12
      when 12, 6, 8, 19; newWeather = 1
      when 0, 1, 4, 11, 16, 13, 17, nil; newWeather = 15
      end
    when 14
      case type2
      when 17, 12; newWeather = 18
      when 1, 2, 8, 11; newWeather = 20
      when 15, 18; newWeather = 16
      when 0,3,4,5,6,7,9,10,13,14,16,19,20,21, nil; newWeather = 7
      end
    when 16
      case type2
      when 21, 4, 2, 12; newWeather = 3
      when 17, 1, 20; newWeather = 4
      when 10; newWeather = 12
      when 14; newWeather = 20
      when 0,3,5,6,7,8,9,11,13,15,16,18,19, nil; newWeather = 6
      end
    when 17
      case type2
      when 0,1,2,4,6,7,11,13,16,18,20,21,nil; newWeather = 4
      when 3,10,19; newWeather = 14
      when 12,14; newWeather = 18
      when 5,8,15; newWeather = 15
      end
    when 18
      case type2
      when 10, 21; newWeather = 11
      when 14, 7, 20; newWeather = 16
      when 0,1,2,3,4,5,6,8,9,11,12,13,15,16,17,18,19, nil; newWeather = 6
      end
    when 19
      case type2
      when 8; newWeather = 6
      when 4; newWeather = 13
      when 7; newWeather = 7
      when 3, 1; newWeather = 17
      when 15, 12, 6; newWeather = 1
      when 0,2,5,9,10,11,13,14,16,17,18,19,20,21, nil; newWeather = 19
      end
    when 20
      case type2
      when 0, 17; newWeather = 11
      when 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,19,20,21, nil; newWeather = 5
      end
    when 21
      case type2
      when 4, 2, 12, 16; newWeather = 3
      when 3, 5, 8; newWeather = 14
      when 1; newWeather = 4
      when 11; newWeather = 6
      when 0,6,7,9,10,13,14,15,16,17,18,19,20,21, nil; newWeather = 12
      end
    end
  end
  if newWeather==newForm
    weatherChange = battle.field.weather
    break
  end
  case newWeather
  when 1; weatherChange = :Sun  if weather != :Sun
  when 2; weatherChange = :Rain  if weather != :Rain
  when 3; weatherChange = :Sleet  if weather != :Sleet
  when 4; weatherChange = :Fog  if weather != :Fog
  when 5; weatherChange = :Overcast  if weather != :Overcast
  when 6; weatherChange = :Starstorm  if weather != :Starstorm
  when 7; weatherChange = :Eclipse  if weather != :Eclipse
  when 8; weatherChange = :Windy  if weather != :Windy
  when 9; weatherChange = :HeatLight  if weather != :HeatLight
  when 10; weatherChange = :StrongWinds  if weather != :StrongWinds
  when 11; weatherChange = :AcidRain  if weather != :AcidRain
  when 12; weatherChange = :Sandstorm  if weather != :Sandstorm
  when 13; weatherChange = :Rainbow  if weather != :Rainbow
  when 14; weatherChange = :DustDevil  if weather != :DustDevil
  when 15; weatherChange = :DAshfall  if weather != :DAshfall
  when 16; weatherChange = :VolcanicAsh  if weather != :VolcanicAsh
  when 17; weatherChange = :Borealis  if weather != :Borealis
  when 18; weatherChange = :Humid  if weather != :Humid
  when 19; weatherChange = :TimeWarp  if weather != :TimeWarp
  when 20; weatherChange = :Reverb  if weather != :Reverb
  end
  battle.pbShowAbilitySplash(battler)
  battle.field.weather = weatherChange
  battle.field.weatherDuration = 5
  @weatherType = weatherChange
  case weatherChange
  when :Starstorm;   battle.pbDisplay(_INTL("Stars fill the sky."))
  when :Thunder;     battle.pbDisplay(_INTL("Lightning flashes in th sky."))
  when :Humid;       battle.pbDisplay(_INTL("The air is humid."))
  when :Overcast;    battle.pbDisplay(_INTL("The sky is overcast."))
  when :Eclipse;     battle.pbDisplay(_INTL("The sky is dark."))
  when :Fog;         battle.pbDisplay(_INTL("The fog is deep."))
  when :AcidRain;    battle.pbDisplay(_INTL("Acid rain is falling."))
  when :VolcanicAsh; battle.pbDisplay(_INTL("Volcanic Ash sprinkles down."))
  when :Rainbow;     battle.pbDisplay(_INTL("A rainbow crosses the sky."))
  when :Borealis;    battle.pbDisplay(_INTL("The sky is ablaze with color."))
  when :TimeWarp;    battle.pbDisplay(_INTL("Time has stopped."))
  when :Reverb;      battle.pbDisplay(_INTL("A dull echo hums."))
  when :DClear;      battle.pbDisplay(_INTL("The sky is distorted."))
  when :DRain;       battle.pbDisplay(_INTL("Rain is falling upward."))
  when :DWind;       battle.pbDisplay(_INTL("The wind is haunting."))
  when :DAshfall;    battle.pbDisplay(_INTL("Ash floats in midair."))
  when :Sleet;       battle.pbDisplay(_INTL("Sleet began to fall."))
  when :Windy;       battle.pbDisplay(_INTL("There is a slight breeze."))
  when :HeatLight;   battle.pbDisplay(_INTL("Static fills the air."))
  when :DustDevil;   battle.pbDisplay(_INTL("A dust devil approaches."))
  when :Sun;         battle.pbDisplay(_INTL("The sunlight is strong."))
  when :Rain;        battle.pbDisplay(_INTL("It is raining."))
  when :Sandstorm;   battle.pbDisplay(_INTL("A sandstorm is raging."))
  when :Hail;        battle.pbDisplay(_INTL("Hail is falling."))
  when :HarshSun;    battle.pbDisplay(_INTL("The sunlight is extremely harsh."))
  when :HeavyRain;   battle.pbDisplay(_INTL("It is raining heavily."))
  when :StrongWinds; battle.pbDisplay(_INTL("The wind is strong."))
  when :ShadowSky;   battle.pbDisplay(_INTL("The sky is shadowy."))
  end
    newForm = newWeather
    if @form!=newForm
      battler.pbChangeForm(newForm,_INTL("{1} transformed!",battler.pbThis))
    end
    oldWeather = weatherChange
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORWeatherAbility.copy(:ACCLIMATE,:BAROMETRIC)

BattleHandlers::EORHealingAbility.add(:RESURGENCE,
  proc { |ability,battler,battle|
    next if !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp/16)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORHealingAbility.add(:ASPIRANT,
  proc { |ability,battler,battle|
    wishHeal = $game_variables[103]
    $game_variables[101] -= 1
    if $game_variables[101]==0
      wishMaker = $game_variables[102]
      battler.pbRecoverHP(wishHeal)
      battle.pbDisplay(_INTL("{1}'s wish came true!",wishMaker))
    end
    next if $game_variables[101]>0
    if $game_variables[101]<0
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        $game_variables[103] = (battler.totalhp/2)
        $game_variables[102] = battler.pbThis
        $game_variables[101] += 2
        battle.pbDisplay(_INTL("{1} made a wish!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1} made a wish with {2}",battler.pbThis,battler.abilityName))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORHealingAbility.add(:HOPEFULTOLL,
  proc { |ability,battler,battle|
    battler.status = 0
    def pbAromatherapyHeal(pkmn,battler=nil)
      oldStatus = (battler) ? battler.status : pkmn.status
      curedName = (battler) ? battler.pbThis : pkmn.name
      if battler
        battler.pbCureStatus(false)
      else
        pkmn.status      = 0
        pkmn.statusCount = 0
      end
    end
    battle.pbShowAbilitySplash(battler)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} rang a healing bell!",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} sounded a {2}",battler.pbThis,battler.abilityName))
    end
    battle.pbParty(battler.index).each_with_index do |pkmn,i|
      next if !pkmn || !pkmn.able? || pkmn.status==0
      pkmn.status = 0
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:GAIAFORCE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is gathering power from the earth!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DUAT,
  proc { |ability,battler,battle|
    battler.effects[PBEffects::Type3] = :TIME
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is shrouded in the Duat !",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:EQUINOX,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Starstorm, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:NIGHTFALL,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Eclipse, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SHROUD,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Fog, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:BOREALIS,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Borealis, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:HAILSTORM,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Sleet, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:GALEFORCE,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Windy, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PINDROP,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Reverb, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:WORMHOLE,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:TimeWarp, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MINDGAMES,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler)
      b.pbLowerSpAtkStatStageMindGames(battler)
      b.pbItemOnIntimidatedCheck
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MEDUSOID,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler)
      b.pbLowerSpeedStatStageMedusoid(battler)
      b.pbItemOnIntimidatedCheck
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DIMENSIONSHIFT,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    if battle.field.effects[PBEffects::TrickRoom] > 0
      battle.field.effects[PBEffects::TrickRoom] = 0
      battle.pbDisplay(_INTL("{1} reverted the dimensions!",battler.pbThis))
    end
    if battle.field.weather == :TimeWarp
      battle.field.effects[PBEffects::TrickRoom] = 7
      battle.pbDisplay(_INTL("{1} twisted the dimensions!",battler.pbThis))
    else
      battle.field.effects[PBEffects::TrickRoom] = 5
      battle.pbDisplay(_INTL("{1} twisted the dimensions!",battler.pbThis))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:CACOPHONY,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is creating an uproar!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)
#===================================
# Item Scripts
#===================================
module ItemHandlers

  def pbRaiseEffortValues(pkmn, stat, evGain = 10, ev_limit = true)
    stat = GameData::Stat.get(stat).id
    return 0 if ev_limit && pkmn.ev[stat] >= 252
    evTotal = 0
    GameData::Stat.each_main { |s| evTotal += pkmn.ev[s.id] }
    evGain = evGain.clamp(0, Pokemon::EV_STAT_LIMIT - pkmn.ev[stat])
    evGain = evGain.clamp(0, 252 - pkmn.ev[stat]) if ev_limit
    evGain = evGain.clamp(0, Pokemon::EV_LIMIT - evTotal)
    if evGain > 0
      pkmn.ev[stat] += evGain
      pkmn.calc_stats
    end
    return evGain
  end

  def pbRaiseHappinessAndLowerEV(pkmn,scene,stat,messages)
    h = pkmn.happiness<255
    e = pkmn.ev[stat]>0
    if !h && !e
      scene.pbDisplay(_INTL("It won't have any effect."))
      return false
    end
    if h
      pkmn.changeHappiness("evberry")
    end
    if e
      pkmn.ev[stat] = 0
      pkmn.calc_stats
    end
    scene.pbRefresh
    scene.pbDisplay(messages[2-(h ? 0 : 2)-(e ? 0 : 1)])
    return true
  end

  def canUseMoveCut?
    showmsg = true
     return false if !$PokemonBag.pbQuantity(:CHAINSAW)==0
     facingEvent = $game_player.pbFacingEvent
     if !facingEvent || !facingEvent.name[/cuttree/i]
       pbMessage(_INTL("Can't use that here.")) if showmsg
       return false
     end
     return true
  end
  def useMoveCut
    if !pbHiddenMoveAnimation(nil)
      pbMessage(_INTL("{1} used a {2}!",$Trainer.name,GameData::Item.get(:CHAINSAW).name))
    end
    facingEvent = $game_player.pbFacingEvent
    if facingEvent
      pbSmashEvent(facingEvent)
    end
    return true
  end

  def canUseMoveDive?
     showmsg = true
     return false if !$PokemonBag.pbQuantity(:SCUBATANK)==0
     if $PokemonGlobal.diving
       surface_map_id = nil
       GameData::MapMetadata.each do |map_data|
         next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
         surface_map_id = map_data.id
         break
       end
       if !surface_map_id ||
          !$MapFactory.getTerrainTag(surface_map_id, $game_player.x, $game_player.y).can_dive
         pbMessage(_INTL("Can't use that here.")) if showmsg
         return false
       end
     else
       if !GameData::MapMetadata.exists?($game_map.map_id) ||
          !GameData::MapMetadata.get($game_map.map_id).dive_map_id
         pbMessage(_INTL("Can't use that here.")) if showmsg
         return false
       end
       if !$game_player.terrain_tag.can_dive
         pbMessage(_INTL("Can't use that here.")) if showmsg
         return false
       end
     end
     return true
  end
  def useMoveDive
    wasdiving = $PokemonGlobal.diving
    if $PokemonGlobal.diving
      dive_map_id = nil
      GameData::MapMetadata.each do |map_data|
        next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
        dive_map_id = map_data.id
        break
      end
    else
      map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
      dive_map_id = map_metadata.dive_map_id if map_metadata
    end
    return false if !dive_map_id
    if !pbHiddenMoveAnimation(pokemon)
      pbMessage(_INTL("{1} used a {2}!",$Trainer.name,GameData::Item.get(:SCUBATANK).name))
    end
    pbFadeOutIn {
      $game_temp.player_new_map_id    = dive_map_id
      $game_temp.player_new_x         = $game_player.x
      $game_temp.player_new_y         = $game_player.y
      $game_temp.player_new_direction = $game_player.direction
      $PokemonGlobal.surfing = wasdiving
      $PokemonGlobal.diving  = !wasdiving
      pbUpdateVehicle
      $scene.transfer_player(false)
      $game_map.autoplay
      $game_map.refresh
    }
    return true
  end

  def canUseMoveFlash?
     showmsg = true
     if !GameData::MapMetadata.exists?($game_map.map_id) ||
        !GameData::MapMetadata.get($game_map.map_id).dark_map
       pbMessage(_INTL("Can't use that here.")) if showmsg
       return false
     end
     if $PokemonGlobal.flashUsed
       pbMessage(_INTL("Flash is already being used.")) if showmsg
       return false
     end
     return true
  end
  def useMoveFlash
    darkness = $PokemonTemp.darknessSprite
    return false if !darkness || darkness.disposed?
    if !pbHiddenMoveAnimation(nil)
      pbMessage(_INTL("{1} used a {2}!",$Trainer.name,GameData::Item.get(:TORCH).name))
    end
    $PokemonGlobal.flashUsed = true
    radiusDiff = 8*20/Graphics.frame_rate
    while darkness.radius<darkness.radiusMax
      Graphics.update
      Input.update
      pbUpdateSceneMap
      darkness.radius += radiusDiff
      darkness.radius = darkness.radiusMax if darkness.radius>darkness.radiusMax
    end
    return true
  end

  def canUseMoveFly?
    showmsg = true
    return false if !$PokemonBag.pbQuantity(:WINGSUIT)==0
    if $game_player.pbHasDependentEvents?
      pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
      return false
    end
    if !GameData::MapMetadata.exists?($game_map.map_id) ||
       !GameData::MapMetadata.get($game_map.map_id).outdoor_map
      pbMessage(_INTL("Can't use that here.")) if showmsg
      return false
    end
    return true
  end
  def useMoveFly
    if !$PokemonTemp.flydata
      pbMessage(_INTL("Can't use that here."))
      return false
    end
    if !pbHiddenMoveAnimation(pokemon)
      pbMessage(_INTL("{1} used the {2}!",$Trainer.name,GameData::Item.get(:WINGSUIT).name))
    end
    pbFadeOutIn {
      for i in 115..121
        $game_switches[i] = false
      end
      $game_switches[125] = false
      $game_temp.player_new_map_id    = $PokemonTemp.flydata[0]
      $game_temp.player_new_x         = $PokemonTemp.flydata[1]
      $game_temp.player_new_y         = $PokemonTemp.flydata[2]
      $game_temp.player_new_direction = 2
      $PokemonTemp.flydata = nil
      $scene.transfer_player
      $game_map.autoplay
      $game_map.refresh
    }
    pbEraseEscapePoint
    return true
  end

  def canUseMoveRockSmash?
    showmsg = true
    return false if !$PokemonBag.pbQuantity(:HAMMER)==0
    facingEvent = $game_player.pbFacingEvent
    if !facingEvent || !facingEvent.name[/smashrock/i]
      pbMessage(_INTL("Can't use that here.")) if showmsg
      return false
    end
    return true
  end
  def useMoveRockSmash
    if !pbHiddenMoveAnimation(nil)
      pbMessage(_INTL("{1} used a {2}!",$Trainer.name,GameData::Item.get(:HAMMER).name))
    end
    facingEvent = $game_player.pbFacingEvent
    if facingEvent
      pbSmashEvent(facingEvent)
      pbRockSmashRandomEncounter
    end
    return true
  end

  def canUseMoveStrength?
     showmsg = true
     return false if !$PokemonBag.pbQuantity(:FULCRUM)==0
     if $PokemonMap.strengthUsed
       pbMessage(_INTL("The Fulcrum is already being used.")) if showmsg
       return false
     end
     return true
  end
  def useMoveStrength
    if !pbHiddenMoveAnimation(nil)
      pbMessage(_INTL("{1} used a {2}!\1",$Trainer.name,GameData::Item.get(:FULCRUM).name))
    end
    pbMessage(_INTL("{1}'s {2} made it possible to move boulders around!",$Trainer.name,GameData::Item.get(:FULCRUM).name))
    $PokemonMap.strengthUsed = true
    return true
  end

  def canUseMoveSurf?
     showmsg = true
     return false if !$PokemonBag.pbQuantity(:HOVERCRAFT)==0
     if $PokemonGlobal.surfing
       pbMessage(_INTL("You're already surfing.")) if showmsg
       return false
     end
     if $game_player.pbHasDependentEvents?
       pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
       return false
     end
     if GameData::MapMetadata.exists?($game_map.map_id) &&
        GameData::MapMetadata.get($game_map.map_id).always_bicycle
       pbMessage(_INTL("Let's enjoy cycling!")) if showmsg
       return false
     end
     if !$game_player.pbFacingTerrainTag.can_surf_freely ||
        !$game_map.passable?($game_player.x,$game_player.y,$game_player.direction,$game_player)
       pbMessage(_INTL("No surfing here!")) if showmsg
       return false
     end
     return true
  end
  def useMoveSurf
    $game_temp.in_menu = false
    pbCancelVehicles
    if !pbHiddenMoveAnimation(nil)
      pbMessage(_INTL("{1} used {2}!",$Trainer.name,GameData::Item.get(:HOVERCRAFT).name))
    end
    surfbgm = GameData::Metadata.get.surf_BGM
    pbCueBGM(surfbgm,0.5) if surfbgm
    pbStartSurfing
    return true
  end

  def canUseMoveWaterfall?
    showmsg = true
    if !$game_player.pbFacingTerrainTag.waterfall
      pbMessage(_INTL("Can't use that here.")) if showmsg
      return false
    end
    return true
  end
  def useMoveWaterfall
    if !pbHiddenMoveAnimation(pokemon)
      pbMessage(_INTL("{1} used an {2}!",$Trainer.name,GameData::Item.get(:AQUAROCKET).name))
    end
    pbAscendWaterfall
    return true
  end

  def canUseMoveRockClimb?
    showmsg = true
    return false if !$PokemonBag.pbQuantity(:HIKINGGEAR)==0
     if pbFacingTerrainTag!=PBTerrain::RockClimb
       pbMessage(_INTL("Can't use that here.")) if showmsg
       return false
     end
     return true
  end
  def useMoveRockClimb
     if !pbHiddenMoveAnimation(nil)
       pbMessage(_INTL("{1} uses the {2}!",$Trainer.name,GameData::Item.get(:HIKINGGEAR).name))
     end
     if event.direction=8
       pbRockClimbUp
     elsif event.direction=2
       pbRockClimbDown
     end
     return true
  end
end

def pbRockSmashRandomItem
  randItem = rand(100)+1
  return nil if randItem < 51
  if randItem < 76
    pbExclaim(get_character(-1))
    pbWait(8)
    pbMessage(_INTL("Oh, there was an item!"))
    pbItemBall(:HARDSTONE)
  elsif randItem < 86
    pbExclaim(get_character(-1))
    pbWait(8)
    pbMessage(_INTL("Oh, there was an item!"))
    pbItemBall(:NUGGET)
  elsif randItem < 96
    pbExclaim(get_character(-1))
    pbWait(8)
    pbMessage(_INTL("Oh, there was an item!"))
    randFossil = rand(2)
      if randFossil == 1
        pbItemBall(:TOMBSEAL)
      else
        pbItemBall(:ANCIENTTOTEM)
      end
    else
      pbExclaim(get_character(-1))
      pbWait(8)
      pbMessage(_INTL("Oh, there was an item!"))
      pbItemBall(:BIGNUGGET)
  end
end

ItemHandlers::UseOnPokemon.add(:RARECANDY,proc { |item,pkmn,scene|
  if pkmn.level>=GameData::GrowthRate.max_level || pkmn.shadowPokemon? || pkmn.level>=$game_variables[106]
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pbChangeLevel(pkmn,pkmn.level+1,scene)
  scene.pbHardRefresh
  next true
})

ItemHandlers::UseOnPokemon.add(:ADAMANTMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:ADAMANT
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:ADAMANT)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:BRAVEMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:BRAVE
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:BRAVE)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:NAUGHTYMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:NAUGHTY
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:NAUGHTY)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:LONELYMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:LONELY
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:LONELY)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:BOLDMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:BOLD
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:BOLD)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:IMPISHMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:IMPISH
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:IMPISH)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:LAXMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:LAX
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:LAX)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:RELAXEDMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:RELAXED
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:RELAXED)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:MODESTMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:MODEST
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:MODEST)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:MILDMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:MILD
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:MILD)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:RASHMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:RASH
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:RASH)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:QUIETMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:QUIET
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:QUIET)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:CALMMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:CALM
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:CALM)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:GENTLEMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:GENTLE
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:GENTLE)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:CAREFULMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:CAREFUL
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:CAREFUL)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:SASSYMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:SASSY
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:SASSY)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:TIMIDMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:TIMID
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:TIMID)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:HASTYMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:HASTY
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:HASTY)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:JOLLYMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:JOLLY
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:JOLLY)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:NAIVEMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:NAIVE
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:NAIVE)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:BASHFULMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:BASHFUL
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:BASHFUL)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:HARDYMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:HARDY
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:HARDY)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:DOCILEMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:DOCILE
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:DOCILE)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:QUIRKYMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:QUIRKY
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:QUIRKY)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:SERIOUSMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:SERIOUS
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:SERIOUS)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:IVMAXSTONE,proc { |item,pkmn,scene|
  choices = []
  for i in 0...6
    stat = PBStats
    choices.push(_INTL(stat.getName(i)))
  end
  choices.push(_INTL("Cancel"))
  command = pbMessage("Which IV would you like to max out?",choices,choices.length)
  statChoice = (command == 6) ? -1 : command
  next false if statChoice == -1
  if pkmn.iv[statChoice] == 31
    scene.pbDisplay(_INTL("This stat is already maxed out!"))
    return false
  end
  statDisp = stat.getName(statChoice)
    pkmn.iv[statChoice] = 31
    pkmn.calcStats
    scene.pbDisplay(_INTL("{1}'s {2} IVs were maxed out!",pkmn.name,statDisp))
  next true
})

ItemHandlers::UseOnPokemon.add(:IVMINSTONE,proc { |item,pkmn,scene|
  choices = []
  for i in 0...6
    stat = PBStats
    choices.push(_INTL(stat.getName(i)))
  end
  choices.push(_INTL("Cancel"))
  command = pbMessage("Which IV would you like to zero out?",choices,choices.length)
  statChoice = (command == 6) ? -1 : command
  next false if statChoice == -1
  if pkmn.iv[statChoice] == 0
    scene.pbDisplay(_INTL("This stat is already zeroed out!"))
    return false
  end
  statDisp = stat.getName(statChoice)
    pkmn.iv[statChoice] = 0
    pkmn.calcStats
    scene.pbDisplay(_INTL("{1}'s {2} IVs were zeroed out!",pkmn.name,statDisp))
  next true
})

ItemHandlers::UseOnPokemon.add(:POMEGBERRY,proc { |item,pkmn,scene|
  next pbRaiseHappinessAndLowerEV(pkmn,scene,:HP,[
     _INTL("{1} adores you! Its base HP fell!",pkmn.name),
     _INTL("{1} became more friendly. Its base HP can't go lower.",pkmn.name),
     _INTL("{1} became more friendly. However, its base HP fell!",pkmn.name)
  ])
})

ItemHandlers::UseOnPokemon.add(:KELPSYBERRY,proc { |item,pkmn,scene|
  next pbRaiseHappinessAndLowerEV(pkmn,scene,:ATTACK,[
     _INTL("{1} adores you! Its base Attack fell!",pkmn.name),
     _INTL("{1} became more friendly. Its base Attack can't go lower.",pkmn.name),
     _INTL("{1} became more friendly. However, its base Attack fell!",pkmn.name)
  ])
})

ItemHandlers::UseOnPokemon.add(:QUALOTBERRY,proc { |item,pkmn,scene|
  next pbRaiseHappinessAndLowerEV(pkmn,scene,:DEFENSE,[
     _INTL("{1} adores you! Its base Defense fell!",pkmn.name),
     _INTL("{1} became more friendly. Its base Defense can't go lower.",pkmn.name),
     _INTL("{1} became more friendly. However, its base Defense fell!",pkmn.name)
  ])
})

ItemHandlers::UseOnPokemon.add(:HONDEWBERRY,proc { |item,pkmn,scene|
  next pbRaiseHappinessAndLowerEV(pkmn,scene,:SPECIAL_ATTACK,[
     _INTL("{1} adores you! Its base Special Attack fell!",pkmn.name),
     _INTL("{1} became more friendly. Its base Special Attack can't go lower.",pkmn.name),
     _INTL("{1} became more friendly. However, its base Special Attack fell!",pkmn.name)
  ])
})

ItemHandlers::UseOnPokemon.add(:GREPABERRY,proc { |item,pkmn,scene|
  next pbRaiseHappinessAndLowerEV(pkmn,scene,:SPECIAL_DEFENSE,[
     _INTL("{1} adores you! Its base Special Defense fell!",pkmn.name),
     _INTL("{1} became more friendly. Its base Special Defense can't go lower.",pkmn.name),
     _INTL("{1} became more friendly. However, its base Special Defense fell!",pkmn.name)
  ])
})

ItemHandlers::UseOnPokemon.add(:TAMATOBERRY,proc { |item,pkmn,scene|
  next pbRaiseHappinessAndLowerEV(pkmn,scene,:SPEED,[
     _INTL("{1} adores you! Its base Speed fell!",pkmn.name),
     _INTL("{1} became more friendly. Its base Speed can't go lower.",pkmn.name),
     _INTL("{1} became more friendly. However, its base Speed fell!",pkmn.name)
  ])
})

ItemHandlers::UseOnPokemon.add(:ABILITYPATCH,proc { |item,pkmn,scene|
  abils = pkmn.getAbilityList
  abil1 = 0; abil2 = 0; hAbil = 0
  for i in abils
    abil1 = i[0] if i[1]==0
    abil2 = i[0] if i[1]==1
    hAbil = i[0] if i[1]==2
  end
  if pkmn.isSpecies?(:HOPPALM) || pkmn.isSpecies?(:PAPYRUN) || pkmn.isSpecies?(:NEFLORA) || pkmn.isSpecies?(:CHARPHINCH) || pkmn.isSpecies?(:PHIRUNDO) || pkmn.isSpecies?(:PHIRENIX) || pkmn.isSpecies?(:BARBOL) || pkmn.isSpecies?(:BOWLTISIS) || pkmn.isSpecies?(:SATURABTU) || pkmn.isSpecies?(:APOPHICARY) || pkmn.isSpecies?(:FALKMUNRA) || pkmn.isSpecies?(:CASTFORM) || pkmn.isSpecies?(:FORMETEOS) || pkmn.isSpecies?(:UNOWN) || pkmn.isSpecies?(:EYEROGLYPH) || pkmn.isSpecies?(:SPOOKLOTH) || pkmn.isSpecies?(:RELICLOTH) || pkmn.isSpecies?(:CORPUSCUFF) || pkmn.isSpecies?(:YAMASK) || pkmn.isSpecies?(:COFAGRIGUS) || pkmn.isSpecies?(:RUNERIGUS)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  if pkmn.hasHiddenAbility? && abil2 != nil
    abilChoose = rand(2)+1
    newabil = pkmn.abilityIndex-abilChoose
    newabilname = GameData::Ability.get((newabil==0) ? abil1 : abil2)
      if scene.pbConfirm(_INTL("Would you like to change {1}'s Ability to {2}?",pkmn.name,newabilname))
        pkmn.setAbility(newabil)
        scene.pbRefresh
        scene.pbDisplay(_INTL("{1}'s Ability changed to {2}!",pkmn.name,newabilname))
        next true
      end
  elsif pkmn.hasHiddenAbility? && abil2 == nil
    newabil = pkmn.abilityIndex-2
    newabilname = GameData::Ability.get((newabil==0) ? abil1 : abil2)
    if scene.pbConfirm(_INTL("Would you like to change {1}'s Ability to {2}?",pkmn.name,newabilname))
      pkmn.setAbility(newabil)
      scene.pbRefresh
      scene.pbDisplay(_INTL("{1}'s Ability changed to {2}!",pkmn.name,newabilname))
      next true
    end
  else
    !pkmn.hasHiddenAbility?
    newabilname = GameData::Ability.get(hAbil)
    if scene.pbConfirm(_INTL("Would you like to change {1}'s Ability to {2}?",pkmn.name,newabilname))
      pkmn.setAbility(2)
      scene.pbRefresh
      scene.pbDisplay(_INTL("{1}'s Ability changed to {2}!",pkmn.name,newabilname))
      next true
    end
    next false
  end
})

ItemHandlers::UseFromBag.add(:CHAINSAW,proc{|item|
   next canUseMoveCut? ? 2 : 0
})

ItemHandlers::UseInField.add(:CHAINSAW,proc{|item|
   useMoveCut if canUseMoveCut?
})

ItemHandlers::UseFromBag.add(:SCUBATANK,proc{|item|
   next canUseMoveDive? ? 2 : 0
})

ItemHandlers::UseInField.add(:SCUBATANK,proc{|item|
   useMoveDive if canUseMoveDive?
})

ItemHandlers::UseFromBag.add(:TORCH,proc{|item|
   next canUseMoveFlash? ? 2 : 0
})

ItemHandlers::UseInField.add(:TORCH,proc{|item|
   useMoveFlash if canUseMoveFlash?
})

ItemHandlers::UseFromBag.add(:WINGSUIT,proc{|item|
   next canUseMoveFly? ? 2 : 0
})

ItemHandlers::UseInField.add(:WINGSUIT,proc{|item|
   useMoveFly if canUseMoveFly?
})

ItemHandlers::UseInField.add(:ITEMCRAFTER,proc{|item|
   useItemCrafter
})

ItemHandlers::UseFromBag.add(:HAMMER,proc{|item|
   next canUseMoveRockSmash? ? 2 : 0
})

ItemHandlers::UseInField.add(:HAMMER,proc{|item|
   useMoveRockSmash if canUseMoveRockSmash?
})

ItemHandlers::UseFromBag.add(:FULCRUM,proc{|item|
   next canUseMoveStrength? ? 2 : 0
})

ItemHandlers::UseInField.add(:FULCRUM,proc{|item|
   useMoveStrength if canUseMoveStrength?
})

ItemHandlers::UseFromBag.add(:HOVERCRAFT,proc{|item|
   next canUseMoveSurf? ? 2 : 0
})

ItemHandlers::UseInField.add(:HOVERCRAFT,proc{|item|
   useMoveSurf if canUseMoveSurf?
})

ItemHandlers::UseFromBag.add(:AQUAROCKET,proc{|item|
   next canUseMoveWaterfall? ? 2 : 0
})

ItemHandlers::UseInField.add(:AQUAROCKET,proc{|item|
   useMoveWaterfall if canUseMoveWaterfall?
})

ItemHandlers::UseFromBag.add(:HIKINGGEAR,proc{|item|
   next canUseMoveRockClimb? ? 2 : 0
})

ItemHandlers::UseInField.add(:HIKINGGEAR,proc{|item|
   useMoveRockClimb if canUseMoveRockClimb?
})
#===================================
# Misc
#===================================


class PokemonEncounters
  def has_sandy_encounters?
    GameData::EncounterType.each do |enc_type|
      return true if enc_type.type == :sand && has_encounter_type?(enc_type.id)
    end
    return false
  end
  def has_graveyard_encounters?
    GameData::EncounterType.each do |enc_type|
      return true if enc_type.type == :graveyard && has_encounter_type?(enc_type.id)
    end
    return false
  end
  def has_snow_encounters?
    GameData::EncounterType.each do |enc_type|
      return true if enc_type.type == :snow && has_encounter_type?(enc_type.id)
    end
    return false
  end
  def has_high_bridge_encounters?
    GameData::EncounterType.each do |enc_type|
      return true if enc_type.type == :highbridge && has_encounter_type?(enc_type.id)
    end
    return false
  end
  def has_distortion_encounters?
    GameData::EncounterType.each do |enc_type|
      return true if enc_type.type == :distortion && has_encounter_type?(enc_type.id)
    end
    return false
  end
end

GameData::TerrainTag.register({
  :id                     => :Distortion,
  :id_number              => 17,
  :land_wild_encounters   => true,
  :battle_environment     => :Distortion
})

GameData::TerrainTag.register({
  :id                     => :HighBridge,
  :id_number              => 18,
  :land_wild_encounters   => true
})

GameData::TerrainTag.register({
  :id                     => :RockClimb,
  :id_number              => 19
})

GameData::TerrainTag.register({
  :id                     => :Sandy,
  :id_number              => 20,
  :land_wild_encounters   => true,
  :battle_environment     => :Sand
})

GameData::TerrainTag.register({
  :id                     => :Graveyard,
  :id_number              => 21,
  :land_wild_encounters   => true,
  :battle_environment     => :Graveyard
})

GameData::TerrainTag.register({
  :id                     => :Snow,
  :id_number              => 22,
  :land_wild_encounters   => true,
  :battle_environment     => :Ice
})

GameData::EncounterType.register({
  :id             => :Distortion,
  :type           => :distortion,
  :trigger_chance => 5,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})

GameData::EncounterType.register({
  :id             => :HighBridge,
  :type           => :highbridge,
  :trigger_chance => 5,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})

GameData::EncounterType.register({
  :id             => :Graveyard,
  :type           => :graveyard,
  :trigger_chance => 5,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})

GameData::EncounterType.register({
  :id             => :Snow,
  :type           => :snow,
  :trigger_chance => 5,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})

GameData::EncounterType.register({
  :id             => :Sand,
  :type           => :sand,
  :trigger_chance => 5,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})

class PokemonSave_Scene
  def pbStartScreen
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    totalsec = Graphics.frame_count / Graphics.frame_rate
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    mapname=$game_map.name
    textColor = ["7FE00000","463F0000","7FE00000"][$Trainer.gender]
    locationColor = "90F090,000000"   # green
    loctext=_INTL("<ac><c3={1}>{2}</c3></ac>",locationColor,mapname)
    loctext+=_INTL("Player<r><c2={1}>{2}</c2><br>",textColor,$Trainer.name)
    if hour>0
      loctext+=_INTL("Time<r><c2={1}>{2}h {3}m</c2><br>",textColor,hour,min)
    else
      loctext+=_INTL("Time<r><c2={1}>{2}m</c2><br>",textColor,min)
    end
    loctext+=_INTL("Badges<r><c2={1}>{2}</c2><br>",textColor,$Trainer.badge_count)
    if $Trainer.has_pokedex
      loctext+=_INTL("Pokédex<r><c2={1}>{2}/{3}</c2><br>",textColor,$Trainer.pokedex.owned_count,$Trainer.pokedex.seen_count)
    end
    if $game_switches[Readouts::Readout]
      loctext+=_INTL("Readouts<r><c2={1}>{2}</c2>",textColor,$game_variables[Readouts::Count])
    end
    @sprites["locwindow"]=Window_AdvancedTextPokemon.new(loctext)
    @sprites["locwindow"].viewport=@viewport
    @sprites["locwindow"].x=0
    @sprites["locwindow"].y=0
    @sprites["locwindow"].width=228 if @sprites["locwindow"].width<228
    @sprites["locwindow"].visible=true
  end
end

class PokemonPauseMenu_Scene
  def pbStartScene
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["cmdwindow"] = Window_CommandPokemon.new([])
    @sprites["cmdwindow"].visible = false
    @sprites["cmdwindow"].viewport = @viewport
    @sprites["infowindow"] = Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
    @sprites["infowindow"].visible = false
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
    @sprites["helpwindow"].visible = false
    @infostate = false
    @helpstate = false
    $viewport4 = @viewport
    pbSEPlay("GUI menu open")
  end

  def pbShowInfo(text)
    @sprites["infowindow"].resizeToFit(text,Graphics.height)
    @sprites["infowindow"].text    = text
    @sprites["infowindow"].visible = true
    @infostate = true
  end

  def pbShowHelp(text)
    @sprites["helpwindow"].resizeToFit(text,Graphics.height)
    @sprites["helpwindow"].text    = text
    @sprites["helpwindow"].visible = true
    pbBottomLeft(@sprites["helpwindow"])
    @helpstate = true
  end

  def pbShowMenu
    @sprites["cmdwindow"].visible = true
    @sprites["infowindow"].visible = @infostate
    @sprites["helpwindow"].visible = @helpstate
  end

  def pbHideMenu
    @sprites["cmdwindow"].visible = false
    @sprites["infowindow"].visible = false
    @sprites["helpwindow"].visible = false
  end

  def pbShowCommands(commands)
    ret = -1
    cmdwindow = @sprites["cmdwindow"]
    cmdwindow.commands = commands
    cmdwindow.index    = $PokemonTemp.menuLastChoice
    cmdwindow.resizeToFit(commands)
    cmdwindow.x        = Graphics.width-cmdwindow.width
    cmdwindow.y        = 0
    cmdwindow.visible  = true
    loop do
      cmdwindow.update
      Graphics.update
      Input.update
      pbUpdateSceneMap
      if Input.trigger?(Input::BACK)
        ret = -1
        break
      elsif Input.trigger?(Input::USE)
        ret = cmdwindow.index
        $PokemonTemp.menuLastChoice = ret
        break
      end
    end
    return ret
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbRefresh; end
end

class PokemonPauseMenu
  def initialize(scene)
    @scene = scene
  end

  def pbShowMenu
    @scene.pbRefresh
    @scene.pbShowMenu
  end

  def pbStartPokemonMenu
    if !$Trainer
      if $DEBUG
        pbMessage(_INTL("The player trainer was not defined, so the pause menu can't be displayed."))
        pbMessage(_INTL("Please see the documentation to learn how to set up the trainer player."))
      end
      return
    end
    @scene.pbStartScene
    endscene = true
    commands = []
    cmdPokedex  = -1
    cmdPokemon  = -1
    cmdBag      = -1
    cmdTrainer  = -1
    cmdSave     = -1
    cmdOption   = -1
    cmdPokegear = -1
    cmdWeather = -1
    cmdDexnav = -1
    cmdDebug    = -1
    cmdQuit     = -1
    cmdEndGame  = -1
    if $Trainer.has_pokedex && $Trainer.pokedex.accessible_dexes.length > 0
      commands[cmdPokedex = commands.length] = _INTL("Pokédex")
    end
    commands[cmdPokemon = commands.length]   = _INTL("Pokémon") if $Trainer.party_count > 0
    commands[cmdBag = commands.length]       = _INTL("Bag") if !pbInBugContest?
    commands[cmdPokegear = commands.length]  = _INTL("Pokégear") if $Trainer.has_pokegear
    commands[cmdDexnav = commands.length]  = _INTL("DexNav") if $game_switches[401]
    commands[cmdWeather = commands.length]  = _INTL("Weather Readout") if $game_switches[Readouts::Readout]
    commands[cmdTrainer = commands.length]   = $Trainer.name
    if pbInSafari?
      if Settings::SAFARI_STEPS <= 0
        @scene.pbShowInfo(_INTL("Balls: {1}",pbSafariState.ballcount))
      else
        @scene.pbShowInfo(_INTL("Steps: {1}/{2}\nBalls: {3}",
           pbSafariState.steps, Settings::SAFARI_STEPS, pbSafariState.ballcount))
      end
      commands[cmdQuit = commands.length]    = _INTL("Quit")
    elsif pbInBugContest?
      if pbBugContestState.lastPokemon
        @scene.pbShowInfo(_INTL("Caught: {1}\nLevel: {2}\nBalls: {3}",
           pbBugContestState.lastPokemon.speciesName,
           pbBugContestState.lastPokemon.level,
           pbBugContestState.ballcount))
      else
        @scene.pbShowInfo(_INTL("Caught: None\nBalls: {1}",pbBugContestState.ballcount))
      end
      commands[cmdQuit = commands.length]    = _INTL("Quit Contest")
    else
      commands[cmdSave = commands.length]    = _INTL("Save") if $game_system && !$game_system.save_disabled
    end
    commands[cmdOption = commands.length]    = _INTL("Options")
    commands[cmdDebug = commands.length]     = _INTL("Debug") if $DEBUG
    commands[cmdEndGame = commands.length]   = _INTL("Quit Game")
    loop do
      command = @scene.pbShowCommands(commands)
      if cmdPokedex>=0 && command==cmdPokedex
        pbPlayDecisionSE
        if Settings::USE_CURRENT_REGION_DEX
          pbFadeOutIn {
            scene = PokemonPokedex_Scene.new
            screen = PokemonPokedexScreen.new(scene)
            screen.pbStartScreen
            @scene.pbRefresh
          }
        else
          if $Trainer.pokedex.accessible_dexes.length == 1
            $PokemonGlobal.pokedexDex = $Trainer.pokedex.accessible_dexes[0]
            pbFadeOutIn {
              scene = PokemonPokedex_Scene.new
              screen = PokemonPokedexScreen.new(scene)
              screen.pbStartScreen
              @scene.pbRefresh
            }
          else
            pbFadeOutIn {
              scene = PokemonPokedexMenu_Scene.new
              screen = PokemonPokedexMenuScreen.new(scene)
              screen.pbStartScreen
              @scene.pbRefresh
            }
          end
        end
      elsif cmdPokemon>=0 && command==cmdPokemon
        pbPlayDecisionSE
        hiddenmove = nil
        pbFadeOutIn {
          sscene = PokemonParty_Scene.new
          sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
          hiddenmove = sscreen.pbPokemonScreen
          (hiddenmove) ? @scene.pbEndScene : @scene.pbRefresh
        }
        if hiddenmove
          $game_temp.in_menu = false
          pbUseHiddenMove(hiddenmove[0],hiddenmove[1])
          return
        end
      elsif cmdBag>=0 && command==cmdBag
        pbPlayDecisionSE
        item = nil
        pbFadeOutIn {
          scene = PokemonBag_Scene.new
          screen = PokemonBagScreen.new(scene,$PokemonBag)
          item = screen.pbStartScreen
          (item) ? @scene.pbEndScene : @scene.pbRefresh
        }
        if item
          $game_temp.in_menu = false
          pbUseKeyItemInField(item)
          return
        end
      elsif cmdPokegear>=0 && command==cmdPokegear
        pbPlayDecisionSE
        pbFadeOutIn {
          scene = PokemonPokegear_Scene.new
          screen = PokemonPokegearScreen.new(scene)
          screen.pbStartScreen
          @scene.pbRefresh
        }
      elsif cmdWeather>=0 && command==cmdWeather
        pbPlayDecisionSE
        pbFadeOutIn {
          scene = PokemonWeather_Scene.new
          screen = PokemonWeatherScreen.new(scene)
          screen.pbStartScreen
          @scene.pbRefresh
        }
      elsif cmdDexnav>=0 && command==cmdDexnav
        pbPlayDecisionSE
        $viewport4.dispose
        pbFadeOutIn {
          if $currentDexSearch != nil && $currentDexSearch.is_a?(Array)
            pbMessage(_INTL("<c2=7FE00000>You are already searching!</c2>"))
            break
          end
          @scene = NewDexNav.new
          return
        }
      elsif cmdTrainer>=0 && command==cmdTrainer
        pbPlayDecisionSE
        pbFadeOutIn {
          scene = PokemonTrainerCard_Scene.new
          screen = PokemonTrainerCardScreen.new(scene)
          screen.pbStartScreen
          @scene.pbRefresh
        }
      elsif cmdQuit>=0 && command==cmdQuit
        @scene.pbHideMenu
        if pbInSafari?
          if pbConfirmMessage(_INTL("Would you like to leave the Safari Game right now?"))
            @scene.pbEndScene
            pbSafariState.decision = 1
            pbSafariState.pbGoToStart
            return
          else
            pbShowMenu
          end
        else
          if pbConfirmMessage(_INTL("Would you like to end the Contest now?"))
            @scene.pbEndScene
            pbBugContestState.pbStartJudging
            return
          else
            pbShowMenu
          end
        end
      elsif cmdSave>=0 && command==cmdSave
        @scene.pbHideMenu
        scene = PokemonSave_Scene.new
        screen = PokemonSaveScreen.new(scene)
        if screen.pbSaveScreen
          @scene.pbEndScene
          endscene = false
          break
        else
          pbShowMenu
        end
      elsif cmdOption>=0 && command==cmdOption
        pbPlayDecisionSE
        pbFadeOutIn {
          scene = PokemonOption_Scene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen
          pbUpdateSceneMap
          @scene.pbRefresh
        }
      elsif cmdDebug>=0 && command==cmdDebug
        pbPlayDecisionSE
        pbFadeOutIn {
          pbDebugMenu
          @scene.pbRefresh
        }
      elsif cmdEndGame>=0 && command==cmdEndGame
        @scene.pbHideMenu
        if pbConfirmMessage(_INTL("Are you sure you want to quit the game?"))
          scene = PokemonSave_Scene.new
          screen = PokemonSaveScreen.new(scene)
          if screen.pbSaveScreen
            @scene.pbEndScene
          end
          @scene.pbEndScene
          $scene = nil
          return
        else
          pbShowMenu
        end
      else
        pbPlayCloseMenuSE
        break
      end
    end
    @scene.pbEndScene if endscene
  end
end

class PokemonPokegearScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    commands = []
    cmdMap     = -1
    cmdPhone   = -1
    cmdJukebox = -1
    cmdBoxLink = -1
    commands[cmdMap = commands.length]     = ["map",_INTL("Map")]
    if $PokemonGlobal.phoneNumbers && $PokemonGlobal.phoneNumbers.length>0
      commands[cmdPhone = commands.length] = ["phone",_INTL("Phone")]
    end
    commands[cmdJukebox = commands.length] = ["jukebox",_INTL("Jukebox")]
    commands[cmdBoxLink = commands.length] = ["pc",_INTL("PC Box Link")] if $game_switches[115] == false
    @scene.pbStartScene(commands)
    loop do
      cmd = @scene.pbScene
      if cmd<0
        break
      elsif cmdMap>=0 && cmd==cmdMap
        pbShowMap(-1,false)
      elsif cmdPhone>=0 && cmd==cmdPhone
        pbFadeOutIn {
          PokemonPhoneScene.new.start
        }
      elsif cmdJukebox>=0 && cmd==cmdJukebox
        pbFadeOutIn {
          scene = PokemonJukebox_Scene.new
          screen = PokemonJukeboxScreen.new(scene)
          screen.pbStartScreen
        }
      elsif cmdBoxLink>=0 && cmd==cmdBoxLink
        pbPokeCenterPC
      end
    end
    @scene.pbEndScene
  end
end

class PokemonSummary_Scene
  def drawPage(page)
    if @pokemon.egg?
      drawPageOneEgg
      return
    end
    @sprites["itemicon"].item = @pokemon.item_id
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248,248,248)
    shadow = Color.new(104,104,104)
    # Set background image
    @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_#{page}")
    imagepos=[]
    # Show the Poké Ball containing the Pokémon
    ballimage = sprintf("Graphics/Pictures/Summary/icon_ball_%s", @pokemon.poke_ball)
    if !pbResolveBitmap(ballimage)
      ballimage = sprintf("Graphics/Pictures/Summary/icon_ball_%02d", pbGetBallType(@pokemon.poke_ball))
    end
    imagepos.push([ballimage,14,60])
    # Show status/fainted/Pokérus infected icon
    status = 0
    if @pokemon.fainted?
      status = GameData::Status::DATA.keys.length / 2
    elsif @pokemon.status != :NONE
      status = GameData::Status.get(@pokemon.status).id_number
    elsif @pokemon.pokerusStage == 1
      status = GameData::Status::DATA.keys.length / 2 + 1
    end
    status -= 1
    if status >= 0
      imagepos.push(["Graphics/Pictures/statuses",124,100,0,16*status,44,16])
    end
    # Show Pokérus cured icon
    if @pokemon.pokerusStage==2
      imagepos.push([sprintf("Graphics/Pictures/Summary/icon_pokerus"),176,100])
    end
    # Show shininess star
    if @pokemon.shiny?
      imagepos.push([sprintf("Graphics/Pictures/shiny"),2,134])
    end
    # Draw all images
    pbDrawImagePositions(overlay,imagepos)
    # Write various bits of text
    pagename = [_INTL("INFO"),
                _INTL("TRAINER MEMO"),
                _INTL("SKILLS"),
                _INTL("EVs/IVs"),
                _INTL("MOVES")][page-1]
    textpos = [
       [pagename,26,10,0,base,shadow],
       [@pokemon.name,46,56,0,base,shadow],
       [@pokemon.level.to_s,46,86,0,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Item"),66,312,0,base,shadow]
    ]
    # Write the held item's name
    if @pokemon.hasItem?
      textpos.push([@pokemon.item.name,16,346,0,Color.new(64,64,64),Color.new(176,176,176)])
    else
      textpos.push([_INTL("None"),16,346,0,Color.new(192,200,208),Color.new(208,216,224)])
    end
    # Write the gender symbol
    if @pokemon.male?
      textpos.push([_INTL("♂"),178,56,0,Color.new(24,112,216),Color.new(136,168,208)])
    elsif @pokemon.female?
      textpos.push([_INTL("♀"),178,56,0,Color.new(248,56,32),Color.new(224,152,144)])
    end
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
    # Draw the Pokémon's markings
    drawMarkings(overlay,84,292)
    # Draw page-specific information
    case page
    when 1 then drawPageOne
    when 2 then drawPageTwo
    when 3 then drawPageThree
    when 4 then drawPageFour
    when 5 then drawPageFive
    end
  end

  def drawPageFour
   overlay = @sprites["overlay"].bitmap
    base   = Color.new(248,248,248)
    shadow = Color.new(104,104,104)
    statshadows = {}
    GameData::Stat.each_main { |s| statshadows[s.id] = shadow }
    if !@pokemon.shadowPokemon? || @pokemon.heartStage > 3
      @pokemon.nature_for_stats.stat_changes.each do |change|
        statshadows[change[0]] = Color.new(136,96,72) if change[1] > 0
        statshadows[change[0]] = Color.new(64,120,152) if change[1] < 0
      end
    end
    evtable = Marshal.load(Marshal.dump(@pokemon.ev))
    ivtable = Marshal.load(Marshal.dump(@pokemon.iv))
    evHP = evtable[@pokemon.ev.keys[0]]
    ivHP = ivtable[@pokemon.iv.keys[0]]
    evAt = evtable[@pokemon.ev.keys[0]]
    ivAt = ivtable[@pokemon.iv.keys[0]]
    evDf = evtable[@pokemon.ev.keys[0]]
    ivDf = ivtable[@pokemon.iv.keys[0]]
    evSa = evtable[@pokemon.ev.keys[0]]
    ivSa = ivtable[@pokemon.iv.keys[0]]
    evSd = evtable[@pokemon.ev.keys[0]]
    ivSd = ivtable[@pokemon.iv.keys[0]]
    evSp = evtable[@pokemon.ev.keys[0]]
    ivSp = ivtable[@pokemon.iv.keys[0]]
    textpos = [
       [_INTL("HP"),292,70,2,base,statshadows[:HP]],
       [sprintf("%d/%d",evHP,ivHP),462,70,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Attack"),248,114,0,base,statshadows[:ATTACK]],
       [sprintf("%d/%d",evAt,ivAt),456,114,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Defense"),248,146,0,base,statshadows[:DEFENSE]],
       [sprintf("%d/%d",evDf,ivDf),456,146,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Sp. Atk"),248,178,0,base,statshadows[:SPECIAL_ATTACK]],
       [sprintf("%d/%d",evSa,ivSa),456,178,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Sp. Def"),248,210,0,base,statshadows[:SPECIAL_DEFENSE]],
       [sprintf("%d/%d",evSd,ivSd),456,210,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Speed"),248,242,0,base,statshadows[:SPEED]],
       [sprintf("%d/%d",evSd,ivSd),456,242,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Ability"),224,278,0,base,shadow]
    ]
    ability = @pokemon.ability
    if ability
      textpos.push([ability.name,362,278,0,Color.new(64,64,64),Color.new(176,176,176)])
      drawTextEx(overlay,224,320,282,2,ability.description,Color.new(64,64,64),Color.new(176,176,176))
    end
    pbDrawTextPositions(overlay,textpos)
  end

  def drawPageFive
    overlay = @sprites["overlay"].bitmap
    moveBase   = Color.new(64,64,64)
    moveShadow = Color.new(176,176,176)
    ppBase   = [moveBase,                # More than 1/2 of total PP
                Color.new(248,192,0),    # 1/2 of total PP or less
                Color.new(248,136,32),   # 1/4 of total PP or less
                Color.new(248,72,72)]    # Zero PP
    ppShadow = [moveShadow,             # More than 1/2 of total PP
                Color.new(144,104,0),   # 1/2 of total PP or less
                Color.new(144,72,24),   # 1/4 of total PP or less
                Color.new(136,48,48)]   # Zero PP
    @sprites["pokemon"].visible  = true
    @sprites["pokeicon"].visible = false
    @sprites["itemicon"].visible = true
    textpos  = []
    imagepos = []
    # Write move names, types and PP amounts for each known move
    yPos = 92
    for i in 0...Pokemon::MAX_MOVES
      move=@pokemon.moves[i]
      if move
        type_number = GameData::Type.get(move.type).id_number
        imagepos.push(["Graphics/Pictures/types", 248, yPos + 8, 0, type_number * 28, 64, 28])
        textpos.push([move.name,316,yPos,0,moveBase,moveShadow])
        if move.total_pp>0
          textpos.push([_INTL("PP"),342,yPos+32,0,moveBase,moveShadow])
          ppfraction = 0
          if move.pp==0;                  ppfraction = 3
          elsif move.pp*4<=move.total_pp; ppfraction = 2
          elsif move.pp*2<=move.total_pp; ppfraction = 1
          end
          textpos.push([sprintf("%d/%d",move.pp,move.total_pp),460,yPos+32,1,ppBase[ppfraction],ppShadow[ppfraction]])
        end
      else
        textpos.push(["-",316,yPos,0,moveBase,moveShadow])
        textpos.push(["--",442,yPos+32,1,moveBase,moveShadow])
      end
      yPos += 64
    end
    # Draw all text and images
    pbDrawTextPositions(overlay,textpos)
    pbDrawImagePositions(overlay,imagepos)
  end
  def drawPageFiveSelecting(move_to_learn)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248,248,248)
    shadow = Color.new(104,104,104)
    moveBase   = Color.new(64,64,64)
    moveShadow = Color.new(176,176,176)
    ppBase   = [moveBase,                # More than 1/2 of total PP
                Color.new(248,192,0),    # 1/2 of total PP or less
                Color.new(248,136,32),   # 1/4 of total PP or less
                Color.new(248,72,72)]    # Zero PP
    ppShadow = [moveShadow,             # More than 1/2 of total PP
                Color.new(144,104,0),   # 1/2 of total PP or less
                Color.new(144,72,24),   # 1/4 of total PP or less
                Color.new(136,48,48)]   # Zero PP
    # Set background image
    if move_to_learn
      @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_learnmove")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_movedetail")
    end
    # Write various bits of text
    textpos = [
       [_INTL("MOVES"),26,10,0,base,shadow],
       [_INTL("CATEGORY"),20,116,0,base,shadow],
       [_INTL("POWER"),20,148,0,base,shadow],
       [_INTL("ACCURACY"),20,180,0,base,shadow]
    ]
    imagepos = []
    # Write move names, types and PP amounts for each known move
    yPos = 92
    yPos -= 76 if move_to_learn
    limit = (move_to_learn) ? Pokemon::MAX_MOVES + 1 : Pokemon::MAX_MOVES
    for i in 0...limit
      move = @pokemon.moves[i]
      if i==Pokemon::MAX_MOVES
        move = move_to_learn
        yPos += 20
      end
      if move
        type_number = GameData::Type.get(move.type).id_number
        imagepos.push(["Graphics/Pictures/types", 248, yPos + 8, 0, type_number * 28, 64, 28])
        textpos.push([move.name,316,yPos,0,moveBase,moveShadow])
        if move.total_pp>0
          textpos.push([_INTL("PP"),342,yPos+32,0,moveBase,moveShadow])
          ppfraction = 0
          if move.pp==0;                  ppfraction = 3
          elsif move.pp*4<=move.total_pp; ppfraction = 2
          elsif move.pp*2<=move.total_pp; ppfraction = 1
          end
          textpos.push([sprintf("%d/%d",move.pp,move.total_pp),460,yPos+32,1,ppBase[ppfraction],ppShadow[ppfraction]])
        end
      else
        textpos.push(["-",316,yPos,0,moveBase,moveShadow])
        textpos.push(["--",442,yPos+32,1,moveBase,moveShadow])
      end
      yPos += 64
    end
    # Draw all text and images
    pbDrawTextPositions(overlay,textpos)
    pbDrawImagePositions(overlay,imagepos)
    # Draw Pokémon's type icon(s)
    type1_number = GameData::Type.get(@pokemon.type1).id_number
    type2_number = GameData::Type.get(@pokemon.type2).id_number
    type1rect = Rect.new(0, type1_number * 28, 64, 28)
    type2rect = Rect.new(0, type2_number * 28, 64, 28)
    if @pokemon.type1==@pokemon.type2
      overlay.blt(130,78,@typebitmap.bitmap,type1rect)
    else
      overlay.blt(96,78,@typebitmap.bitmap,type1rect)
      overlay.blt(166,78,@typebitmap.bitmap,type2rect)
    end
  end
  def drawSelectedMove(move_to_learn, selected_move)
    # Draw all of page four, except selected move's details
    drawPageFiveSelecting(move_to_learn)
    # Set various values
    overlay = @sprites["overlay"].bitmap
    base = Color.new(64, 64, 64)
    shadow = Color.new(176, 176, 176)
    @sprites["pokemon"].visible = false if @sprites["pokemon"]
    @sprites["pokeicon"].pokemon = @pokemon
    @sprites["pokeicon"].visible = true
    @sprites["itemicon"].visible = false if @sprites["itemicon"]
    textpos = []
    # Write power and accuracy values for selected move
    case selected_move.base_damage
    when 0 then textpos.push(["---", 216, 148, 1, base, shadow])   # Status move
    when 1 then textpos.push(["???", 216, 148, 1, base, shadow])   # Variable power move
    else        textpos.push([selected_move.base_damage.to_s, 216, 148, 1, base, shadow])
    end
    if selected_move.accuracy == 0
      textpos.push(["---", 216, 180, 1, base, shadow])
    else
      textpos.push(["#{selected_move.accuracy}%", 216 + overlay.text_size("%").width, 180, 1, base, shadow])
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw selected move's damage category icon
    imagepos = [["Graphics/Pictures/category", 166, 124, 0, selected_move.category * 28, 64, 28]]
    pbDrawImagePositions(overlay, imagepos)
    # Draw selected move's description
    drawTextEx(overlay, 4, 222, 230, 5, selected_move.description, base, shadow)
  end
  def pbScene
    GameData::Species.play_cry_from_pokemon(@pokemon)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      if Input.trigger?(Input::ACTION)
        pbSEStop
        GameData::Species.play_cry_from_pokemon(@pokemon)
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        if @page==5
          pbPlayDecisionSE
          pbMoveSelection
          dorefresh = true
        elsif !@inbattle
          pbPlayDecisionSE
          dorefresh = pbOptions
        end
      elsif Input.trigger?(Input::UP) && @partyindex>0
        oldindex = @partyindex
        pbGoToPrevious
        if @partyindex!=oldindex
          pbChangePokemon
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::DOWN) && @partyindex<@party.length-1
        oldindex = @partyindex
        pbGoToNext
        if @partyindex!=oldindex
          pbChangePokemon
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::LEFT) && !@pokemon.egg?
        oldpage = @page
        @page -= 1
        @page = 1 if @page<1
        @page = 5 if @page>5
        if @page!=oldpage   # Move to next page
          pbSEPlay("GUI summary change page")
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::RIGHT) && !@pokemon.egg?
        oldpage = @page
        @page += 1
        @page = 1 if @page<1
        @page = 5 if @page>5
        if @page!=oldpage   # Move to next page
          pbSEPlay("GUI summary change page")
          @ribbonOffset = 0
          dorefresh = true
        end
      end
      if dorefresh
        drawPage(@page)
      end
    end
    return @partyindex
  end
end
