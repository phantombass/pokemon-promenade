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

def removeAllHazards(event=nil)
  if @battle.battlers.pbOwnSide.effects[PBEffects::StealthRock] || @battle.battlers.pbOpposingSide.effects[PBEffects::StealthRock]
    @battle.battlers.pbOwnSide.effects[PBEffects::StealthRock]      = false
    @battle.battlers.pbOpposingSide.effects[PBEffects::StealthRock] = false
  end
  if @battle.battlers.pbOwnSide.effects[PBEffects::Spikes]>0 || @battle.battlers.pbOpposingSide.effects[PBEffects::Spikes]>0
    @battle.battlers.pbOwnSide.effects[PBEffects::Spikes]      = 0
    @battle.battlers.pbOpposingSide.effects[PBEffects::Spikes] = 0
  end
  if @battle.battlers.pbOwnSide.effects[PBEffects::CometShards] || @battle.battlers.pbOpposingSide.effects[PBEffects::CometShards]
    @battle.battlers.pbOwnSide.effects[PBEffects::CometShards]      = false
    @battle.battlers.pbOpposingSide.effects[PBEffects::CometShards] = false
  end
  if @battle.battlers.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 || @battle.battlers.pbOpposingSide.effects[PBEffects::ToxicSpikes]>0
    @battle.battlers.pbOwnSide.effects[PBEffects::ToxicSpikes]      = 0
    @battle.battlers.pbOpposingSide.effects[PBEffects::ToxicSpikes] = 0
  end
  if @battle.battlers.pbOwnSide.effects[PBEffects::StickyWeb] || @battle.battlers.pbOpposingSide.effects[PBEffects::StickyWeb]
    @battle.battlers.pbOwnSide.effects[PBEffects::StickyWeb]      = false
    @battle.battlers.pbOpposingSide.effects[PBEffects::StickyWeb] = false
  end
end
