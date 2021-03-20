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
