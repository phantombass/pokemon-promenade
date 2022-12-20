#===================
# Move and Ability Effects
#===================

class Pokemon
  def getEggMovesList
    baby = GameData::Species.get(species).get_baby_species
    form = 0
    if baby == :RIOLU || baby == :LUCARIO || baby == :BUNEARY || baby == :LOPUNNY || baby == :NUMEL || baby == :CAMERUPT || baby == :ROCKRUFF || baby == :LYCANROC || baby == :YAMASK || baby == :COFAGRIGUS
      form = 2
    elsif baby == :CACNEA || baby == :CACTURNE || baby == :SANDYGAST || baby == :PALOSSAND || baby == :DEINO || baby == :ZWEILOUS || baby == :HYDREIGON || baby == :TRAPINCH || baby == :HORSEA || baby == :SEADRA || baby == :EXEGGUTOR || baby == :SEEL || baby == :DEWGONG || baby == :LUVDISC || baby == :QWILFISH
      form = 1
    else
      form = form
    end
    egg = GameData::Species.get_species_form(baby,form).egg_moves
    return egg
  end
  def has_egg_move?
    return false if egg? || shadowPokemon?
    getEggMovesList.each { |m| return true if !hasMove?(m[1]) }
    return false
  end
end

module Effectiveness

  module_function

  def ineffective_type?(attack_type, defend_type1, defend_type2 = nil, defend_type3 = nil)
    value = calculate(attack_type, defend_type1, defend_type2, defend_type3)
    return ineffective?(value)
  end

  def not_very_effective_type?(attack_type, defend_type1, defend_type2 = nil, defend_type3 = nil)
    value = calculate(attack_type, defend_type1, defend_type2, defend_type3)
    return not_very_effective?(value)
  end

  def resistant_type?(attack_type, defend_type1, defend_type2 = nil, defend_type3 = nil)
    value = calculate(attack_type, defend_type1, defend_type2, defend_type3)
    return resistant?(value)
  end

  def normal_type?(attack_type, defend_type1, defend_type2 = nil, defend_type3 = nil)
    value = calculate(attack_type, defend_type1, defend_type2, defend_type3)
    return normal?(value)
  end

  def super_effective_type?(attack_type, defend_type1, defend_type2 = nil, defend_type3 = nil)
    value = calculate(attack_type, defend_type1, defend_type2, defend_type3)
    return super_effective?(value)
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
    elsif pbSoundMove? && battle.field.weather == :Reverb &&
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
       (@battle.pbCheckGlobalAbility(:GAIAFORCE) && type == :GROUND) ||
       (@battle.pbCheckGlobalAbility(:FEVERPITCH) && type == :POISON)
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
    when :Poison
      multipliers[:base_damage_multiplier] *= 1.5 if type == :POISON && user.affectedByTerrain?
      multipliers[:base_damage_multiplier] /= 2 if type == :PSYCHIC && target.affectedByTerrain?
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
      if target.pbHasType?(:SOUND) && (physicalMove? || @function="122")
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
      elsif target.pbHasType?(:POISON) && (physicalMove? || @function="122")
        multipliers[:defense_multiplier] *= 1.5
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
    if user.status == :FROZEN && specialMove? && damageReducedByFreeze?
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
    return 0 if target.hasActiveAbility?(:INNERFOCUS) && !@battle.moldBreaker
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

module BattleHandlers
  StatLossImmunityAbilityNonIgnorableSandy = AbilityHandlerHash.new   # Unshaken
  def self.triggerStatLossImmunityAbilityNonIgnorableSandy(ability,battler,stat,battle,showMessages)
    ret = StatLossImmunityAbilityNonIgnorableSandy.trigger(ability,battler,stat,battle,showMessages)
    return (ret!=nil) ? ret : false
  end
end

class PokeBattle_Move_087 < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if @battle.pbWeather != :None
    return baseDmg
  end

  def pbBaseType(user)
    ret = :NORMAL
    case @battle.pbWeather
    when :Sun, :HarshSun
      ret = :FIRE if GameData::Type.exists?(:FIRE)
    when :Rain, :HeavyRain, :Storm
      ret = :WATER if GameData::Type.exists?(:WATER)
    when :Sandstorm
      ret = :ROCK if GameData::Type.exists?(:ROCK)
    when :Hail, :Sleet
      ret = :ICE if GameData::Type.exists?(:ICE)
    when :Starstorm
      ret = :COSMIC if GameData::Type.exists?(:COSMIC)
    when :Fog
      ret = :FAIRY if GameData::Type.exists?(:FAIRY)
    when :Humid
      ret = :BUG if GameData::Type.exists?(:BUG)
    when :Overcast
      ret = :GHOST if GameData::Type.exists?(:GHOST)
    when :Eclipse
      ret = :DARK if GameData::Type.exists?(:DARK)
    when :Windy
      ret = :FLYING if GameData::Type.exists?(:FLYING)
    when :HeatLight
      ret = :ELECTRIC if GameData::Type.exists?(:ELECTRIC)
    when :AcidRain
      ret = :POISON if GameData::Type.exists?(:POISON)
    when :StrongWinds
      ret = :DRAGON if GameData::Type.exists?(:DRAGON)
    when :Rainbow
      ret = :GRASS if GameData::Type.exists?(:GRASS)
    when :DustDevil
      ret = :GROUND if GameData::Type.exists?(:GROUND)
    when :DAshfall
      ret = :FIGHTING if GameData::Type.exists?(:FIGHTING)
    when :VolcanicAsh
      ret = :STEEL if GameData::Type.exists?(:STEEL)
    when :Borealis
      ret = :PSYCHIC if GameData::Type.exists?(:PSYCHIC)
    when :TimeWarp
      ret = :TIME if GameData::Type.exists?(:TIME)
    when :Reverb
      ret = :SOUND if GameData::Type.exists?(:SOUND)
    end
    return ret
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    t = pbBaseType(user)
    hitNum = 1 if t == :FIRE   # Type-specific anims
    hitNum = 2 if t == :WATER
    hitNum = 3 if t == :ROCK
    hitNum = 4 if t == :ICE
    super
  end
end

BattleHandlers::EORWeatherAbility.add(:ACCLIMATE,
  proc { |ability,weather,battler,battle|
    next if battler.fainted?
    oldWeather = battle.pbWeather
    newForm = battler.form
    newWeather = newForm
    if newForm >= 21
      if newForm >= 42
        newForm -= 42
      else
        newForm -= 21
      end
    end
    newWeather = newForm
    battle.eachOtherSideBattler(battler.index) do |b|
      type1 = b.type1
      type2 = b.type2
      case type1
      when :NORMAL
        case type2
        when :GHOST, :PSYCHIC, :TIME; newWeather = 7
        when :FAIRY; newWeather = 16
        when :FLYING, :SOUND; newWeather = 3
        when :BUG; newWeather = 1
        when :NORMAL,:FIGHTING,:POISON,:GROUND,:ROCK,:STEEL,:FIRE,:WATER,:GRASS,:ELECTRIC,:ICE,:DRAGON,:DARK,:COSMIC, type1; newWeather = 15
        end
      when :FIGHTING
        case type2
        when :POISON, :COSMIC; newWeather = 17
        when :STEEL; newWeather = 20
        when :FLYING, :FIRE; newWeather = 19
        when :NORMAL,:FIGHTING,:GROUND,:ROCK,:BUG,:GHOST,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,:ICE,:DRAGON,:DARK,:FAIRY,:TIME,:SOUND, type1; newWeather = 4
        end
      when :FLYING
        case type2
        when :GROUND, :DRAGON, :SOUND, :COSMIC, :GHOST; newWeather = 3
        when :FIRE, :ICE, :ROCK, :POISON, :BUG; newWeather = 12
        when :NORMAL,:FIGHTING,:STEEL,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,:DARK,:FAIRY,:TIME, type1; newWeather = 20
        end
      when :ROCK
        case type2
        when :ICE, :DARK; newWeather = 15
        when :FLYING, :BUG, :GRASS, :TIME, :FAIRY; newWeather = 16
        when :WATER, :GROUND, :SOUND; newWeather = 13
        when :FIRE; newWeather = 2
        when :COSMIC; newWeather = 19
        when :NORMAL, :FIGHTING, :POISON, :GHOST, :STEEL, :ELECTRIC, :DRAGON, :PSYCHIC, type1; newWeather = 14
        end
      when :GROUND
        case type2
        when :WATER, :ROCK, :ELECTRIC, type1; newWeather = 13
        when :DRAGON, :FLYING, :SOUND, :GRASS; newWeather = 3
        when :COSMIC; newWeather = 17
        when :TIME; newWeather = 5
        when :NORMAL,:FIGHTING,:POISON,:BUG,:GHOST,:STEEL,:FIRE,:PSYCHIC,:ICE,:DARK,:FAIRY; newWeather = 2
        end
      when :POISON
        case type2
        when :DARK, :STEEL, :ELECTRIC, :ROCK, :FIRE; newWeather = 14
        when :TIME, :PSYCHIC, :GHOST; newWeather = 7
        when :SOUND, :BUG, :ICE, :FLYING; newWeather = 12
        when :NORMAL,:FIGHTING,:POISON,:GROUND,:WATER,:GRASS,:DRAGON,:FAIRY,:COSMIC, type1; newWeather = 17
        end
      when :BUG
        case type2
        when :GROUND, :WATER, :FIGHTING; newWeather = 8
        when :GRASS, :STEEL, :COSMIC; newWeather = 1
        when :TIME; newWeather = 16
        when :NORMAL,:FLYING,:POISON,:ROCK,:GHOST,:FIRE,:ELECTRIC,:PSYCHIC,:ICE,:DRAGON,:DARK,:FAIRY,:SOUND, type1; newWeather = 12
        end
      when :GHOST
        case type2
        when :FIGHTING, :DARK; newWeather = 4
        when :FAIRY; newWeather = 16
        when :BUG; newWeather = 1
        when :NORMAL,:FLYING,:POISON,:GROUND,:ROCK,:STEEL,:FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,:ICE,:DRAGON,:COSMIC,:TIME,:SOUND, type1; newWeather = 7
        end
      when :STEEL
        case type2
        when :WATER; newWeather = 9
        when :TIME, :GROUND; newWeather = 20
        when :FIRE, :ROCK; newWeather = 14
        when :DARK, :NORMAL; newWeather = 15
        when :DRAGON, :SOUND; newWeather = 6
        when :FLYING,:POISON,:BUG,:GHOST,:STEEL,:GRASS,:ELECTRIC,:PSYCHIC,:ICE,:FAIRY,:COSMIC, type1; newWeather = 1
        end
      when :GRASS
        case type2
        when :STEEL, :COSMIC, :ICE; newWeather = 1
        when :TIME, :FAIRY, :SOUND; newWeather = 11
        when :DRAGON, :GROUND, :FLYING, :ELECTRIC; newWeather = 3
        when :DARK, :PSYCHIC; newWeather = 18
        when :ROCK; newWeather = 16
        when :NORMAL, :FIGHTING, :POISON, :BUG, :GHOST, :FIRE, :WATER, type1; newWeather = 8
        end
      when :FIRE
        case type2
        when :GRASS; newWeather = 8
        when :WATER; newWeather = 9
        when :COSMIC, :ROCK, :FIGHTING, :FLYING; newWeather = 19
        when :DRAGON, :ELECTRIC, :TIME; newWeather = 14
        when :SOUND; newWeather = 12
        when :NORMAL,:POISON,:GROUND,:BUG,:GHOST,:STEEL,:FIRE,:PSYCHIC,:ICE,:DARK,:FAIRY, type1; newWeather = 2
        end
      when :WATER
        case type2
        when :FIRE, :FLYING; newWeather = 9
        when :GHOST; newWeather = 7
        when :GROUND, :ROCK; newWeather = 13
        when :PSYCHIC, :TIME; newWeather = 20
        when :NORMAL,:FIGHTING,:POISON,:BUG,:STEEL,:GRASS,:ELECTRIC,:ICE,:DRAGON,:DARK,:FAIRY,:COSMIC,:SOUND, type1; newWeather = 6
        end
      when :ELECTRIC
        case type2
        when :FLYING, :GRASS; newWeather = 3
        when :TIME,:WATER; newWeather = 20
        when :BUG,:ICE; newWeather = 1
        when :NORMAL,:FIGHTING,:POISON,:GROUND,:ROCK,:GHOST,:STEEL,:FIRE,:PSYCHIC,:DRAGON,:DARK,:FAIRY,:COSMIC,:SOUND, type1; newWeather = 14
        end
      when :ICE
        case type2
        when :GHOST, :PSYCHIC, :TIME, :FAIRY, :ROCK, type1; newWeather = 16
        when :SOUND, :FIRE, :FLYING, :POISON; newWeather = 12
        when :GRASS, :BUG, :STEEL, :COSMIC; newWeather = 1
        when :NORMAL, :FIGHTING, :GROUND, :WATER, :DRAGON, :ELECTRIC, :DARK; newWeather = 15
        end
      when :PSYCHIC
        case type2
        when :DARK, :GRASS; newWeather = 18
        when :FLYING, :WATER; newWeather = 20
        when :FIGHTING; newWeather = 19
        when :SOUND; newWeather = 5
        when :ICE, :FAIRY; newWeather = 16
        when :NORMAL,:POISON,:GROUND,:ROCK,:BUG,:GHOST,:STEEL,:FIRE,:ELECTRIC,:DRAGON,:COSMIC,:TIME, type1; newWeather = 7
        end
      when :DRAGON
        case type2
        when :SOUND, :GROUND, :FLYING, :GRASS; newWeather = 3
        when :DARK, :FIGHTING, :TIME, type1; newWeather = 4
        when :FIRE; newWeather = 12
        when :PSYCHIC; newWeather = 7
        when :NORMAL,:POISON,:ROCK,:BUG,:GHOST,:STEEL,:WATER,:ELECTRIC,:ICE,:DRAGON,:FAIRY,:COSMIC; newWeather = 6
        end
      when :DARK
        case type2
        when :NORMAL,:FIGHTING,:FLYING,:GROUND,:BUG,:GHOST,:WATER,:ELECTRIC,:DRAGON,:FAIRY,:TIME,:SOUND,type1; newWeather = 4
        when :POISON,:FIRE; newWeather = 14
        when :GRASS,:PSYCHIC,:COSMIC; newWeather = 18
        when :ROCK,:STEEL,:ICE; newWeather = 15
        end
      when :FAIRY
        case type2
        when :FIRE; newWeather = 12
        when :COSMIC; newWeather = 1
        when :GRASS, :SOUND, :TIME; newWeather = 11
        when :ROCK, :ICE; newWeather = 16
        when :NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,:BUG,:STEEL,:WATER,:GRASS,:ELECTRIC,:DRAGON,:DARK, type1; newWeather = 6
        end
      when :COSMIC
        case type2
        when :GROUND, :SOUND; newWeather = 3
        when :GHOST, :TIME; newWeather = 7
        when :POISON, :FIGHTING; newWeather = 17
        when :DRAGON then newWeather = 6
        when :ICE, :GRASS, :BUG, :STEEL, :FAIRY; newWeather = 1
        when :NORMAL,:FLYING,:ROCK,:FIRE,:WATER,:ELECTRIC,:PSYCHIC, type1; newWeather = 19
        end
      when :TIME
        case type2
        when :NORMAL, :DARK, :SOUND, :GRASS, :FAIRY; newWeather = 11
        when :GHOST, :ROCK, :ICE, :COSMIC; newWeather = 7
        when :FIGHTING,:FLYING,:POISON,:GROUND,:BUG,:STEEL,:FIRE,:WATER,:ELECTRIC,:PSYCHIC,:DRAGON, type1; newWeather = 20
        end
      when :SOUND
        case type2
        when :GROUND, :FLYING, :GRASS, :DRAGON, :COSMIC; newWeather = 3
        when :POISON, :ROCK, :STEEL; newWeather = 14
        when :GHOST; newWeather = 7
        when :TIME; newWeather = 5
        when :WATER; newWeather = 6
        when :FIGHTING; newWeather = 11
        when :NORMAL,:BUG,:GHOST,:FIRE,:ELECTRIC,:PSYCHIC,:ICE,:DRAGON,:DARK,:FAIRY, type1; newWeather = 12
        end
      end
    end
    case newWeather
    when 1 then weatherChange = :Sun
    when 2 then weatherChange = :Rain
    when 3 then weatherChange = :Sleet
    when 4 then weatherChange = :Fog
    when 5 then weatherChange = :Overcast
    when 6 then weatherChange = :Starstorm
    when 7 then weatherChange = :Eclipse
    when 8 then weatherChange = :Windy
    when 9 then weatherChange = :HeatLight
    when 10 then weatherChange = :StrongWinds
    when 11 then weatherChange = :AcidRain
    when 12 then weatherChange = :Sandstorm
    when 13 then weatherChange = :Rainbow
    when 14 then weatherChange = :DustDevil
    when 15 then weatherChange = :DAshfall
    when 16 then weatherChange = :VolcanicAsh
    when 17 then weatherChange = :Borealis
    when 18 then weatherChange = :Humid
    when 19 then weatherChange = :TimeWarp
    when 20 then weatherChange = :Reverb
    end
  if oldWeather==weatherChange
    weatherChange = battle.pbWeather
  else
    battle.pbShowAbilitySplash(battler)
    battle.field.weather = weatherChange
    battle.field.weatherDuration = 5
    case weatherChange
    when :Starstorm then   battle.pbDisplay(_INTL("Stars fill the sky."))
    when :Thunder then     battle.pbDisplay(_INTL("Lightning flashes in th sky."))
    when :Humid then       battle.pbDisplay(_INTL("The air is humid."))
    when :Overcast then    battle.pbDisplay(_INTL("The sky is overcast."))
    when :Eclipse then     battle.pbDisplay(_INTL("The sky is dark."))
    when :Fog then         battle.pbDisplay(_INTL("The fog is deep."))
    when :AcidRain then    battle.pbDisplay(_INTL("Acid rain is falling."))
    when :VolcanicAsh then battle.pbDisplay(_INTL("Volcanic Ash sprinkles down."))
    when :Rainbow then     battle.pbDisplay(_INTL("A rainbow crosses the sky."))
    when :Borealis then    battle.pbDisplay(_INTL("The sky is ablaze with color."))
    when :TimeWarp then    battle.pbDisplay(_INTL("Time has stopped."))
    when :Reverb then      battle.pbDisplay(_INTL("A dull echo hums."))
    when :DClear then      battle.pbDisplay(_INTL("The sky is distorted."))
    when :DRain then       battle.pbDisplay(_INTL("Rain is falling upward."))
    when :DWind then       battle.pbDisplay(_INTL("The wind is haunting."))
    when :DAshfall then    battle.pbDisplay(_INTL("Ash floats in midair."))
    when :Sleet then       battle.pbDisplay(_INTL("Sleet began to fall."))
    when :Windy then       battle.pbDisplay(_INTL("There is a slight breeze."))
    when :HeatLight then   battle.pbDisplay(_INTL("Static fills the air."))
    when :DustDevil then   battle.pbDisplay(_INTL("A dust devil approaches."))
    when :Sun then         battle.pbDisplay(_INTL("The sunlight is strong."))
    when :Rain then        battle.pbDisplay(_INTL("It is raining."))
    when :Sandstorm then   battle.pbDisplay(_INTL("A sandstorm is raging."))
    when :Hail then        battle.pbDisplay(_INTL("Hail is falling."))
    when :HarshSun then    battle.pbDisplay(_INTL("The sunlight is extremely harsh."))
    when :HeavyRain then   battle.pbDisplay(_INTL("It is raining heavily."))
    when :StrongWinds then battle.pbDisplay(_INTL("The wind is strong."))
    when :ShadowSky then   battle.pbDisplay(_INTL("The sky is shadowy."))
    end
    newForm = newWeather
    if battler.isSpecies?(:ALTEMPER)
      case newForm
      when 4 then                       battler.effects[PBEffects::Type3] = :FAIRY
      when 0 then                       battler.effects[PBEffects::Type3] = :NORMAL
      when 5 then                       battler.effects[PBEffects::Type3] = :GHOST
      when 7 then                       battler.effects[PBEffects::Type3] = :DARK
      when 8 then                       battler.effects[PBEffects::Type3] = :FLYING
      when 9 then                       battler.effects[PBEffects::Type3] = :ELECTRIC
      when 10 then                      battler.effects[PBEffects::Type3] = :DRAGON
      when 11 then                      battler.effects[PBEffects::Type3] = :POISON
      when 12 then                      battler.effects[PBEffects::Type3] = :ROCK
      when 13 then                      battler.effects[PBEffects::Type3] = :GRASS
      when 14 then                      battler.effects[PBEffects::Type3] = :GROUND
      when 15 then                      battler.effects[PBEffects::Type3] = :FIGHTING
      when 16 then                      battler.effects[PBEffects::Type3] = :STEEL
      when 17 then                      battler.effects[PBEffects::Type3] = :PSYCHIC
      when 18 then                      battler.effects[PBEffects::Type3] = :BUG
      when 20 then                      battler.effects[PBEffects::Type3] = :SOUND
      when 1 then                       battler.effects[PBEffects::Type3] = :FIRE
      when 2 then                       battler.effects[PBEffects::Type3] = :WATER
      when 3 then                       battler.effects[PBEffects::Type3] = :ICE
      end
    elsif battler.isSpecies?(:FORMETEOS)
      case newForm
      when 4 then                       battler.type1 = :FAIRY
      when 0 then                       battler.type1 = :NORMAL
      when 5 then                       battler.type1 = :GHOST
      when 7 then                       battler.type1 = :DARK
      when 8 then                       battler.type1 = :FLYING
      when 9 then                       battler.type1 = :ELECTRIC
      when 10 then                      battler.type1 = :DRAGON
      when 11 then                      battler.type1 = :POISON
      when 12 then                      battler.type1 = :ROCK
      when 13 then                      battler.type1 = :GRASS
      when 14 then                      battler.type1 = :GROUND
      when 15 then                      battler.type1 = :FIGHTING
      when 16 then                      battler.type1 = :STEEL
      when 17 then                      battler.type1 = :PSYCHIC
      when 18 then                      battler.type1 = :BUG
      when 20 then                      battler.type1 = :SOUND
      when 1 then                       battler.type1 = :FIRE
      when 2 then                       battler.type1 = :WATER
      when 3 then                       battler.type1 = :ICE
      end
    end
  end
    if battler.form >= 21 && battler.isSpecies?(:ALTEMPER)
      if battler.form >= 42 && battler.isSpecies?(:ALTEMPER)
        newForm += 42
      else
        newForm += 21
      end
    end
    if battler.isSpecies?(:FORMETEOS)
      battler.form = newForm
    end
    if battler.form != newForm && battler.form <= 41 && !battler.isSpecies?(:FORMETEOS)
      battler.pbChangeForm(newForm,_INTL("{1} transformed!",battler.pbThis))
    end
    oldWeather = weatherChange
    battle.pbHideAbilitySplash(battler)
    battle.eachBattler { |b| b.pbCheckFormOnWeatherChange }
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
    next if battle.positions[battler.index].effects[PBEffects::Wish] == 1
    battle.positions[battler.index].effects[PBEffects::Wish] -= 1
    $aspirantBattler = battler.pbThis
    next if battle.positions[battler.index].effects[PBEffects::Wish]>0
    if battle.positions[battler.index].effects[PBEffects::Wish]<0
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.positions[battler.index].effects[PBEffects::WishAmount] = (battler.totalhp/2)
        battle.pbDisplay(_INTL("{1} made a wish!",$aspirantBattler))
      else
        battle.pbDisplay(_INTL("{1} made a wish with {2}",$aspirantBattler,battler.abilityName))
      end
      battle.positions[battler.index].effects[PBEffects::Wish] = 2
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

BattleHandlers::EORWeatherAbility.add(:ACIDDRAIN,
  proc { |ability,weather,battler,battle|
    next unless weather==:AcidRain
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

BattleHandlers::EORWeatherAbility.copy(:POISONHEAL,:ACIDDRAIN)

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
    battle.pbDisplay(_INTL("{1} is shrouded in the Duat!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SHADOWGUARD,
  proc { |ability,battler,battle|
    battler.effects[PBEffects::Type3] = :DARK
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is shrouded in the shadows!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:EQUINOX,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Starstorm, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:URBANCLOUD,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:AcidRain, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FIGHTERSWRATH,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:DAshfall, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MUGGYAIR,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Humid, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ELECTROSTATIC,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:HeatLight, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FLOWERGIFT,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Rainbow, battler, battle)
    #battler.pbChangeForm(1,_INTL("{1} transformed!",battler.name))
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:RAGINGSEA,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Storm, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DESERTSTORM,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:DustDevil, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ASHCOVER,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:VolcanicAsh, battler, battle)
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

BattleHandlers::AbilityOnSwitchIn.add(:CLOUDCOVER,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Overcast, battler, battle)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:WINDRAGE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if (user.battle.pbWeather == :Windy || user.battle.pbWeather == :StrongWinds) &&
       [:FLYING, :DRAGON].include?(type)
      mults[:base_damage_multiplier] *= 1.3
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SOOTSURGE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if (user.battle.pbWeather == :VolcanicAsh || user.battle.pbWeather == :DAshfall) &&
       [:STEEL, :FIGHTING].include?(type)
      mults[:base_damage_multiplier] *= 1.3
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:TOXICSURGE,
  proc { |ability,battler,battle|
    next if battle.field.terrain == :Poison
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Poison)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
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

BattleHandlers::DamageCalcUserAbility.add(:FLOWERGIFT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if move.specialMove? && [:Sun, :HarshSun,:Rainbow].include?(user.battle.pbWeather)
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAllyAbility.add(:FLOWERGIFT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if move.specialMove? && [:Sun, :HarshSun,:Rainbow].include?(user.battle.pbWeather)
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FLOWERGIFT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if [:Sun, :HarshSun,:Rainbow].include?(user.battle.pbWeather)
      mults[:defense_multiplier] *= 1.5
    end
  }
)

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

BattleHandlers::SpeedCalcAbility.add(:ASHRUSH,
  proc { |ability,battler,mult|
    next mult * 2 if [:VolcanicAsh, :DAshfall].include?(battler.battle.pbWeather)
  }
)

BattleHandlers::SpeedCalcAbility.add(:TOXICRUSH,
  proc { |ability,battler,mult|
    next mult * 2 if [:AcidRain].include?(battler.battle.pbWeather)
  }
)

BattleHandlers::StatusImmunityAbility.copy(:WATERVEIL,:FEVERPITCH)
BattleHandlers::StatusCureAbility.copy(:WATERVEIL,:FEVERPITCH)

BattleHandlers::DamageCalcUserAbility.add(:SUBWOOFER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.index != target.index && move && move.soundMove? && (baseDmg * mults[:base_damage_multiplier] <= 70)
      mults[:base_damage_multiplier]*1.5
    end
  }
)

BattleHandlers::StatusImmunityAbility.add(:FAIRYBUBBLE,
  proc { |ability,battler,status|
    next true if status =! :NONE
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FAIRYBUBBLE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 2 if type == :FAIRY
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FEVERPITCH,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if type == :PSYCHIC
      mults[:final_damage_multiplier] *= 0.5
    end
  }
)

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
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:DARK,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:CORRUPTION,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:FAIRY,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:STEAMENGINE,
  proc { |ability,user,target,move,type,battle|
    next (pbBattleMoveImmunityStatAbility(user,target,move,type,:WATER,:SPEED,6,battle) || pbBattleMoveImmunityStatAbility(user,target,move,type,:FIRE,:SPEED,6,battle))
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:DIMENSIONBLOCK,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:COSMIC,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:MENTALBLOCK,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:PSYCHIC,battle)
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

class PokeBattle_Battler
  def immune_by_ability?(type,ability)
    if type == :COSMIC && ability == :DIMENSIONBLOCK
      return true
    end
    if type == :DARK && ability == :UNTAINTED
      return true
    end
    if type == :FAIRY && ability == :CORRUPTION
      return true
    end
    if type == :FIRE && ability == :FLASHFIRE
      return true
    end
    if type == :GRASS && ability == :SAPSIPPER
      return true
    end
    if type == :WATER && [:STORMDRAIN,:WATERABSORB,:DRYSKIN].include?(ability)
      return true
    end
    if type == :GROUND && ability == :LEVITATE
      return true
    end
    return false
  end
  def pbCanLowerStatStage?(stat,user=nil,move=nil,showFailMsg=false,ignoreContrary=false)
    return false if fainted?
    return false if hasActiveAbility?(:UNSHAKEN)
    return false if hasActiveItem?(:UNSHAKENORB)
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbCanRaiseStatStage?(stat,user,move,showFailMsg,true)
    end
    if !user || user.index!=@index   # Not self-inflicted
      if @effects[PBEffects::Substitute]>0 && !(move && move.ignoresSubstitute?(user))
        @battle.pbDisplay(_INTL("{1} is protected by its substitute!",pbThis)) if showFailMsg
        return false
      end
      if pbOwnSide.effects[PBEffects::Mist]>0 &&
         !(user && user.hasActiveAbility?(:INFILTRATOR))
        @battle.pbDisplay(_INTL("{1} is protected by Mist!",pbThis)) if showFailMsg
        return false
      end
      if abilityActive?
        return false if BattleHandlers.triggerStatLossImmunityAbility(
           self.ability,self,stat,@battle,showFailMsg) if !@battle.moldBreaker
        return false if BattleHandlers.triggerStatLossImmunityAbilityNonIgnorable(
           self.ability,self,stat,@battle,showFailMsg)
      end
      if !@battle.moldBreaker
        eachAlly do |b|
          next if !b.abilityActive?
          return false if BattleHandlers.triggerStatLossImmunityAllyAbility(
             b.ability,b,self,stat,@battle,showFailMsg)
        end
      end
    end
    # Check the stat stage
    if statStageAtMin?(stat)
      @battle.pbDisplay(_INTL("{1}'s {2} won't go any lower!",
         pbThis, GameData::Stat.get(stat).name)) if showFailMsg
      return false
    end
    return true
  end
  def hasUtilityUmbrella?
    return hasActiveItem?(:UTILITYUMBRELLA)
  end
  def pbInitEffects(batonPass)
    if batonPass
      # These effects are passed on if Baton Pass is used, but they need to be
      # reapplied
      @effects[PBEffects::LaserFocus] = (@effects[PBEffects::LaserFocus]>0) ? 2 : 0
      @effects[PBEffects::LockOn]     = (@effects[PBEffects::LockOn]>0) ? 2 : 0
      if @effects[PBEffects::PowerTrick]
        @attack,@defense = @defense,@attack
      end
      # These effects are passed on if Baton Pass is used, but they need to be
      # cancelled in certain circumstances anyway
      @effects[PBEffects::Telekinesis] = 0 if isSpecies?(:GENGAR) && mega?
      @effects[PBEffects::GastroAcid]  = false if unstoppableAbility?
    else
      # These effects are passed on if Baton Pass is used
      @stages[:ATTACK]          = 0
      @stages[:DEFENSE]         = 0
      @stages[:SPEED]           = 0
      @stages[:SPECIAL_ATTACK]  = 0
      @stages[:SPECIAL_DEFENSE] = 0
      @stages[:ACCURACY]        = 0
      @stages[:EVASION]         = 0
      @effects[PBEffects::AquaRing]          = false
      @effects[PBEffects::Confusion]         = 0
      @effects[PBEffects::Curse]             = false
      @effects[PBEffects::Embargo]           = 0
      @effects[PBEffects::FocusEnergy]       = 0
      @effects[PBEffects::GastroAcid]        = false
      @effects[PBEffects::HealBlock]         = 0
      @effects[PBEffects::Ingrain]           = false
      @effects[PBEffects::LaserFocus]        = 0
      @effects[PBEffects::LeechSeed]         = -1
      @effects[PBEffects::LockOn]            = 0
      @effects[PBEffects::LockOnPos]         = -1
      @effects[PBEffects::MagnetRise]        = 0
      @effects[PBEffects::PerishSong]        = 0
      @effects[PBEffects::PerishSongUser]    = -1
      @effects[PBEffects::PowerTrick]        = false
      @effects[PBEffects::Substitute]        = 0
      @effects[PBEffects::StarSap]         = -1
      @effects[PBEffects::Telekinesis]       = 0
    end
    @fainted               = (@hp==0)
    @initialHP             = 0
    @lastAttacker          = []
    @lastFoeAttacker       = []
    @lastHPLost            = 0
    @lastHPLostFromFoe     = 0
    @tookDamage            = false
    @tookPhysicalHit       = false
    @lastMoveUsed          = nil
    @lastMoveUsedType      = nil
    @lastRegularMoveUsed   = nil
    @lastRegularMoveTarget = -1
    @lastRoundMoved        = -1
    @lastMoveFailed        = false
    @lastRoundMoveFailed   = false
    @movesUsed             = []
    @turnCount             = 0
    @effects[PBEffects::Attract]             = -1
    @battle.eachBattler do |b|   # Other battlers no longer attracted to self
      b.effects[PBEffects::Attract] = -1 if b.effects[PBEffects::Attract]==@index
    end
    @effects[PBEffects::BanefulBunker]       = false
    @effects[PBEffects::BeakBlast]           = false
    @effects[PBEffects::Bide]                = 0
    @effects[PBEffects::BideDamage]          = 0
    @effects[PBEffects::BideTarget]          = -1
    @effects[PBEffects::BurnUp]              = false
    @effects[PBEffects::Charge]              = 0
    @effects[PBEffects::ChoiceBand]          = nil
    @effects[PBEffects::Counter]             = -1
    @effects[PBEffects::CounterTarget]       = -1
    @effects[PBEffects::Dancer]              = false
    @effects[PBEffects::DefenseCurl]         = false
    @effects[PBEffects::DestinyBond]         = false
    @effects[PBEffects::DestinyBondPrevious] = false
    @effects[PBEffects::DestinyBondTarget]   = -1
    @effects[PBEffects::Disable]             = 0
    @effects[PBEffects::DisableMove]         = nil
    @effects[PBEffects::Electrify]           = false
    @effects[PBEffects::Encore]              = 0
    @effects[PBEffects::EncoreMove]          = nil
    @effects[PBEffects::Endure]              = false
    @effects[PBEffects::FirstPledge]         = 0
    @effects[PBEffects::FlashFire]           = false
    @effects[PBEffects::Flinch]              = false
    @effects[PBEffects::FocusPunch]          = false
    @effects[PBEffects::FollowMe]            = 0
    @effects[PBEffects::Foresight]           = false
    @effects[PBEffects::FuryCutter]          = 0
    @effects[PBEffects::GemConsumed]         = nil
    @effects[PBEffects::Grudge]              = false
    @effects[PBEffects::HelpingHand]         = false
    @effects[PBEffects::HyperBeam]           = 0
    @effects[PBEffects::Illusion]            = nil
    if hasActiveAbility?(:ILLUSION)
      idxLastParty = @battle.pbLastInTeam(@index)
      if idxLastParty >= 0 && idxLastParty != @pokemonIndex
        @effects[PBEffects::Illusion]        = @battle.pbParty(@index)[idxLastParty]
      end
    end
    @effects[PBEffects::Imprison]            = false
    @effects[PBEffects::Instruct]            = false
    @effects[PBEffects::Instructed]          = false
    @effects[PBEffects::KingsShield]         = false
    @battle.eachBattler do |b|   # Other battlers lose their lock-on against self
      next if b.effects[PBEffects::LockOn]==0
      next if b.effects[PBEffects::LockOnPos]!=@index
      b.effects[PBEffects::LockOn]    = 0
      b.effects[PBEffects::LockOnPos] = -1
    end
    @effects[PBEffects::MagicBounce]         = false
    @effects[PBEffects::MagicCoat]           = false
    @effects[PBEffects::MeanLook]            = -1
    @battle.eachBattler do |b|   # Other battlers no longer blocked by self
      b.effects[PBEffects::MeanLook] = -1 if b.effects[PBEffects::MeanLook]==@index
    end
    @effects[PBEffects::MeFirst]             = false
    @effects[PBEffects::Metronome]           = 0
    @effects[PBEffects::MicleBerry]          = false
    @effects[PBEffects::Minimize]            = false
    @effects[PBEffects::MiracleEye]          = false
    @effects[PBEffects::MirrorCoat]          = -1
    @effects[PBEffects::MirrorCoatTarget]    = -1
    @effects[PBEffects::MoveNext]            = false
    @effects[PBEffects::MudSport]            = false
    @effects[PBEffects::Nightmare]           = false
    @effects[PBEffects::Outrage]             = 0
    @effects[PBEffects::ParentalBond]        = 0
    @effects[PBEffects::EchoChamber]         = 0
    @effects[PBEffects::PickupItem]          = nil
    @effects[PBEffects::PickupUse]           = 0
    @effects[PBEffects::Pinch]               = false
    @effects[PBEffects::Powder]              = false
    @effects[PBEffects::Prankster]           = false
    @effects[PBEffects::PriorityAbility]     = false
    @effects[PBEffects::PriorityItem]        = false
    @effects[PBEffects::Protect]             = false
    @effects[PBEffects::ProtectRate]         = 1
    @effects[PBEffects::Pursuit]             = false
    @effects[PBEffects::Quash]               = 0
    @effects[PBEffects::Rage]                = false
    @effects[PBEffects::RagePowder]          = false
    @effects[PBEffects::Rollout]             = 0
    @effects[PBEffects::Roost]               = false
    @effects[PBEffects::SkyDrop]             = -1
    @battle.eachBattler do |b|   # Other battlers no longer Sky Dropped by self
      b.effects[PBEffects::SkyDrop] = -1 if b.effects[PBEffects::SkyDrop]==@index
    end
    @effects[PBEffects::SlowStart]           = 0
    @effects[PBEffects::SmackDown]           = false
    @effects[PBEffects::Snatch]              = 0
    @effects[PBEffects::SpikyShield]         = false
    @effects[PBEffects::Spotlight]           = 0
    @effects[PBEffects::Stockpile]           = 0
    @effects[PBEffects::StockpileDef]        = 0
    @effects[PBEffects::StockpileSpDef]      = 0
    @effects[PBEffects::Taunt]               = 0
    @effects[PBEffects::ThroatChop]          = 0
    @effects[PBEffects::Torment]             = false
    @effects[PBEffects::Toxic]               = 0
    @effects[PBEffects::Transform]           = false
    @effects[PBEffects::TransformSpecies]    = 0
    @effects[PBEffects::Trapping]            = 0
    @effects[PBEffects::TrappingMove]        = nil
    @effects[PBEffects::TrappingUser]        = -1
    @battle.eachBattler do |b|   # Other battlers no longer trapped by self
      next if b.effects[PBEffects::TrappingUser]!=@index
      b.effects[PBEffects::Trapping]     = 0
      b.effects[PBEffects::TrappingUser] = -1
    end
    @effects[PBEffects::Truant]              = false
    @effects[PBEffects::TwoTurnAttack]       = nil
    @effects[PBEffects::Type3]               = nil
    @effects[PBEffects::Unburden]            = false
    @effects[PBEffects::Uproar]              = 0
    @effects[PBEffects::WaterSport]          = false
    @effects[PBEffects::WeightChange]        = 0
    @effects[PBEffects::Yawn]                = 0
  end
  def pbProcessMoveHit(move,user,targets,hitNum,skipAccuracyCheck)
    return false if user.fainted?
    # For two-turn attacks being used in a single turn
    move.pbInitialEffect(user,targets,hitNum)
    numTargets = 0   # Number of targets that are affected by this hit
    targets.each { |b| b.damageState.resetPerHit }
    # Count a hit for Parental Bond (if it applies)
    user.effects[PBEffects::ParentalBond] -= 1 if user.effects[PBEffects::ParentalBond]>0
    user.effects[PBEffects::EchoChamber] -= 1 if user.effects[PBEffects::EchoChamber]>0
    # Accuracy check (accuracy/evasion calc)
    if hitNum==0 || move.successCheckPerHit?
      targets.each do |b|
        next if b.damageState.unaffected
        if pbSuccessCheckPerHit(move,user,b,skipAccuracyCheck)
          numTargets += 1
        else
          b.damageState.missed     = true
          b.damageState.unaffected = true
        end
      end
      # If failed against all targets
      if targets.length>0 && numTargets==0 && !move.worksWithNoTargets?
        targets.each do |b|
          next if !b.damageState.missed || b.damageState.magicCoat
          pbMissMessage(move,user,b)
        end
        move.pbCrashDamage(user)
        user.pbItemHPHealCheck
        pbCancelMoves
        return false
      end
    end
    # If we get here, this hit will happen and do something
    #---------------------------------------------------------------------------
    # Calculate damage to deal
    if move.pbDamagingMove?
      targets.each do |b|
        next if b.damageState.unaffected
        # Check whether Substitute/Disguise will absorb the damage
        move.pbCheckDamageAbsorption(user,b)
        # Calculate the damage against b
        # pbCalcDamage shows the "eat berry" animation for SE-weakening
        # berries, although the message about it comes after the additional
        # effect below
        move.pbCalcDamage(user,b,targets.length)   # Stored in damageState.calcDamage
        # Lessen damage dealt because of False Swipe/Endure/etc.
        move.pbReduceDamage(user,b)   # Stored in damageState.hpLost
      end
    end
    # Show move animation (for this hit)
    move.pbShowAnimation(move.id,user,targets,hitNum)
    # Type-boosting Gem consume animation/message
    if user.effects[PBEffects::GemConsumed] && hitNum==0
      # NOTE: The consume animation and message for Gems are shown now, but the
      #       actual removal of the item happens in def pbEffectsAfterMove.
      @battle.pbCommonAnimation("UseItem",user)
      @battle.pbDisplay(_INTL("The {1} strengthened {2}'s power!",
         GameData::Item.get(user.effects[PBEffects::GemConsumed]).name,move.name))
    end
    # Messages about missed target(s) (relevant for multi-target moves only)
    targets.each do |b|
      next if !b.damageState.missed
      pbMissMessage(move,user,b)
    end
    # Deal the damage (to all allies first simultaneously, then all foes
    # simultaneously)
    if move.pbDamagingMove?
      # This just changes the HP amounts and does nothing else
      targets.each do |b|
        next if b.damageState.unaffected
        move.pbInflictHPDamage(b)
      end
      # Animate the hit flashing and HP bar changes
      move.pbAnimateHitAndHPLost(user,targets)
    end
    # Self-Destruct/Explosion's damaging and fainting of user
    move.pbSelfKO(user) if hitNum==0
    user.pbFaint if user.fainted?
    if move.pbDamagingMove?
      targets.each do |b|
        next if b.damageState.unaffected
        # NOTE: This method is also used for the OKHO special message.
        move.pbHitEffectivenessMessages(user,b,targets.length)
        # Record data about the hit for various effects' purposes
        move.pbRecordDamageLost(user,b)
      end
      # Close Combat/Superpower's stat-lowering, Flame Burst's splash damage,
      # and Incinerate's berry destruction
      targets.each do |b|
        next if b.damageState.unaffected
        move.pbEffectWhenDealingDamage(user,b)
      end
      # Ability/item effects such as Static/Rocky Helmet, and Grudge, etc.
      targets.each do |b|
        next if b.damageState.unaffected
        pbEffectsOnMakingHit(move,user,b)
      end
      # Disguise/Endure/Sturdy/Focus Sash/Focus Band messages
      targets.each do |b|
        next if b.damageState.unaffected
        move.pbEndureKOMessage(b)
      end
      # HP-healing held items (checks all battlers rather than just targets
      # because Flame Burst's splash damage affects non-targets)
      @battle.pbPriority(true).each { |b| b.pbItemHPHealCheck }
      # Animate battlers fainting (checks all battlers rather than just targets
      # because Flame Burst's splash damage affects non-targets)
      @battle.pbPriority(true).each { |b| b.pbFaint if b && b.fainted? }
    end
    @battle.pbJudgeCheckpoint(user,move)
    # Main effect (recoil/drain, etc.)
    targets.each do |b|
      next if b.damageState.unaffected
      move.pbEffectAgainstTarget(user,b)
    end
    move.pbEffectGeneral(user)
    targets.each { |b| b.pbFaint if b && b.fainted? }
    user.pbFaint if user.fainted?
    # Additional effect
    if !user.hasActiveAbility?(:SHEERFORCE)
      targets.each do |b|
        next if b.damageState.calcDamage==0
        chance = move.pbAdditionalEffectChance(user,b)
        next if chance<=0
        if @battle.pbRandom(100)<chance
          move.pbAdditionalEffect(user,b)
        end
      end
    end
    # Make the target flinch (because of an item/ability)
    targets.each do |b|
      next if b.fainted?
      next if b.damageState.calcDamage==0 || b.damageState.substitute
      chance = move.pbFlinchChance(user,b)
      next if chance<=0
      if @battle.pbRandom(100)<chance
        PBDebug.log("[Item/ability triggered] #{user.pbThis}'s King's Rock/Razor Fang or Stench")
        b.pbFlinch(user)
      end
    end
    # Message for and consuming of type-weakening berries
    # NOTE: The "consume held item" animation for type-weakening berries occurs
    #       during pbCalcDamage above (before the move's animation), but the
    #       message about it only shows here.
    targets.each do |b|
      next if b.damageState.unaffected
      next if !b.damageState.berryWeakened
      @battle.pbDisplay(_INTL("The {1} weakened the damage to {2}!",b.itemName,b.pbThis(true)))
      b.pbConsumeItem
    end
    targets.each { |b| b.pbFaint if b && b.fainted? }
    user.pbFaint if user.fainted?
    return true
  end
  def pbFlinch(_user=nil)
    if hasActiveAbility?(:INNERFOCUS) && !@battle.moldBreaker
      @effects[PBEffects::Flinch] = false
    else
      @effects[PBEffects::Flinch] = true
    end
  end
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
        when :FROZEN    then msg = _INTL("{1} is already frostbitten!", pbThis)
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
    if newStatus == :FROZEN && [:Sun, :HarshSun].include?(@battle.pbWeather) && !hasUtilityUmbrella?
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
          when :FROZEN    then msg = _INTL("{1} cannot be frostitten!", pbThis)
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
            msg = _INTL("{1} cannot be frostbitten because of {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          end
        else
          case newStatus
          when :SLEEP     then msg = _INTL("{1} stays awake because of its {2}!", pbThis, abilityName)
          when :POISON    then msg = _INTL("{1}'s {2} prevents poisoning!", pbThis, abilityName)
          when :BURN      then msg = _INTL("{1}'s {2} prevents burns!", pbThis, abilityName)
          when :PARALYSIS then msg = _INTL("{1}'s {2} prevents paralysis!", pbThis, abilityName)
          when :FROZEN    then msg = _INTL("{1}'s {2} prevents frostbite!", pbThis, abilityName)
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
    return false if hasActiveAbility?(:BAROMETRIC)
    return false if !takesIndirectDamage?
    return false if pbHasType?(:GROUND) || pbHasType?(:FLYING)
    return false if inTwoTurnAttack?("0CA","0CB")   # Dig, Dive
    return false if hasActiveAbility?([:OVERCOAT,:SANDFORCE,:SANDRUSH,:SANDVEIL])
    return false if hasActiveItem?(:SAFETYGOGGLES)
    return true
  end
  def takesAcidRainDamage?
    return false if hasActiveAbility?(:BAROMETRIC)
    return false if !takesIndirectDamage?
    return false if pbHasType?(:POISON) || pbHasType?(:STEEL)
    return false if inTwoTurnAttack?("0CA","0CB")   # Dig, Dive
    return false if hasActiveAbility?([:OVERCOAT,:SANDFORCE,:SANDRUSH,:SANDVEIL])
    return false if hasActiveItem?(:SAFETYGOGGLES)
    return true
  end
  def takesStarstormDamage?
    return false if hasActiveAbility?(:BAROMETRIC)
    return false if !takesIndirectDamage?
    return false if pbHasType?(:COSMIC)
    return false if inTwoTurnAttack?("0CA","0CB")   # Dig, Dive
    return false if hasActiveAbility?([:OVERCOAT,:ICEBODY,:SNOWCLOAK])
    return false if hasActiveItem?(:SAFETYGOGGLES)
    return true
  end
end

class PokeBattle_Move
    def beamMove?;          return @flags[/p/]; end
    def damageReducedByFreeze?;  return true;  end   # For Facade
    def pbHitEffectivenessMessages(user,target,numTargets=1)
      return if target.damageState.disguise
      if target.damageState.substitute
        @battle.pbDisplay(_INTL("The substitute took damage for {1}!",target.pbThis(true)))
      end
      if target.damageState.critical
        if numTargets>1
          @battle.pbDisplay(_INTL("A critical hit on {1}!",target.pbThis(true)))
        else
          @battle.pbDisplay(_INTL("A critical hit!"))
        end
      end
      # Effectiveness message, for moves with 1 hit
      if !multiHitMove? && (user.effects[PBEffects::ParentalBond]==0 || user.effects[PBEffects::EchoChamber]==0)
        pbEffectivenessMessage(user,target,numTargets)
      end
      if target.damageState.substitute && target.effects[PBEffects::Substitute]==0
        target.effects[PBEffects::Substitute] = 0
        @battle.pbDisplay(_INTL("{1}'s substitute faded!",target.pbThis))
      end
    end
end

class PokeBattle_TargetMultiStatUpMove < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    return false if damagingMove?
    failed = true
    for i in 0...@statUp.length/2
      next if !target.pbCanRaiseStatStage?(@statUp[i*2],user,self)
      failed = false
      break
    end
    if failed
      # NOTE: It's a bit of a faff to make sure the appropriate failure message
      #       is shown here, I know.
      canRaise = false
      if target.hasActiveAbility?(:CONTRARY) && !@battle.moldBreaker
        for i in 0...@statUp.length/2
          next if target.statStageAtMin?(@statUp[i*2])
          canRaise = true
          break
        end
        @battle.pbDisplay(_INTL("{1}'s stats won't go any lower!",target.pbThis)) if !canRaise
      else
        for i in 0...@statUp.length/2
          next if target.statStageAtMax?(@statUp[i*2])
          canRaise = true
          break
        end
        @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",target.pbThis)) if !canRaise
      end
      if canRaise
        target.pbCanRaiseStatStage?(@statUp[0],user,self,true)
      end
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    return if damagingMove?
    showAnim = true
    for i in 0...@statUp.length/2
      next if !target.pbCanRaiseStatStage?(@statUp[i*2],user,self)
      if target.pbRaiseStatStage(@statUp[i*2],@statUp[i*2+1],user,showAnim)
        showAnim = false
      end
    end
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    showAnim = true
    for i in 0...@statUp.length/2
      next if !target.pbCanLowerStatStage?(@statUp[i*2],user,self)
      if target.pbRaiseStatStage(@statUp[i*2],@statUp[i*2+1],user,showAnim)
        showAnim = false
      end
    end
  end
end

class PokeBattle_Battle
  alias initialize_ex initialize
  def initialize(scene,p1,p2,player,opponent)
    initialize_ex(scene,p1,p2,player,opponent)
    $game_variables[101] = -1
  end
end

class PokeBattle_Move_049 < PokeBattle_TargetStatDownMove
  def ignoresSubstitute?(user); return true; end

  def initialize(battle,move)
    super
    @statDown = [:EVASION,1]
  end

  def pbFailsAgainstTarget?(user,target)
    targetSide = target.pbOwnSide
    targetOpposingSide = target.pbOpposingSide
    return false if targetSide.effects[PBEffects::AuroraVeil]>0 ||
                    targetSide.effects[PBEffects::LightScreen]>0 ||
                    targetSide.effects[PBEffects::Reflect]>0 ||
                    targetSide.effects[PBEffects::Mist]>0 ||
                    targetSide.effects[PBEffects::Safeguard]>0
    return false if targetSide.effects[PBEffects::StealthRock] ||
                    targetSide.effects[PBEffects::Spikes]>0 ||
                    targetSide.effects[PBEffects::ToxicSpikes]>0 ||
                    targetSide.effects[PBEffects::StickyWeb]
    return false if Settings::MECHANICS_GENERATION >= 6 &&
                    (targetOpposingSide.effects[PBEffects::StealthRock] ||
                    targetOpposingSide.effects[PBEffects::Spikes]>0 ||
                    targetOpposingSide.effects[PBEffects::ToxicSpikes]>0 ||
                    targetOpposingSide.effects[PBEffects::StickyWeb] ||
                    targetOpposingSide.effects[PBEffects::CometShards])
    return false if Settings::MECHANICS_GENERATION >= 8 && @battle.field.terrain != :None
    return super
  end

  def pbEffectAgainstTarget(user,target)
    if target.pbCanLowerStatStage?(@statDown[0],user,self)
      target.pbLowerStatStage(@statDown[0],@statDown[1],user)
    end
    if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0
      target.pbOwnSide.effects[PBEffects::AuroraVeil] = 0
      @battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::LightScreen]>0
      target.pbOwnSide.effects[PBEffects::LightScreen] = 0
      @battle.pbDisplay(_INTL("{1}'s Light Screen wore off!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Reflect]>0
      target.pbOwnSide.effects[PBEffects::Reflect] = 0
      @battle.pbDisplay(_INTL("{1}'s Reflect wore off!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Mist]>0
      target.pbOwnSide.effects[PBEffects::Mist] = 0
      @battle.pbDisplay(_INTL("{1}'s Mist faded!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Safeguard]>0
      target.pbOwnSide.effects[PBEffects::Safeguard] = 0
      @battle.pbDisplay(_INTL("{1} is no longer protected by Safeguard!!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::StealthRock] ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::StealthRock])
      target.pbOwnSide.effects[PBEffects::StealthRock]      = false
      target.pbOpposingSide.effects[PBEffects::StealthRock] = false if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away stealth rocks!",user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::Spikes]>0 ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::Spikes]>0)
      target.pbOwnSide.effects[PBEffects::Spikes]      = 0
      target.pbOpposingSide.effects[PBEffects::Spikes] = 0 if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away spikes!",user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::ToxicSpikes]>0)
      target.pbOwnSide.effects[PBEffects::ToxicSpikes]      = 0
      target.pbOpposingSide.effects[PBEffects::ToxicSpikes] = 0 if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away poison spikes!",user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::StickyWeb] ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::StickyWeb])
      target.pbOwnSide.effects[PBEffects::StickyWeb]      = false
      target.pbOpposingSide.effects[PBEffects::StickyWeb] = false if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away sticky webs!",user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::CometShards] ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::CometShards])
      target.pbOwnSide.effects[PBEffects::CometShards]      = false
      target.pbOpposingSide.effects[PBEffects::CometShards] = false if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away stealth rocks!",user.pbThis))
    end
    if Settings::MECHANICS_GENERATION >= 8 && @battle.field.terrain != :None
      case @battle.field.terrain
      when :Electric
        @battle.pbDisplay(_INTL("The electricity disappeared from the battlefield."))
      when :Grassy
        @battle.pbDisplay(_INTL("The grass disappeared from the battlefield."))
      when :Misty
        @battle.pbDisplay(_INTL("The mist disappeared from the battlefield."))
      when :Psychic
        @battle.pbDisplay(_INTL("The weirdness disappeared from the battlefield."))
      when :Poison
        @battle.pbDisplay(_INTL("The toxic waste disappeared from the battlefield."))
      end
      @battle.field.terrain = :None
    end
  end
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

class PokeBattle_Move_110 < PokeBattle_Move
  def pbEffectAfterAllHits(user,target)
    return if user.fainted? || target.damageState.unaffected
    if user.effects[PBEffects::Trapping]>0
      trapMove = GameData::Move.get(user.effects[PBEffects::TrappingMove]).name
      trapUser = @battle.battlers[user.effects[PBEffects::TrappingUser]]
      @battle.pbDisplay(_INTL("{1} got free of {2}'s {3}!",user.pbThis,trapUser.pbThis(true),trapMove))
      user.effects[PBEffects::Trapping]     = 0
      user.effects[PBEffects::TrappingMove] = nil
      user.effects[PBEffects::TrappingUser] = -1
    end
    if user.effects[PBEffects::LeechSeed]>=0
      user.effects[PBEffects::LeechSeed] = -1
      @battle.pbDisplay(_INTL("{1} shed Leech Seed!",user.pbThis))
    end
    if user.effects[PBEffects::StarSap]>=0
      user.effects[PBEffects::StarSap] = -1
      @battle.pbDisplay(_INTL("{1} shed Star Sap!",user.pbThis))
    end
    if user.pbOwnSide.effects[PBEffects::StealthRock]
      user.pbOwnSide.effects[PBEffects::StealthRock] = false
      @battle.pbDisplay(_INTL("{1} blew away stealth rocks!",user.pbThis))
    end
    if user.pbOwnSide.effects[PBEffects::Spikes]>0
      user.pbOwnSide.effects[PBEffects::Spikes] = 0
      @battle.pbDisplay(_INTL("{1} blew away spikes!",user.pbThis))
    end
    if user.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
      user.pbOwnSide.effects[PBEffects::ToxicSpikes] = 0
      @battle.pbDisplay(_INTL("{1} blew away poison spikes!",user.pbThis))
    end
    if user.pbOwnSide.effects[PBEffects::StickyWeb]
      user.pbOwnSide.effects[PBEffects::StickyWeb] = false
      @battle.pbDisplay(_INTL("{1} blew away sticky webs!",user.pbThis))
    end
    user.pbRaiseStatStage(:SPEED,1,user)
  end
end

class PokeBattle_Move_176 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPEED,1]
  end

  def pbMoveFailed?(user,targets)
    if Settings::MECHANICS_GENERATION >= 7 && @id == :AURAWHEEL
      if !user.isSpecies?(:MORPEKO) &&
         !user.effects[PBEffects::TransformSpecies] == :MORPEKO
        @battle.pbDisplay(_INTL("But {1} can't use the move!",user.pbThis))
        return true
      end
    end
    return false
  end

  def pbBaseType(user)
    ret = :NORMAL
    case user.form
    when 0
      ret = :ELECTRIC if GameData::Type.exists?(:ELECTRIC)
    when 1
      ret = :DARK if GameData::Type.exists?(:DARK)
    end
    return ret
  end
end



#===============================================================================
# User's Defense is used instead of user's Attack for this move's calculations.
# (Body Press)
#===============================================================================
class PokeBattle_Move_177 < PokeBattle_Move
  def pbGetAttackStats(user,target)
    return user.defense, (user.stages[:DEFENSE] + 6)
  end
end



#===============================================================================
# If the user attacks before the target, or if the target switches in during the
# turn that Fishious Rend is used, its base power doubles. (Fishious Rend, Bolt Beak)
#===============================================================================
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



#===============================================================================
# Raises all user's stats by 1 stage in exchange for the user losing 1/3 of its
# maximum HP, rounded down. Fails if the user would faint. (Clangorous Soul)
#===============================================================================
class PokeBattle_Move_179 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.hp<=(user.totalhp/3) ||
	  (!user.pbCanRaiseStatStage?(:ATTACK,user,self) &&
      !user.pbCanRaiseStatStage?(:DEFENSE,user,self) &&
      !user.pbCanRaiseStatStage?(:SPEED,user,self) &&
      !user.pbCanRaiseStatStage?(:SPATK,user,self) &&
      !user.pbCanRaiseStatStage?(:SPDEF,user,self))
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    if user.pbCanRaiseStatStage?(:ATTACK,user,self)
      user.pbRaiseStatStage(:ATTACK,1,user)
    end
    if user.pbCanRaiseStatStage?(:DEFENSE,user,self)
      user.pbRaiseStatStage(:DEFENSE,1,user)
    end
    if user.pbCanRaiseStatStage?(:SPEED,user,self)
      user.pbRaiseStatStage(:SPEED,1,user)
    end
    if user.pbCanRaiseStatStage?(:SPATK,user,self)
      user.pbRaiseStatStage(:SPATK,1,user)
    end
    if user.pbCanRaiseStatStage?(:SPDEF,user,self)
      user.pbRaiseStatStage(:SPDEF,1,user)
    end
    user.pbReduceHP(user.totalhp/3,false)
  end
end



#===============================================================================
# Swaps barriers, veils and other effects between each side of the battlefield.
# (Court Change)
#===============================================================================
class PokeBattle_Move_17A < PokeBattle_Move
  def initialize(battle,move)
    super
    @swapEffects = [:Reflect, :LightScreen, :AuroraVeil, :SeaOfFire,
      :Swamp, :Rainbow, :Mist, :Safeguard, :StealthRock, :Spikes,
      :StickyWeb, :ToxicSpikes,:Tailwind].map!{|e| getConst(PBEffects,e) }
  end

  def pbMoveFailed(user,targets)
    sides = [user.pbOwnSide,user.pbOpposingSide]
    failed = true
    for i in 0...2
      for j in @swapEffects
        next if !sides[i].effects[j] || sides[i].effects[j] == 0
        failed = false
        break
      end
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed..."))
      return true
    end
    return false
  end


  def pbEffectGeneral(user)
    for j in @swapEffects
      user.pbSwapOwnSideEffect(j)
    end
    @battle.pbDisplay(_INTL("{1} swapped the battle effects affecting each side of the field!",user.pbThis))
  end
end



#===============================================================================
# The user sharply raises the target's Attack and Sp. Atk stats by decorating
# the target. (Decorate)
#===============================================================================
class PokeBattle_Move_17B < PokeBattle_TargetMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,2,:SPATK,2]
  end
end



#===============================================================================
# In singles, this move hits the target twice. In doubles, this move hits each
# target once. If one of the two opponents protects or while semi-invulnerable
# or is a Fairy-type Pokémon, it hits the opponent that doesn't protect twice.
# In Doubles, not affected by WideGuard.
# (Dragon Darts)
#===============================================================================
class PokeBattle_Move_17C < PokeBattle_Move_0BD
  def pbNumHits(user,targets)
    return 1 if targets.length > 1
    return 2
  end
end



#===============================================================================
# Prevents both the user and the target from escaping. (Jaw Lock)
#===============================================================================
class PokeBattle_Move_17D < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    if target.effects[PBEffects::JawLockUser] == -1 && !target.effects[PBEffects::JawLock] &&
      user.effects[PBEffects::JawLockUser] == -1 && !user.effects[PBEffects::JawLock]
      user.effects[PBEffects::JawLock]       = true
      target.effects[PBEffects::JawLock]     = true
      user.effects[PBEffects::JawLockUser]   = user.index
      target.effects[PBEffects::JawLockUser] = user.index
      @battle.pbDisplay(_INTL("Neither Pokémon can run away!"))
    end
  end
end



#===============================================================================
# The user restores 1/4 of its maximum HP, rounded half up. If there is and
# adjacent ally, the user restores 1/4 of both its and its ally's maximum HP,
# rounded up. (Life Dew)
#===============================================================================
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
    if target.hp == target.totalhp
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
end



#===============================================================================
# Increases each stat by 1 stage. Prevents user from fleeing. (No Retreat)
#===============================================================================
class PokeBattle_Move_17F < PokeBattle_MultiStatUpMove
  def pbMoveFailed?(user,targets)
    if user.effects[PBEffects::NoRetreat]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if !user.pbCanRaiseStatStage?(:ATTACK,user,self,true) &&
       !user.pbCanRaiseStatStage?(:DEFENSE,user,self,true) &&
       !user.pbCanRaiseStatStage?(:SPATK,user,self,true) &&
       !user.pbCanRaiseStatStage?(:SPDEF,user,self,true) &&
       !user.pbCanRaiseStatStage?(:SPEED,user,self,true)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    if user.pbCanRaiseStatStage?(:ATTACK,user,self)
      user.pbRaiseStatStage(:ATTACK,1,user)
    end
    if user.pbCanRaiseStatStage?(:DEFENSE,user,self)
      user.pbRaiseStatStage(:DEFENSE,1,user)
    end
    if user.pbCanRaiseStatStage?(:SPEED,user,self)
      user.pbRaiseStatStage(:SPEED,1,user)
    end
    if user.pbCanRaiseStatStage?(:SPATK,user,self)
      user.pbRaiseStatStage(:SPATK,1,user)
    end
    if user.pbCanRaiseStatStage?(:SPDEF,user,self)
      user.pbRaiseStatStage(:SPDEF,1,user)
    end
    if !(user.effects[PBEffects::MeanLook]>=0 || user.effects[PBEffects::Trapping]>0 ||
       user.effects[PBEffects::JawLock] || user.effects[PBEffects::OctolockUser]>=0)
      user.effects[PBEffects::NoRetreat] = true
      @battle.pbDisplay(_INTL("{1} can no longer escape because it used No Retreat!",user.pbThis))
    end
  end
end

#===============================================================================
# User is protected against damaging moves this round. Decreases the Defense of
# the user of a stopped contact move by 2 stages. (Obstruct)
#===============================================================================
class PokeBattle_Move_180 < PokeBattle_ProtectMove
  def initialize(battle,move)
    super
    @effect = PBEffects::Obstruct
  end
end



#===============================================================================
# Lowers target's Defense and Special Defense by 1 stage at the end of each
# turn. Prevents target from retreating. (Octolock)
#===============================================================================
class PokeBattle_Move_181 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if target.effects[PBEffects::OctolockUser]>=0 || (target.damageState.substitute && !ignoresSubstitute?(user))
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if Settings::MORE_TYPE_EFFECTS && target.pbHasType?(:GHOST)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::OctolockUser] = user.index
    target.effects[PBEffects::Octolock] = true
    @battle.pbDisplay(_INTL("{1} can no longer escape!",target.pbThis))
  end
end

#===============================================================================
# Changes Revelation Dance to only change types for Oricorio
#===============================================================================
class PokeBattle_Move_169 < PokeBattle_Move
  def pbBaseType(user)
    userTypes = user.pbTypes(true)
    if user.isSpecies?(:ORICORIO)
      return userTypes[0]
    else
      return :NORMAL
    end
  end
end

#===============================================================================
# Ignores move redirection from abilities and moves. (Snipe Shot)
#===============================================================================
class PokeBattle_Move_182 < PokeBattle_Move
end



#===============================================================================
# Consumes berry and raises the user's Defense by 2 stages. (Stuff Cheeks)
#===============================================================================
class PokeBattle_Move_183 < PokeBattle_Move

  def pbMoveFailed?(user,targets)
    if (!user.item || !user.item.is_berry?) && user.pbCanRaiseStatStage?(:DEFENSE,user,self)
      @battle.pbDisplay("But it failed!")
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbRaiseStatStage(:DEFENSE,2,user)
    user.pbHeldItemTriggerCheck(user.item,false)
    user.pbConsumeItem(true,true,false) if user.item
  end
end



#===============================================================================
# Forces all active Pokémon to consume their held berries. This move bypasses
# Substitutes. (Tea Time)
#===============================================================================
class PokeBattle_Move_184 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbMoveFailed?(user,targets)
    @validTargets = []
    @battle.eachBattler do |b|
      next if !b.item || !b.item.is_berry?
      @validTargets.push(b.index)
    end
    if @validTargets.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    return false if @validTargets.include?(target.index)
    return true if target.semiInvulnerable?
  end

  def pbEffectAgainstTarget(user,target)
    @battle.pbDisplay(_INTL("It's tea time! Everyone dug in to their Berries!"))
    target.pbHeldItemTriggerCheck(target.item,false)
    target.pbConsumeItem(true,true,false) if target.item.is_berry?
  end
end



#===============================================================================
# Decreases Opponent's Defense by 1 stage. Does Double Damage under gravity
# (Grav Apple)
#===============================================================================
class PokeBattle_Move_185 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:DEFENSE,1]
  end

  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 1.5 if @battle.field.effects[PBEffects::Gravity] > 0
    return baseDmg
  end
end



#===============================================================================
# Decrease 1 stage of speed and weakens target to fire moves. (Tar Shot)
#===============================================================================
class PokeBattle_Move_186 < PokeBattle_Move

  def pbFailsAgainstTarget?(user,target)
    if !target.pbCanLowerStatStage?(:SPEED,target,self) && !target.effects[PBEffects::TarShot]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.pbLowerStatStage(:SPEED,1,target)
    target.effects[PBEffects::TarShot] = true
    @battle.pbDisplay(_INTL("{1} became weaker to fire!",target.pbThis))
  end
end



#===============================================================================
# Changes Category based on Opponent's Def and SpDef. Has 20% Chance to Poison
# (Shell Side Arm)
#===============================================================================
class PokeBattle_Move_187 < PokeBattle_Move_005
  def initialize(battle,move)
    super
    @calcCategory = 1
  end

  def pbContactMove?(user)
    ret = super
    ret = true if physicalMove?
    return ret
  end

  def physicalMove?(thisType=nil); return (@calcCategory==0); end
  def specialMove?(thisType=nil);  return (@calcCategory==1); end

  def pbOnStartUse(user,targets)
    return false if !targets.is_a?(Array)
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    defense      = targets[0].defense
    defenseStage = targets[0].stages[:DEFENSE]+6
    realDefense  = (defense.to_f*stageMul[defenseStage]/stageDiv[defenseStage]).floor
    spdef        = targets[0].spdef
    spdefStage   = targets[0].stages[:SPDEF]+6
    realSpdef    = (spdef.to_f*stageMul[spdefStage]/stageDiv[spdefStage]).floor
    # Determine move's category
    @calcCategory = (realDefense < realSpdef) ? 0 : 1
  end
end



#===============================================================================
# Hits 3 times and always critical. (Surging Strikes)
#===============================================================================
class PokeBattle_Move_188 < PokeBattle_Move_0A0
  def multiHitMove?;           return true; end
  def pbNumHits(user,targets); return 3;    end
end

#===============================================================================
# Restore HP and heals any status conditions of itself and its allies
# (Jungle Healing)
#===============================================================================
class PokeBattle_Move_189 < PokeBattle_Move
  def healingMove?; return true; end

  def pbMoveFailed?(user,targets)
    jglheal = 0
    for i in 0...targets.length
      jglheal += 1 if (!targets[i].canHeal?) && targets[i].pbHasAnyStatus?
    end
    if jglheal == targets.length
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.pbCureStatus
    if target.canHeal?
      hpGain = (target.totalhp/4.0).round
      target.pbRecoverHP(hpGain)
      @battle.pbDisplay(_INTL("{1}'s health was restored.",target.pbThis))
    end
    super
  end
end



#===============================================================================
# Changes type and base power based on Battle Terrain (Terrain Pulse)
#===============================================================================
class PokeBattle_Move_18A < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if @battle.field.terrain != :None && !user.airborne?
    return baseDmg
  end

  def pbBaseType(user)
    ret = :NORMAL
    if !user.airborne?
      case @battle.field.terrain
      when :Electric
        ret = :ELECTRIC if GameData::Type.exists?(:ELECTRIC)
      when :Grassy
        ret = :GRASS if GameData::Type.exists?(:GRASS)
      when :Misty
        ret = :FAIRY if GameData::Type.exists?(:FAIRY)
      when :Psychic
        ret = :PSYCHIC if GameData::Type.exists?(:PSYCHIC)
      when :Poison
        ret = :POISON if GameData::Type.exists?(:POISON)
      end
    end
    return ret
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    t = pbBaseType(user)
    hitNum = 1 if t == :ELECTRIC
    hitNum = 2 if t == :GRASS
    hitNum = 3 if t == :FAIRY
    hitNum = 4 if t == :PSYCHIC
    super
  end
end



#===============================================================================
# Burns opposing Pokemon that have increased their stats in that turn before the
# execution of this move (Burning Jealousy)
#===============================================================================
class PokeBattle_Move_18B < PokeBattle_Move
  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    return if target.damageState.iceface
    if target.pbCanBurn?(user,false,self) &&
       target.effects[PBEffects::BurningJealousy]
      target.pbBurn(user)
    end
  end
end



#===============================================================================
# Move has increased Priority in Grassy Terrain (Grassy Glide)
#===============================================================================
class PokeBattle_Move_18C < PokeBattle_Move
  def pbChangePriority(user)
    return 1 if @battle.field.terrain == :Grassy && !user.airborne?
    return 0
  end
end



#===============================================================================
# Power Doubles onn Electric Terrain (Rising Voltage)
#===============================================================================
class PokeBattle_Move_18D < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if @battle.field.terrain == :Electric &&
                    !target.airborne?
    return baseDmg
  end
end



#===============================================================================
# Boosts Targets' Attack and Defense (Coaching)
#===============================================================================
class PokeBattle_Move_18E < PokeBattle_TargetMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,1,:DEFENSE,1]
  end
end



#===============================================================================
# Renders item unusable (Corrosive Gas)
#===============================================================================
class PokeBattle_Move_18F < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    return if @battle.wildBattle? && user.opposes?   # Wild Pokémon can't knock off
    return if user.fainted?
    return if target.damageState.substitute
    return if !target.item || target.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    itemName = target.itemName
    target.pbRemoveItem(false)
    @battle.pbDisplay(_INTL("{1} dropped its {2}!",target.pbThis,itemName))
  end
end



#===============================================================================
# Power is boosted on Psychic Terrain (Expanding Force)
#===============================================================================
class PokeBattle_Move_190 < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 1.5 if @battle.field.terrain == :Psychic
    return baseDmg
  end
end



#===============================================================================
# Boosts Sp Atk on 1st Turn and Attacks on 2nd (Meteor Beam)
#===============================================================================
class PokeBattle_Move_191 < PokeBattle_TwoTurnMove
  def pbChargingTurnMessage(user,targets)
    @battle.pbDisplay(_INTL("{1} is overflowing with space power!",user.pbThis))
  end

  def pbChargingTurnEffect(user,target)
    if user.pbCanRaiseStatStage?(:SPATK,user,self)
      user.pbRaiseStatStage(:SPATK,1,user)
    end
  end
end



#===============================================================================
# Fails if the Target has no Item (Poltergeist)
#===============================================================================
class PokeBattle_Move_192 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if !target.item
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    @battle.pbDisplay(_INTL("{1} is about to be attacked by its {2}!",target.pbThis,target.itemName))
    return false
  end
end



#===============================================================================
# Reduces Defense and Raises Speed after all hits (Scale Shot)
#===============================================================================
class PokeBattle_Move_193 < PokeBattle_Move_0C0
  def pbEffectAfterAllHits(user,target)
    if user.pbCanRaiseStatStage?(:SPEED,user,self)
      user.pbRaiseStatStage(:SPEED,1,user)
    end
    if user.pbCanLowerStatStage?(:DEFENSE,target)
      user.pbLowerStatStage(:DEFENSE,1,user)
    end
  end
end



#===============================================================================
# Double damage if stats were lowered that turn. (Lash Out)
#===============================================================================
class PokeBattle_Move_194 < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if user.effects[PBEffects::LashOut]
    return baseDmg
  end
end



#===============================================================================
# Removes all Terrain. Fails if there is no Terrain (Steel Roller)
#===============================================================================
class PokeBattle_Move_195 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.field.terrain == :None
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    case @battle.field.terrain
      when :Electric
        @battle.pbDisplay(_INTL("The electric current disappeared from the battlefield!"))
      when :Grassy
        @battle.pbDisplay(_INTL("The grass disappeared from the battlefield!"))
      when :Misty
        @battle.pbDisplay(_INTL("The mist disappeared from the battlefield!"))
      when :Psychic
        @battle.pbDisplay(_INTL("The weirdness disappeared from the battlefield!"))
      when :Poison
        @battle.pbDisplay(_INTL("The toxic waste disappeared from the battlefield!"))
    end
    @battle.field.terrain = :None
  end
end



#===============================================================================
# Self KO. Boosted Damage when on Misty Terrain (Misty Explosion)
#===============================================================================
class PokeBattle_Move_196 < PokeBattle_Move_0E0
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 1.5 if @battle.field.terrain == :Misty &&
                        !user.airborne?
    return baseDmg
  end
end



#===============================================================================
# Target becomes Psychic type. (Magic Powder)
#===============================================================================
class PokeBattle_Move_197 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if !target.canChangeType? ||
       !target.pbHasOtherType?(:PSYCHIC)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    newType = :PSYCHIC
    target.pbChangeTypes(newType)
    typeName = GameData::Type.get(newType).name
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",target.pbThis,typeName))
  end
end

#===============================================================================
# Target's last move used loses 3 PP. (Eerie Spell - Galarian Slowking)
#===============================================================================
class PokeBattle_Move_198 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    failed = true
    target.eachMove do |m|
      next if m.id != target.lastRegularMoveUsed || m.pp==0 || m.totalpp<=0
      failed = false; break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.eachMove do |m|
      next if m.id != target.lastRegularMoveUsed
      reduction = [3,m.pp].min
      target.pbSetPP(m,m.pp-reduction)
      @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",
         target.pbThis(true),m.name,reduction))
      break
    end
  end
end


#===============================================================================
# Deals double damage to Dynamax POkémons. Dynamax is not implemented though.
# (Behemoth Blade, Behemoth Bash, Dynamax Cannon)
#===============================================================================
class PokeBattle_Move_199 < PokeBattle_Move
  # DYNAMAX IS NOT IMPLEMENTED.
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
    return Effectiveness::NORMAL_EFFECTIVE_ONE if moveType == :ELECTRIC &&
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
    target.effects[PBEffects::StarSap] = user.index
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

class PokeBattle_Move
  def pbRecordDamageLost(user,target)
    damage = target.damageState.hpLost
    # NOTE: In Gen 3 where a move's category depends on its type, Hidden Power
    #       is for some reason countered by Counter rather than Mirror Coat,
    #       regardless of its calculated type. Hence the following two lines of
    #       code.
    moveType = nil
    moveType = :NORMAL if @function=="090"   # Hidden Power
    if physicalMove?(moveType)
      target.effects[PBEffects::Counter]       = damage
      target.effects[PBEffects::CounterTarget] = user.index
    elsif specialMove?(moveType)
      target.effects[PBEffects::MirrorCoat]       = damage
      target.effects[PBEffects::MirrorCoatTarget] = user.index
    end
    if target.effects[PBEffects::Bide]>0
      target.effects[PBEffects::BideDamage] += damage
      target.effects[PBEffects::BideTarget] = user.index
    end
    if target.fainted?
      target.damageState.fainted = true
    end
    target.lastHPLost = damage             # For Focus Punch
    target.tookDamage = true if damage>0   # For Assurance
    target.lastAttacker.push(user.index)   # For Revenge
    if target.opposes?(user)
      target.lastHPLostFromFoe = damage              # For Metal Burst
      target.lastFoeAttacker.push(user.index)        # For Metal Burst
    end
  end
end

class PokeBattle_Battle
  def pbRecallAndReplace(idxBattler,idxParty,randomReplacement=false,batonPass=false)
    @battlers[idxBattler].pbAbilitiesOnSwitchOut   # Inc. primordial weather check
    if (@battlers[idxBattler].ability == :BAROMETRIC && @battlers[idxBattler].isSpecies?(:ALTEMPER)) || (@battlers[idxBattler].ability == :FORECAST && @battlers[idxBattler].isSpecies?(:CASTFORM))
      if @battlers[idxBattler].form >= 21
        if @battlers[idxBattler].form >= 42
          @battlers[idxBattler].form = 42
        else
          @battlers[idxBattler].form = 21
        end
      else
        @battlers[idxBattler].form = 0
      end
    else
      @battlers[idxBattler].form = @battlers[idxBattler].pokemon.form
    end
    @scene.pbShowPartyLineup(idxBattler&1) if pbSideSize(idxBattler)==1
    pbMessagesOnReplace(idxBattler,idxParty) if !randomReplacement
    pbReplace(idxBattler,idxParty,batonPass)
  end
  alias pbRecallAndReplace_ebdx pbRecallAndReplace unless self.method_defined?(:pbRecallAndReplace_ebdx)
  def pbRecallAndReplace(*args)
    # displays trainer dialogue if applicable
    @scene.pbTrainerBattleSpeech(playerBattler?(@battlers[args[0]]) ? "recall" : "recallOpp")
    @replaced = true
    # specifies sendout toggle
    @scene.sendingOut = true if args[0]%2 == 0
    return pbRecallAndReplace_ebdx(*args)
  end

  alias pbReplace_ebdx pbReplace unless self.method_defined?(:pbReplace_ebdx)
  def pbReplace(index, *args)
    # displays trainer dialogue if applicable
    opt = playerBattler?(@battlers[index]) ? ["last", "beforeLast"] : ["lastOpp", "beforeLastOpp"]
    @scene.pbTrainerBattleSpeech(*opt)
    if !@replaced
      if !@battlers[index].isSpecies?(:ALTEMPER) && !@battlers[index].isSpecies?(:CASTFORM) && !@battlers[index].isSpecies?(:CHERRIM)
        @battlers[index].form = @battlers[index].pokemon.form
      else
        if @battlers[index].form <= 20
          @battlers[index].form = 0
        elsif @battlers[index].form >= 21 && @battlers[index].form <= 41
          @battlers[index].form = 21
        elsif @battlers[index].form >= 42
          @battlers[index].form = 42
        end
      end
      if !@battlers[index].fainted?
        @scene.pbRecall(index)
      end
    end
    pbReplace_ebdx(index, *args)
    @replaced = false
    opt = playerBattler?(@battlers[index]) ? "afterLast" : "afterLastOpp"
    @scene.pbTrainerBattleSpeech(opt)
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

  def pbEORTerrain
    # Count down terrain duration
    @field.terrainDuration -= 1 if @field.terrainDuration>0
    # Terrain wears off
    if @field.terrain != :None && @field.terrainDuration == 0
      case @field.terrain
      when :Electric
        pbDisplay(_INTL("The electric current disappeared from the battlefield!"))
      when :Grassy
        pbDisplay(_INTL("The grass disappeared from the battlefield!"))
      when :Misty
        pbDisplay(_INTL("The mist disappeared from the battlefield!"))
      when :Psychic
        pbDisplay(_INTL("The weirdness disappeared from the battlefield!"))
      when :Poison
        pbDisplay(_INTL("The toxic waste disappeared from the battlefield!"))
      end
      @field.terrain = :None
      # Start up the default terrain
      pbStartTerrain(nil, @field.defaultTerrain, false) if @field.defaultTerrain != :None
      return if @field.terrain == :None
    end
    # Terrain continues
    terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
    pbCommonAnimation(terrain_data.animation) if terrain_data
    case @field.terrain
    when :Electric then pbDisplay(_INTL("An electric current is running across the battlefield."))
    when :Grassy   then pbDisplay(_INTL("Grass is covering the battlefield."))
    when :Misty    then pbDisplay(_INTL("Mist is swirling about the battlefield."))
    when :Psychic  then pbDisplay(_INTL("The battlefield is weird."))
    when :Poison  then pbDisplay(_INTL("Toxic waste covers the battlefield."))
    end
  end

  def pbEndOfRoundPhase
    PBDebug.log("")
    PBDebug.log("[End of round]")
    @endOfRound = true
    @scene.pbBeginEndOfRoundPhase
    pbCalculatePriority           # recalculate speeds
    priority = pbPriority(true)   # in order of fastest -> slowest speeds only
    # Weather
    pbEORWeather(priority)
    # Future Sight/Doom Desire
    @positions.each_with_index do |pos,idxPos|
      next if !pos || pos.effects[PBEffects::FutureSightCounter]==0
      pos.effects[PBEffects::FutureSightCounter] -= 1
      next if pos.effects[PBEffects::FutureSightCounter]>0
      next if !@battlers[idxPos] || @battlers[idxPos].fainted?   # No target
      moveUser = nil
      eachBattler do |b|
        next if b.opposes?(pos.effects[PBEffects::FutureSightUserIndex])
        next if b.pokemonIndex!=pos.effects[PBEffects::FutureSightUserPartyIndex]
        moveUser = b
        break
      end
      next if moveUser && moveUser.index==idxPos   # Target is the user
      if !moveUser   # User isn't in battle, get it from the party
        party = pbParty(pos.effects[PBEffects::FutureSightUserIndex])
        pkmn = party[pos.effects[PBEffects::FutureSightUserPartyIndex]]
        if pkmn && pkmn.able?
          moveUser = PokeBattle_Battler.new(self,pos.effects[PBEffects::FutureSightUserIndex])
          moveUser.pbInitDummyPokemon(pkmn,pos.effects[PBEffects::FutureSightUserPartyIndex])
        end
      end
      next if !moveUser   # User is fainted
      move = pos.effects[PBEffects::FutureSightMove]
      pbDisplay(_INTL("{1} took the {2} attack!",@battlers[idxPos].pbThis,
         GameData::Move.get(move).name))
      # NOTE: Future Sight failing against the target here doesn't count towards
      #       Stomping Tantrum.
      userLastMoveFailed = moveUser.lastMoveFailed
      @futureSight = true
      moveUser.pbUseMoveSimple(move,idxPos)
      @futureSight = false
      moveUser.lastMoveFailed = userLastMoveFailed
      @battlers[idxPos].pbFaint if @battlers[idxPos].fainted?
      pos.effects[PBEffects::FutureSightCounter]        = 0
      pos.effects[PBEffects::FutureSightMove]           = nil
      pos.effects[PBEffects::FutureSightUserIndex]      = -1
      pos.effects[PBEffects::FutureSightUserPartyIndex] = -1
    end
    # Wish
    @positions.each_with_index do |pos,idxPos|
      next if !pos || pos.effects[PBEffects::Wish]==0
      pos.effects[PBEffects::Wish] -= 1
      next if pos.effects[PBEffects::Wish]>0
      next if !@battlers[idxPos] || !@battlers[idxPos].canHeal?
      wishMaker = pbThisEx(idxPos,pos.effects[PBEffects::WishMaker])
      @battlers[idxPos].pbRecoverHP(pos.effects[PBEffects::WishAmount])
      pbDisplay(_INTL("{1}'s wish came true!",wishMaker))
    end
    # Sea of Fire damage (Fire Pledge + Grass Pledge combination)
    curWeather = pbWeather
    for side in 0...2
      next if sides[side].effects[PBEffects::SeaOfFire]==0
      next if [:Rain, :HeavyRain].include?(curWeather)
      @battle.pbCommonAnimation("SeaOfFire") if side==0
      @battle.pbCommonAnimation("SeaOfFireOpp") if side==1
      priority.each do |b|
        next if b.opposes?(side)
        next if !b.takesIndirectDamage? || b.pbHasType?(:FIRE)
        oldHP = b.hp
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/8,false)
        pbDisplay(_INTL("{1} is hurt by the sea of fire!",b.pbThis))
        b.pbItemHPHealCheck
        b.pbAbilitiesOnDamageTaken(oldHP)
        b.pbFaint if b.fainted?
      end
    end
    # Status-curing effects/abilities and HP-healing items
    priority.each do |b|
      next if b.fainted?
      # Grassy Terrain (healing)
      if @field.terrain == :Grassy && b.affectedByTerrain? && b.canHeal?
        PBDebug.log("[Lingering effect] Grassy Terrain heals #{b.pbThis(true)}")
        b.pbRecoverHP(b.totalhp/16)
        pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
      elsif @field.terrain == :Poison && b.affectedByTerrain? && b.pbCanPoison?(b,false,nil)
          PBDebug.log("[Lingering effect] Poison Terrain poisons #{b.pbThis(true)}")
          b.pbInflictStatus(:POISON)
          pbDisplay(_INTL("{1}'s HP was poisoned by the toxic waste!",b.pbThis))
      end
      # Healer, Hydration, Shed Skin
      BattleHandlers.triggerEORHealingAbility(b.ability,b,self) if b.abilityActive?
      # Black Sludge, Leftovers
      BattleHandlers.triggerEORHealingItem(b.item,b,self) if b.itemActive?
    end
    #Aspirant
    @positions.each_with_index do |pos,idxPos|
      next if pos.effects[PBEffects::Wish] != 1
      pos.effects[PBEffects::Wish] -= 1
      next if !@battlers[idxPos] || !@battlers[idxPos].canHeal?
      wishMaker = $aspirantBattler
      @battlers[idxPos].pbRecoverHP(pos.effects[PBEffects::WishAmount])
      pbDisplay(_INTL("{1}'s wish came true!",wishMaker))
    end
    # Aqua Ring
    priority.each do |b|
      next if !b.effects[PBEffects::AquaRing]
      next if !b.canHeal?
      hpGain = b.totalhp/16
      hpGain = (hpGain*1.3).floor if b.hasActiveItem?(:BIGROOT)
      b.pbRecoverHP(hpGain)
      pbDisplay(_INTL("Aqua Ring restored {1}'s HP!",b.pbThis(true)))
    end
    # Ingrain
    priority.each do |b|
      next if !b.effects[PBEffects::Ingrain]
      next if !b.canHeal?
      hpGain = b.totalhp/16
      hpGain = (hpGain*1.3).floor if b.hasActiveItem?(:BIGROOT)
      b.pbRecoverHP(hpGain)
      pbDisplay(_INTL("{1} absorbed nutrients with its roots!",b.pbThis))
    end
    # Leech Seed
    priority.each do |b|
      next if b.effects[PBEffects::LeechSeed]<0
      next if !b.takesIndirectDamage?
      recipient = @battlers[b.effects[PBEffects::LeechSeed]]
      next if !recipient || recipient.fainted?
      oldHP = b.hp
      oldHPRecipient = recipient.hp
      pbCommonAnimation("LeechSeed",recipient,b)
      hpLoss = b.pbReduceHP(b.totalhp/8)
      recipient.pbRecoverHPFromDrain(hpLoss,b,
         _INTL("{1}'s health is sapped by Leech Seed!",b.pbThis))
      recipient.pbAbilitiesOnDamageTaken(oldHPRecipient) if recipient.hp<oldHPRecipient
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
      recipient.pbFaint if recipient.fainted?
    end
    priority.each do |b|
      next if b.effects[PBEffects::StarSap]<0
      next if !b.takesIndirectDamage?
      recipient = @battlers[b.effects[PBEffects::StarSap]]
      next if !recipient || recipient.fainted?
      oldHP = b.hp
      oldHPRecipient = recipient.hp
      pbCommonAnimation("LeechSeed",recipient,b)
      hpLoss = b.pbReduceHP(b.totalhp/8)
      recipient.pbRecoverHPFromDrain(hpLoss,b,
         _INTL("{1}'s health is sapped by Star Sap!",b.pbThis))
      recipient.pbAbilitiesOnDamageTaken(oldHPRecipient) if recipient.hp<oldHPRecipient
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
      recipient.pbFaint if recipient.fainted?
    end
    # Damage from Hyper Mode (Shadow Pokémon)
    priority.each do |b|
      next if !b.inHyperMode? || @choices[b.index][0]!=:UseMove
      hpLoss = b.totalhp/24
      @scene.pbDamageAnimation(b)
      b.pbReduceHP(hpLoss,false)
      pbDisplay(_INTL("The Hyper Mode attack hurts {1}!",b.pbThis(true)))
      b.pbFaint if b.fainted?
    end
    # Damage from poisoning
    priority.each do |b|
      next if b.fainted?
      next if b.status != :POISON
      if b.statusCount>0
        b.effects[PBEffects::Toxic] += 1
        b.effects[PBEffects::Toxic] = 15 if b.effects[PBEffects::Toxic]>15
      end
      if b.hasActiveAbility?(:POISONHEAL)
        if b.canHeal?
          anim_name = GameData::Status.get(:POISON).animation
          pbCommonAnimation(anim_name, b) if anim_name
          pbShowAbilitySplash(b)
          b.pbRecoverHP(b.totalhp/8)
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
          else
            pbDisplay(_INTL("{1}'s {2} restored its HP.",b.pbThis,b.abilityName))
          end
          pbHideAbilitySplash(b)
        end
      elsif b.takesIndirectDamage?
        oldHP = b.hp
        dmg = (b.statusCount==0) ? b.totalhp/8 : b.totalhp*b.effects[PBEffects::Toxic]/16
        b.pbContinueStatus { b.pbReduceHP(dmg,false) }
        b.pbItemHPHealCheck
        b.pbAbilitiesOnDamageTaken(oldHP)
        b.pbFaint if b.fainted?
      end
    end
    # Damage from burn
    priority.each do |b|
      next if b.status != :BURN || !b.takesIndirectDamage?
      oldHP = b.hp
      dmg = (Settings::MECHANICS_GENERATION >= 7) ? b.totalhp/16 : b.totalhp/8
      dmg = (dmg/2.0).round if b.hasActiveAbility?(:HEATPROOF)
      b.pbContinueStatus { b.pbReduceHP(dmg,false) }
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
    end
    priority.each do |b|
      next if b.status != :FROZEN || !b.takesIndirectDamage?
      oldHP = b.hp
      dmg = (Settings::MECHANICS_GENERATION >= 7) ? b.totalhp/16 : b.totalhp/8
      b.pbContinueStatus { b.pbReduceHP(dmg,false) }
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
    end
    # Damage from sleep (Nightmare)
    priority.each do |b|
      b.effects[PBEffects::Nightmare] = false if !b.asleep?
      next if !b.effects[PBEffects::Nightmare] || !b.takesIndirectDamage?
      oldHP = b.hp
      b.pbReduceHP(b.totalhp/4)
      pbDisplay(_INTL("{1} is locked in a nightmare!",b.pbThis))
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
    end
    # Curse
    priority.each do |b|
      next if !b.effects[PBEffects::Curse] || !b.takesIndirectDamage?
      oldHP = b.hp
      b.pbReduceHP(b.totalhp/4)
      pbDisplay(_INTL("{1} is afflicted by the curse!",b.pbThis))
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
    end
    # Trapping attacks (Bind/Clamp/Fire Spin/Magma Storm/Sand Tomb/Whirlpool/Wrap)
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::Trapping]==0
      b.effects[PBEffects::Trapping] -= 1
      moveName = GameData::Move.get(b.effects[PBEffects::TrappingMove]).name
      if b.effects[PBEffects::Trapping]==0
        pbDisplay(_INTL("{1} was freed from {2}!",b.pbThis,moveName))
      else
        case b.effects[PBEffects::TrappingMove]
        when :BIND        then pbCommonAnimation("Bind", b)
        when :CLAMP       then pbCommonAnimation("Clamp", b)
        when :FIRESPIN    then pbCommonAnimation("FireSpin", b)
        when :MAGMASTORM  then pbCommonAnimation("MagmaStorm", b)
        when :SANDTOMB    then pbCommonAnimation("SandTomb", b)
        when :WRAP        then pbCommonAnimation("Wrap", b)
        when :INFESTATION then pbCommonAnimation("Infestation", b)
        else                   pbCommonAnimation("Wrap", b)
        end
        if b.takesIndirectDamage?
          hpLoss = (Settings::MECHANICS_GENERATION >= 6) ? b.totalhp/8 : b.totalhp/16
          if @battlers[b.effects[PBEffects::TrappingUser]].hasActiveItem?(:BINDINGBAND)
            hpLoss = (Settings::MECHANICS_GENERATION >= 6) ? b.totalhp/6 : b.totalhp/8
          end
          @scene.pbDamageAnimation(b)
          b.pbReduceHP(hpLoss,false)
          pbDisplay(_INTL("{1} is hurt by {2}!",b.pbThis,moveName))
          b.pbItemHPHealCheck
          # NOTE: No need to call pbAbilitiesOnDamageTaken as b can't switch out.
          b.pbFaint if b.fainted?
        end
      end
    end
    # Taunt
    pbEORCountDownBattlerEffect(priority,PBEffects::Taunt) { |battler|
      pbDisplay(_INTL("{1}'s taunt wore off!",battler.pbThis))
    }
    # Encore
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::Encore]==0
      idxEncoreMove = b.pbEncoredMoveIndex
      if idxEncoreMove>=0
        b.effects[PBEffects::Encore] -= 1
        if b.effects[PBEffects::Encore]==0 || b.moves[idxEncoreMove].pp==0
          b.effects[PBEffects::Encore] = 0
          pbDisplay(_INTL("{1}'s encore ended!",b.pbThis))
        end
      else
        PBDebug.log("[End of effect] #{b.pbThis}'s encore ended (encored move no longer known)")
        b.effects[PBEffects::Encore]     = 0
        b.effects[PBEffects::EncoreMove] = nil
      end
    end
    # Disable/Cursed Body
    pbEORCountDownBattlerEffect(priority,PBEffects::Disable) { |battler|
      battler.effects[PBEffects::DisableMove] = nil
      pbDisplay(_INTL("{1} is no longer disabled!",battler.pbThis))
    }
    # Magnet Rise
    pbEORCountDownBattlerEffect(priority,PBEffects::MagnetRise) { |battler|
      pbDisplay(_INTL("{1}'s electromagnetism wore off!",battler.pbThis))
    }
    # Telekinesis
    pbEORCountDownBattlerEffect(priority,PBEffects::Telekinesis) { |battler|
      pbDisplay(_INTL("{1} was freed from the telekinesis!",battler.pbThis))
    }
    # Heal Block
    pbEORCountDownBattlerEffect(priority,PBEffects::HealBlock) { |battler|
      pbDisplay(_INTL("{1}'s Heal Block wore off!",battler.pbThis))
    }
    # Embargo
    pbEORCountDownBattlerEffect(priority,PBEffects::Embargo) { |battler|
      pbDisplay(_INTL("{1} can use items again!",battler.pbThis))
      battler.pbItemTerrainStatBoostCheck
    }
    # Yawn
    pbEORCountDownBattlerEffect(priority,PBEffects::Yawn) { |battler|
      if battler.pbCanSleepYawn?
        PBDebug.log("[Lingering effect] #{battler.pbThis} fell asleep because of Yawn")
        battler.pbSleep
      end
    }
    # Perish Song
    perishSongUsers = []
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::PerishSong]==0
      b.effects[PBEffects::PerishSong] -= 1
      pbDisplay(_INTL("{1}'s perish count fell to {2}!",b.pbThis,b.effects[PBEffects::PerishSong]))
      if b.effects[PBEffects::PerishSong]==0
        perishSongUsers.push(b.effects[PBEffects::PerishSongUser])
        b.pbReduceHP(b.hp)
      end
      b.pbItemHPHealCheck
      b.pbFaint if b.fainted?
    end
    if perishSongUsers.length>0
      # If all remaining Pokemon fainted by a Perish Song triggered by a single side
      if (perishSongUsers.find_all { |idxBattler| opposes?(idxBattler) }.length==perishSongUsers.length) ||
         (perishSongUsers.find_all { |idxBattler| !opposes?(idxBattler) }.length==perishSongUsers.length)
        pbJudgeCheckpoint(@battlers[perishSongUsers[0]])
      end
    end
    # Check for end of battle
    if @decision>0
      pbGainExp
      return
    end
    for side in 0...2
      # Reflect
      pbEORCountDownSideEffect(side,PBEffects::Reflect,
         _INTL("{1}'s Reflect wore off!",@battlers[side].pbTeam))
      # Light Screen
      pbEORCountDownSideEffect(side,PBEffects::LightScreen,
         _INTL("{1}'s Light Screen wore off!",@battlers[side].pbTeam))
      # Safeguard
      pbEORCountDownSideEffect(side,PBEffects::Safeguard,
         _INTL("{1} is no longer protected by Safeguard!",@battlers[side].pbTeam))
      # Mist
      pbEORCountDownSideEffect(side,PBEffects::Mist,
         _INTL("{1} is no longer protected by mist!",@battlers[side].pbTeam))
      # Tailwind
      pbEORCountDownSideEffect(side,PBEffects::Tailwind,
         _INTL("{1}'s Tailwind petered out!",@battlers[side].pbTeam))
      # Lucky Chant
      pbEORCountDownSideEffect(side,PBEffects::LuckyChant,
         _INTL("{1}'s Lucky Chant wore off!",@battlers[side].pbTeam))
      # Pledge Rainbow
      pbEORCountDownSideEffect(side,PBEffects::Rainbow,
         _INTL("The rainbow on {1}'s side disappeared!",@battlers[side].pbTeam(true)))
      # Pledge Sea of Fire
      pbEORCountDownSideEffect(side,PBEffects::SeaOfFire,
         _INTL("The sea of fire around {1} disappeared!",@battlers[side].pbTeam(true)))
      # Pledge Swamp
      pbEORCountDownSideEffect(side,PBEffects::Swamp,
         _INTL("The swamp around {1} disappeared!",@battlers[side].pbTeam(true)))
      # Aurora Veil
      pbEORCountDownSideEffect(side,PBEffects::AuroraVeil,
         _INTL("{1}'s Aurora Veil wore off!",@battlers[side].pbTeam(true)))
    end
    # Trick Room
    pbEORCountDownFieldEffect(PBEffects::TrickRoom,
       _INTL("The twisted dimensions returned to normal!"))
    # Gravity
    pbEORCountDownFieldEffect(PBEffects::Gravity,
       _INTL("Gravity returned to normal!"))
    # Water Sport
    pbEORCountDownFieldEffect(PBEffects::WaterSportField,
       _INTL("The effects of Water Sport have faded."))
    # Mud Sport
    pbEORCountDownFieldEffect(PBEffects::MudSportField,
       _INTL("The effects of Mud Sport have faded."))
    # Wonder Room
    pbEORCountDownFieldEffect(PBEffects::WonderRoom,
       _INTL("Wonder Room wore off, and Defense and Sp. Def stats returned to normal!"))
    # Magic Room
    pbEORCountDownFieldEffect(PBEffects::MagicRoom,
       _INTL("Magic Room wore off, and held items' effects returned to normal!"))
    # End of terrains
    pbEORTerrain
    priority.each do |b|
      next if b.fainted?
      # Hyper Mode (Shadow Pokémon)
      if b.inHyperMode?
        if pbRandom(100)<10
          b.pokemon.hyper_mode = false
          b.pokemon.adjustHeart(-50)
          pbDisplay(_INTL("{1} came to its senses!",b.pbThis))
        else
          pbDisplay(_INTL("{1} is in Hyper Mode!",b.pbThis))
        end
      end
      # Uproar
      if b.effects[PBEffects::Uproar]>0
        b.effects[PBEffects::Uproar] -= 1
        if b.effects[PBEffects::Uproar]==0
          pbDisplay(_INTL("{1} calmed down.",b.pbThis))
        else
          pbDisplay(_INTL("{1} is making an uproar!",b.pbThis))
        end
      end
      # Slow Start's end message
      if b.effects[PBEffects::SlowStart]>0
        b.effects[PBEffects::SlowStart] -= 1
        if b.effects[PBEffects::SlowStart]==0
          pbDisplay(_INTL("{1} finally got its act together!",b.pbThis))
        end
      end
      # Bad Dreams, Moody, Speed Boost
      BattleHandlers.triggerEOREffectAbility(b.ability,b,self) if b.abilityActive?
      # Flame Orb, Sticky Barb, Toxic Orb
      BattleHandlers.triggerEOREffectItem(b.item,b,self) if b.itemActive?
      # Harvest, Pickup
      BattleHandlers.triggerEORGainItemAbility(b.ability,b,self) if b.abilityActive?
    end
    pbGainExp
    return if @decision>0
    # Form checks
    priority.each { |b| b.pbCheckForm(true) }
    # Switch Pokémon in if possible
    pbEORSwitch
    return if @decision>0
    # In battles with at least one side of size 3+, move battlers around if none
    # are near to any foes
    pbEORShiftDistantBattlers
    # Try to make Trace work, check for end of primordial weather
    priority.each { |b| b.pbContinualAbilityChecks }
    # Reset/count down battler-specific effects (no messages)
    eachBattler do |b|
      b.effects[PBEffects::BanefulBunker]    = false
      b.effects[PBEffects::Charge]           -= 1 if b.effects[PBEffects::Charge]>0
      b.effects[PBEffects::Counter]          = -1
      b.effects[PBEffects::CounterTarget]    = -1
      b.effects[PBEffects::Electrify]        = false
      b.effects[PBEffects::Endure]           = false
      b.effects[PBEffects::FirstPledge]      = 0
      b.effects[PBEffects::Flinch]           = false
      b.effects[PBEffects::FocusPunch]       = false
      b.effects[PBEffects::FollowMe]         = 0
      b.effects[PBEffects::HelpingHand]      = false
      b.effects[PBEffects::HyperBeam]        -= 1 if b.effects[PBEffects::HyperBeam]>0
      b.effects[PBEffects::KingsShield]      = false
      b.effects[PBEffects::LaserFocus]       -= 1 if b.effects[PBEffects::LaserFocus]>0
      if b.effects[PBEffects::LockOn]>0   # Also Mind Reader
        b.effects[PBEffects::LockOn]         -= 1
        b.effects[PBEffects::LockOnPos]      = -1 if b.effects[PBEffects::LockOn]==0
      end
      b.effects[PBEffects::MagicBounce]      = false
      b.effects[PBEffects::MagicCoat]        = false
      b.effects[PBEffects::MirrorCoat]       = -1
      b.effects[PBEffects::MirrorCoatTarget] = -1
      b.effects[PBEffects::Powder]           = false
      b.effects[PBEffects::Prankster]        = false
      b.effects[PBEffects::PriorityAbility]  = false
      b.effects[PBEffects::PriorityItem]     = false
      b.effects[PBEffects::Protect]          = false
      b.effects[PBEffects::RagePowder]       = false
      b.effects[PBEffects::Roost]            = false
      b.effects[PBEffects::Snatch]           = 0
      b.effects[PBEffects::SpikyShield]      = false
      b.effects[PBEffects::Spotlight]        = 0
      b.effects[PBEffects::ThroatChop]       -= 1 if b.effects[PBEffects::ThroatChop]>0
      b.lastHPLost                           = 0
      b.lastHPLostFromFoe                    = 0
      b.tookDamage                           = false
      b.tookPhysicalHit                      = false
      b.lastRoundMoveFailed                  = b.lastMoveFailed
      b.lastAttacker.clear
      b.lastFoeAttacker.clear
    end
    # Reset/count down side-specific effects (no messages)
    for side in 0...2
      @sides[side].effects[PBEffects::CraftyShield]         = false
      if !@sides[side].effects[PBEffects::EchoedVoiceUsed]
        @sides[side].effects[PBEffects::EchoedVoiceCounter] = 0
      end
      @sides[side].effects[PBEffects::EchoedVoiceUsed]      = false
      @sides[side].effects[PBEffects::MatBlock]             = false
      @sides[side].effects[PBEffects::QuickGuard]           = false
      @sides[side].effects[PBEffects::Round]                = false
      @sides[side].effects[PBEffects::WideGuard]            = false
    end
    # Reset/count down field-specific effects (no messages)
    @field.effects[PBEffects::IonDeluge]   = false
    @field.effects[PBEffects::FairyLock]   -= 1 if @field.effects[PBEffects::FairyLock]>0
    @field.effects[PBEffects::FusionBolt]  = false
    @field.effects[PBEffects::FusionFlare] = false
    @endOfRound = false
  end

  def pbEndPrimordialWeather
    oldWeather = @field.weather
    # End Primordial Sea, Desolate Land, Delta Stream
    case @field.weather
    when :HarshSun
      if !pbCheckGlobalAbility(:DESOLATELAND) && @field.weather != :HarshSun
        @field.weather = :None
        pbDisplay("The harsh sunlight faded!")
      end
    when :HeavyRain
      if !pbCheckGlobalAbility(:PRIMORDIALSEA) && @field.weather != :HeavyRain
        @field.weather = :None
        pbDisplay("The heavy rain has lifted!")
      end
    when :StrongWinds
      if !pbCheckGlobalAbility(:DELTASTREAM) && @field.weather != :StrongWinds
        @field.weather = :None
        pbDisplay("The mysterious air current has dissipated!")
      end
    end
    if @field.weather!=oldWeather
      # Check for form changes caused by the weather changing
      eachBattler { |b| b.pbCheckFormOnWeatherChange }
      # Start up the default weather
      pbStartWeather(nil,$game_screen.weather_type) if $game_screen.weather_type!= :None
    end
  end

  def pbEORWeather(priority)
    # NOTE: Primordial weather doesn't need to be checked here, because if it
    #       could wear off here, it will have worn off already.
    # Count down weather duration
    curWeather = @field.weather
    priority.each do |b|
      # Weather-related abilities
      if b.ability == :BAROMETRIC || b.ability == :ACCLIMATE
        BattleHandlers.triggerEORWeatherAbility(b.ability,curWeather,b,self)
        b.pbFaint if b.fainted?
      end
    end
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
      @field.weather= :None
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
#    when :Sun;         pbDisplay(_INTL("The sunlight is strong."))
#    when :Rain;        pbDisplay(_INTL("Rain continues to fall."))
    when :Sandstorm;   pbDisplay(_INTL("The sandstorm is raging."))
    when :Hail;        pbDisplay(_INTL("The hail is crashing down."))
#    when :HarshSun;    pbDisplay(_INTL("The sunlight is extremely harsh."))
#    when :HeavyRain;   pbDisplay(_INTL("It is raining heavily."))
#    when :StrongWinds; pbDisplay(_INTL("The wind is strong."))
    when :ShadowSky;   pbDisplay(_INTL("The shadow sky continues."));
    end
    # Effects due to weather
    curWeather = @field.weather
    priority.each do |b|
      # Weather damage
      # NOTE:
      if b.isSpecies?(:CASTFORM)
        b.pbCheckFormOnWeatherChange
      end
      b.pbFaint if b.fainted?
      if !b.isSpecies?(:ALTEMPER) && !b.isSpecies?(:FORMETEOS)
        BattleHandlers.triggerEORWeatherAbility(b.ability,curWeather,b,self)
      end
      case curWeather
      when :Sandstorm
        next if !b.takesSandstormDamage? ||  b.isSpecies?(:ALTEMPER)
        pbDisplay(_INTL("{1} is buffeted by the sandstorm!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :AcidRain
        next if !b.takesAcidRainDamage? ||  b.isSpecies?(:ALTEMPER)
        pbDisplay(_INTL("{1} is scathed by Acid Rain!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :DWind
        next if !b.takesDWindDamage? ||  b.isSpecies?(:ALTEMPER)
        pbDisplay(_INTL("{1} is whipped by the Distorted Wind!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :DustDevil
        next if !b.takesDustDevilDamage? ||  b.isSpecies?(:ALTEMPER)
        pbDisplay(_INTL("{1} is buffeted by the Dust Devil!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :Hail
        next if !b.takesHailDamage? ||  b.isSpecies?(:ALTEMPER)
        pbDisplay(_INTL("{1} is buffeted by the hail!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :Sleet
        next if !b.takesHailDamage? ||  b.isSpecies?(:ALTEMPER)
        pbDisplay(_INTL("{1} is buffeted by the Sleet!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/8,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :Starstorm
        next if !b.takesStarstormDamage? ||  b.isSpecies?(:ALTEMPER)
        pbDisplay(_INTL("{1} is hurt by the Starstorm!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :ShadowSky
        next if !b.takesShadowSkyDamage? ||  b.isSpecies?(:ALTEMPER)
        pbDisplay(_INTL("{1} is hurt by the shadow sky!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :Windy
        next if !b.pbOwnSide.effects[PBEffects::StealthRock] && b.pbOwnSide.effects[PBEffects::Spikes] == 0 && !b.pbOwnSide.effects[PBEffects::CometShards] && !b.pbOwnSide.effects[PBEffects::StickyWeb] && b.pbOwnSide.effects[PBEffects::ToxicSpikes] == 0
        if b.pbOwnSide.effects[PBEffects::StealthRock] || b.pbOpposingSide.effects[PBEffects::StealthRock]
          b.pbOwnSide.effects[PBEffects::StealthRock]      = false
          b.pbOpposingSide.effects[PBEffects::StealthRock] = false
        end
        if b.pbOwnSide.effects[PBEffects::Spikes]>0 || b.pbOpposingSide.effects[PBEffects::Spikes]>0
          b.pbOwnSide.effects[PBEffects::Spikes]      = 0
          target.pbOpposingSide.effects[PBEffects::Spikes] = 0
        end
        if b.pbOwnSide.effects[PBEffects::CometShards] || b.pbOpposingSide.effects[PBEffects::CometShards]
          b.pbOwnSide.effects[PBEffects::CometShards]      = false
          b.pbOpposingSide.effects[PBEffects::CometShards] = false
        end
        if b.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 || b.pbOpposingSide.effects[PBEffects::ToxicSpikes]>0
          b.pbOwnSide.effects[PBEffects::ToxicSpikes]      = 0
          b.pbOpposingSide.effects[PBEffects::ToxicSpikes] = 0
        end
        if b.pbOwnSide.effects[PBEffects::StickyWeb] || b.pbOpposingSide.effects[PBEffects::StickyWeb]
          b.pbOwnSide.effects[PBEffects::StickyWeb]      = false
          b.pbOpposingSide.effects[PBEffects::StickyWeb] = false
        end
      end
    end
  end
end

#=============
#Effects
#=============

module PBEffects
  GorillaTactics      = 114
  BallFetch           = 115
  LashOut             = 118
  BurningJealousy     = 119
  NoRetreat           = 120
  Obstruct            = 121
  JawLock             = 122
  JawLockUser         = 123
  TarShot             = 124
  Octolock            = 125
  OctolockUser        = 126
  BlunderPolicy       = 127
  EchoChamber         = 128
  #=
  StickyWebUser      = 22
  CometShards        = 23
  StarSap            = 129
  #=
  NeutralizingGas = 13
end
