def poisonAllPokemon(event=nil)
    for pkmn in $Trainer.ablePokemonParty
       next if pkmn.hasType?(:POISON)  || pkmn.hasType?(:STEEL) ||
          pkmn.hasAbility?(:COMATOSE)  || pkmn.hasAbility?(:SHIELDSDOWN) || pkmn.hasAbility?(:IMMUNITY)
          pkmn.status!=0
       pkmn.status = :POISON
       pkmn.statusCount = 1
     end
end

def paralyzeAllPokemon(event=nil)
    for pkmn in $Trainer.ablePokemonParty
       next if pkmn.hasType?(:ELECTRIC) ||
          pkmn.hasAbility?(:COMATOSE)  || pkmn.hasAbility?(:SHIELDSDOWN) || pkmn.hasAbility?(:LIMBER)
          pkmn.status!=0
       pkmn.status = :PARALYSIS
     end
end

def burnAllPokemon(event=nil)
    for pkmn in $Trainer.ablePokemonParty
       next if pkmn.hasType?(:FIRE) ||
          pkmn.hasAbility?(:COMATOSE)  || pkmn.hasAbility?(:SHIELDSDOWN) || pkmn.hasAbility?(:WATERBUBBLE) || pkmn.hasAbility?(:WATERVEIL)
          pkmn.status!=0
       pkmn.status = :BURN
     end
end

module EliteBattle
  TRAINER_SPRITE_SCALE = 1
  REPLACE_MISSING_ANIM = true
end

module EnvironmentEBDX
  GUARDIAN = {
    "backdrop" => "Sapphire",
    "vacuum" => "dark006",
    "img001" => {
      :scrolling => true, :vertical => true, :speed => 1,
      :bitmap => "decor003a",
      :oy => 180, :y => 90, :flat => true
    }, "img002" => {
      :bitmap => "shade",
      :oy => 100, :y => 98, :flat => false
    }, "img003" => {
      :scrolling => true, :speed => 16,
      :bitmap => "decor005",
      :oy => 0, :y => 4, :z => 4, :flat => true
    }, "img004" => {
      :scrolling => true, :speed => 16, :direction => -1,
      :bitmap => "decor006",
      :oy => 0, :z => 4, :flat => true
    }, "img005" => {
      :scrolling => true, :speed => 0.5,
      :bitmap => "base001a",
      :oy => 0, :y => 122, :z => 1, :flat => true
    }, "img006" => {
      :bitmap => "pillars",
      :oy => 100, :x => 96, :y => 98, :flat => false, :zoom => 0.5
    }
  }
end
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
end

EliteBattle.defineMoveAnimation(:STELLARWIND) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}
  rndx = []; prndx = []
  rndy = []; prndy = []
  rangl = []
  dx = []
  dy = []
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb423")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].z = @targetSprite.z + 1
    rndx.push(rand(256)); prndx.push(rand(72))
    rndy.push(rand(256)); prndy.push(rand(72))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  shake = 4
  # start animation
  @vector.set(vector2)
  pbSEPlay("Anim/Whirlwind")
  for i in 0...72
    ax, ay = @userSprite.getCenter
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...128
      next if j>(i*2)
      if !fp["#{j}"].visible
        dx[j] = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
        fp["#{j}"].visible = true
      end
      x0 = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
      y0 = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
      x2 = cx - 128*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 128*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].angle += rangl[j]*2
      nextx = fp["#{j}"].x
      nexty = fp["#{j}"].y
      if !@targetIsPlayer
        fp["#{j}"].opacity -= 51 if nextx > cx && nexty < cy
      else
        fp["#{j}"].opacity -= 51 if nextx < cx && nexty > cy
      end
    end
    if i >= 64
  #    @targetSprite.x += 64*(@targetIsPlayer ? -1 : 1)
    elsif i >= 52
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @vector.set(vector) if i == 16
    @vector.inc = 0.1 if i == 16
    @scene.wait(1,i < 64)
  end
#  @targetSprite.visible = false
#  @targetSprite.hidden = true
#  @targetSprite.ox = @targetSprite.bitmap.width/2
  pbDisposeSpriteHash(fp)
  @vector.reset
  @vector.inc = 0.2
  @scene.wait(16,true)
end
EliteBattle.defineMoveAnimation(:TIMEWIND) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}
  rndx = []; prndx = []
  rndy = []; prndy = []
  rangl = []
  dx = []
  dy = []
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb423")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].z = @targetSprite.z + 1
    rndx.push(rand(256)); prndx.push(rand(72))
    rndy.push(rand(256)); prndy.push(rand(72))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  shake = 4
  # start animation
  @vector.set(vector2)
  pbSEPlay("Anim/Whirlwind")
  for i in 0...72
    ax, ay = @userSprite.getCenter
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...128
      next if j>(i*2)
      if !fp["#{j}"].visible
        dx[j] = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
        fp["#{j}"].visible = true
      end
      x0 = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
      y0 = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
      x2 = cx - 128*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 128*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].angle += rangl[j]*2
      nextx = fp["#{j}"].x
      nexty = fp["#{j}"].y
      if !@targetIsPlayer
        fp["#{j}"].opacity -= 51 if nextx > cx && nexty < cy
      else
        fp["#{j}"].opacity -= 51 if nextx < cx && nexty > cy
      end
    end
    if i >= 64
  #    @targetSprite.x += 64*(@targetIsPlayer ? -1 : 1)
    elsif i >= 52
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @vector.set(vector) if i == 16
    @vector.inc = 0.1 if i == 16
    @scene.wait(1,i < 64)
  end
#  @targetSprite.visible = false
#  @targetSprite.hidden = true
#  @targetSprite.ox = @targetSprite.bitmap.width/2
  pbDisposeSpriteHash(fp)
  @vector.reset
  @vector.inc = 0.2
  @scene.wait(16,true)
end

#=====================
#
#Mid Battle Scripts
#
#=====================

module BattleScripts
  BORIS = {
    "lastOpp" => proc do
      @scene.pbTrainerSpeak("Don't think this is over just yet, \\PN!")
      @sprites["battlebg"].reconfigure(:SKY, :DISTORTION)
      @scene.wait(16, false)
      @battle.field.weather = :Windy
      @battle.field.weatherDuration = 8
      @scene.pbDisplay("The wind picked back up!")
      @battle.removeAllHazards
    end,
    "turnStart0" => "Let's see just how prepared you are!"
  }

  SETH = {
    "lastOpp" => proc do
      @scene.pbTrainerSpeak("Hoho! Just see what trickery we have for you!")
      @sprites["battlebg"].reconfigure(:DARKNESS, :DISTORTION)
      @battle.field.weather = :Eclipse
      @battle.field.weatherDuration = 8
      @scene.pbDisplay("The darkness returned!")
      @scene.wait(16, false)
      EliteBattle.playCommonAnimation(:POISON,@scene,0)
      @battle.battlers[0].status = :POISON
      @battle.battlers[0].effects[PBEffects::Toxic]
      poisonAllPokemon(nil)
      @scene.pbDisplay("Seth's underhanded tactics badly poisoned \\PN's party!")

  end,
  "turnStart0" => "Let's get this madness started!"
  }

  OZZY = {
    "lastOpp" => proc do
      @scene.pbTrainerSpeak("This battle may be saved yet! Observe, \\PN!")
      @sprites["battlebg"].reconfigure(:CAVE, :DISTORTION)
      @battle.pbAnimation(getID(GameData::Move,:SANDSTORM),@battle.battlers[1],@battle.battlers[0])
      @battle.field.weather = :Sandstorm
      @battle.field.weatherDuration = 8
      @scene.pbDisplay("The sandstorm resurged!")
      @scene.wait(16,false)
      if @battle.battlers[0].pbOwnSide.effects[PBEffects::StealthRock] == false
        @battle.pbAnimation(getID(GameData::Move,:STEALTHROCK),@battle.battlers[1],@battle.battlers[0])
        @battle.battlers[0].pbOwnSide.effects[PBEffects::StealthRock] = true
        @scene.pbDisplay("Ozzy set Stealth Rocks on \\PN's side!")
      end
    end,
    "turnStart0" => "Let's see just what you're made of!"
    }

  RALPH = {
    "lastOpp" => proc do
              @scene.pbTrainerSpeak("May the sun rise on our victory!")
              @sprites["battlebg"].reconfigure(:MAGMA, :DISTORTION)
              @battle.field.defaultWeather = :HarshSun
              @battle.field.weather = :HarshSun
              @scene.pbDisplay("The sun returned and intensified!")
              @scene.wait(16,false)
              EliteBattle.playCommonAnimation(:BURN,@scene,0)
              @battle.battlers[0].status = :BURN
              burnAllPokemon(nil)
              @scene.pbDisplay("The intense sun left \\PN's team burned!")
            end,
    "turnStart0" => "Let's get this place heated up!"
            }

  DELTA = {
    "lastOpp" => proc do
              @scene.pbTrainerSpeak("It's time for the tidal wave to come crashing down!")
              @sprites["battlebg"].reconfigure(:UNDERWATER, :DISTORTION)
              @battle.field.defaultWeather = :HeavyRain
              @battle.field.weather = :HeavyRain
              @scene.pbDisplay("The rain returned and intensified!")
              @scene.wait(16,false)
              if @battle.battlers[0].pbOwnSide.effects[PBEffects::StealthRock] == false
                @battle.pbAnimation(GameData::Move.get(:STEALTHROCK).id,@battle.battlers[1],@battle.battlers[0])
                @battle.battlers[0].pbOwnSide.effects[PBEffects::StealthRock] = true
                @scene.pbDisplay("Ozzy set Stealth Rocks on \\PN's side!")
              end
            end,
    "turnStart0" => "Come at me with all you've got!"
            }

  SEBASTIAN = {
    "lastOpp" => proc do
              @scene.pbTrainerSpeak("It's time for the curtain call!")
              @sprites["battlebg"].reconfigure(:STAGE, :DISTORTION)
              @battle.field.weather = :Reverb
              @battle.field.weatherDuration = 8
              @scene.pbDisplay("The Echo Chamber returned!")
              @scene.wait(16,false)
              @battle.pbAnimation(GameData::Move.get(:SPIKES).id,@battle.battlers[1],@battle.battlers[0])
              @battle.battlers[0].pbOwnSide.effects[PBEffects::Spikes] = 3
              @scene.pbDisplay("The reverberation shook 3 layers of Spikes onto \\PN's side!")
            end,
    "turnStart0" => "Come! Let us make a masterpiece!"
              }
  ANN = {
        "lastOpp" => proc do
          @scene.pbTrainerSpeak("...let the shadows come to my side.")
          @sprites["battlebg"].reconfigure(:DARKNESS, :DISTORTION)
          @battle.field.weather = :TimeWarp
          @battle.field.weatherDuration = 8
          @scene.pbDisplay("Time stopped again!")
          @scene.wait(16,false)
          @battlers[1].pbRaiseStatStageBasic(:DEFENSE,1)
          @battlers[1].pbRaiseStatStageBasic(:SPECIAL_DEFENSE,1)
          @scene.pbDisplay("Ann's Pokémon boosted its Defense and Special Defense!")
          @scene.wait(16,false)
          @battle.pbAnimation(GameData::Move.get(:SPIKES).id,@battle.battlers[1],@battle.battlers[0])
          @battle.battlers[0].pbOwnSide.effects[PBEffects::ToxicSpikes] = 2
          @scene.pbDisplay("The shadows managed to sneak 2 layers of Toxic Spikes onto \\PN's side!")
        end,
        "turnStart0" => "...let's begin."
      }

  PHOEBE = {
    "lastOpp" => proc do
              @scene.pbTrainerSpeak("I haven't have a battle this intense in a long time!")
              @battle.field.weather = :Fog
              @battle.field.weatherDuration = 8
              @scene.pbDisplay("Fog covers the field!")
              @scene.wait(16,false)
              @battlers[1].pbRaiseStatStageBasic(:DEFENSE,1)
              @battlers[1].pbRaiseStatStageBasic(:SPECIAL_DEFENSE,1)
              @scene.pbDisplay("Phoebe's Pokémon boosted its Defense and Special Defense!")
              @scene.wait(16,false)
              @battle.pbAnimation(GameData::Move.get(:STEALTHROCK).id,@battle.battlers[1],@battle.battlers[0])
              @battle.battlers[0].pbOwnSide.effects[PBEffects::StealthRock] = true
              @scene.wait(16,false)
              @battle.pbAnimation(GameData::Move.get(:SPIKES).id,@battle.battlers[1],@battle.battlers[0])
              @battle.battlers[0].pbOwnSide.effects[PBEffects::Spikes] = 3
              @scene.pbDisplay("Phoebe launched Stealth Rocks and 3 layers of Spikes onto \\PN's side!")
            end,
            "turnStart0" => "I'm excited to have my first Gym Battle!"
            }
#============================
# Temple Guardian Battles
#============================
MARIE = {
    "turnStart0" => proc do
              @scene.pbTrainerSpeak("Be prepared for the terrible sound of defeat!")
              @battle.field.weather = :Reverb
              @battle.field.weatherDuration = 8
              @scene.pbDisplay("An echo chamber surrounds the field!")
              @scene.wait(16,false)
              if battle.battlers[0].pbOwnSide.effects[PBEffects::CometShards] == nil
                @battle.pbAnimation(GameData::Move.get(:STEALTHROCK).id,@battle.battlers[1],@battle.battlers[0])
                @battle.battlers[0].pbOwnSide.effects[PBEffects::CometShards] = true
                @scene.pbDisplay("Marie set Comet Shards on \\PN's side!")
              end
            end,

"lowHPOpp" => proc do
                @scene.pbTrainerSpeak("Don't think I've given up so soon!")
                @scene.wait(16,false)
                EliteBattle.playCommonAnimation(:HEALTHUP,@scene,0)
                @battle.battlers[1].pbRecoverHP(@battle.battlers[1].totalhp/3)
                @scene.pbDisplay("Meritempo tried its hardest for Marie!")
                @scene.pbDisplay("Meritempo recovered some HP!")
                @scene.wait(16,false)
                @battlers[1].pbRaiseStatStageBasic(:DEFENSE,1)
                @battlers[1].pbRaiseStatStageBasic(:SPEED,1)
                @scene.wait(16,false)
                @scene.pbDisplay("Meritempo's Defense and Speed rose!")
              end
              }
BURT = {
  "turnStart0" => proc do
                    @scene.pbTrainerSpeak("It takes more than just power to win some battles!")
                    @battle.field.weather = :Humid
                    @battle.field.weatherDuration = 8
                    @scene.pbDisplay("The air becomes humid!")
                    @scene.wait(16,false)
                    if @battle.battlers[0].pbOwnSide.effects[PBEffects::ToxicSpikes] == 0
                      @battle.pbAnimation(GameData::Move.get(:SPIKES).id,@battle.battlers[1],@battle.battlers[0])
                      @battle.battlers[0].pbOwnSide.effects[PBEffects::ToxicSpikes] = 2
                      @scene.pbDisplay("Burt set Toxic Spikes on \\PN's side!")
                    end
                  end,
"lowHPOpp" => proc do
                    @scene.pbTrainerSpeak("I can't let you break through yet. We've just begun!")
                    @scene.wait(16,false)
                    EliteBattle.playCommonAnimation(:HEALTHUP,@scene,0)
                    @battle.battlers[1].pbRecoverHP(@battle.battlers[1].totalhp/3)
                    @battle.battlers[1].status = 0
                    @scene.pbDisplay("Centisepa tried its hardest for Burt!")
                    @scene.pbDisplay("Centisepa recovered some HP and cured its status!")
                    @scene.wait(16,false)
                    @battlers[1].pbRaiseStatStageBasic(:DEFENSE,1)
                    @battlers[1].pbRaiseStatStageBasic(:SPDEF,1,)
                    @scene.wait(16,false)
                    @scene.pbDisplay("Centisepa's Defense and Special Defense rose!")
                  end
                  }

TIM = {
  "turnStart0" => proc do
                    @scene.pbTrainerSpeak("The wind is at our backs!")
                    @battle.field.defaultWeather = :HeavyRain
                    @battle.field.weather = :HeavyRain
                    @scene.pbDisplay("Rain comes crashing down!")
                    @scene.wait(16,false)
                    if battle.battlers[0].pbOwnSide.effects[PBEffects::Spikes] == 0
                      @battle.pbAnimation(GameData::Move.get(:SPIKES).id,@battle.battlers[1],@battle.battlers[0])
                      @battle.battlers[0].pbOwnSide.effects[PBEffects::Spikes] = 1
                      @scene.pbDisplay("Tim set a layer of Spikes on \\PN's side!")
                    end
                  end,
  "lowHPOpp" => proc do
                    @scene.pbTrainerSpeak("This storm could turn! Time to turn it up!")
                    @scene.wait(16,false)
                    EliteBattle.playCommonAnimation(:HEALTHUP,@scene,0)
                    @battle.battlers[1].pbRecoverHP(@battle.battlers[1].totalhp/2)
                    @battle.battlers[1].status = 0
                    @scene.pbDisplay("Orrustorm tried its hardest for Tim!")
                    @scene.pbDisplay("Orrustorm recovered some HP and cured its status!")
                    @scene.wait(16,false)
                    @battlers[1].pbRaiseStatStageBasic(:SPEED,1)
                    @battlers[1].pbRaiseStatStageBasic(:SPATK,1)
                    @scene.wait(16,false)
                    pbMessage("Orrustorm's Speed and Special Attack rose!")
                    @scene.wait(16,false)
                    @battle.pbAnimation(GameData::Move.get(:AURORAVEIL).id,@battle.battlers[1],@battle.battlers[1])
                    @battle.battlers[1].pbOwnSide.effects[PBEffects::AuroraVeil] = 8
                    @scene.pbDisplay("Tim set up a protective veil of light!")
                  end
      }

ANDY = {
    "turnStart0" => proc do
                  @scene.pbTrainerSpeak("The end shall come quickly...")
                  @battle.field.weather = :TimeWarp
                  @battle.field.weatherDuration = 8
                  @scene.pbDisplay("Time stood still!")
                  @scene.wait(16,false)
                  @battle.pbAnimation(GameData::Move.get(:STEALTHROCK),@battle.battlers[1],@battle.battlers[0])
                  @battle.battlers[0].pbOwnSide.effects[PBEffects::StealthRock] = true
                  @scene.pbDisplay("Andy set up Stealth Rocks on \\PN's side!")
                  @scene.wait(16,false)
                  @battle.pbAnimation(GameData::Move.get(:AURORAVEIL).id,@battle.battlers[1],@battle.battlers[1])
                  @battle.battlers[1].pbOwnSide.effects[PBEffects::AuroraVeil] = 5
                  @scene.pbDisplay("Andy set up a protective veil of light!")
                end,
      "lowHPOpp" => proc do
                  @scene.pbTrainerSpeak("This storm could turn! Time to turn it up!")
                  @scene.wait(16,false)
                  EliteBattle.playCommonAnimation(:HEALTHUP,@scene,0)
                  @battle.battlers[1].pbRecoverHP(@battle.battlers[1].totalhp/3)
                  @battle.battlers[1].status = 0
                  @scene.pbDisplay("Caninpu tried its hardest for Andy!")
                  @scene.pbDisplay("Caninpu recovered some HP and cured its status!")
                  @scene.wait(16,false)
                  @battle.battlers[1].pbRaiseStatStageBasic(:SPEED,2)
                  @scene.wait(16,false)
                  @scene.pbDisplay("Caninpu's Speed sharply rose!")
                  @scene.wait(16,false)
                  @battle.battlers[0].effects[PBEffects::Trapping] = 5
                  @scene.pbDisplay("Andy trapped your Pokémon!")
                end
                }

OWEN = {
    "turnStart0" => proc do
                  @scene.pbTrainerSpeak("I've been looking forward to this battle!")
                  @battle.field.weather = :Rain
                  @battle.field.weatherDuration = 8
                  @scene.pbDisplay("Rain began to fall!")
                  @scene.wait(16,false)
                  @battle.field.terrain = PBBattleTerrains::Psychic
                  @battle.field.terrainDuration = 5
                  @scene.pbDisplay("The battlefield got weird!")
                  @scene.wait(16,false)
                  @battle.pbAnimation(GameData::Move.get(:STEALTHROCK),@battle.battlers[1],@battle.battlers[0])
                  @battle.battlers[0].pbOwnSide.effects[PBEffects::CometShards] = true
                  @scene.pbDisplay("Owen set up Comet Shards on \\PN's side!")
                  @scene.wait(16,false)
                  @battle.pbAnimation(GameData::Move.get(:AURORAVEIL).id,@battle.battlers[1],@battle.battlers[1])
                  @battle.battlers[1].pbOwnSide.effects[PBEffects::AuroraVeil] = 5
                  @scene.pbDisplay("Owen set up a protective veil of light!")

                end,
    "lowHPOpp" => proc do
                  @scene.pbTrainerSpeak("This is getting really good! Let's finish this out!")
                  @scene.wait(16,false)
                  EliteBattle.playCommonAnimation(:HEALTHUP,@scene,0)
                  @battle.battlers[1].pbRecoverHP(battle.battlers[0].totalhp/2)
                  @battle.battlers[1].status = 0
                  @scene.pbDisplay("Sobekodile tried its hardest for Owen!")
                  @scene.pbDisplay("Sobekodile recovered some HP and cured its status!")
                  @scene.wait(16,false)
                  @battlers[1].pbRaiseStatStageBasic(:SPEED,1)
                  @scene.wait(16,false)
                  @scene.pbDisplay("Sobekodile's Speed rose!")
                  @scene.wait(16,false)
                  EliteBattle.playCommonAnimation(:POISON,@scene,0)
                  @battle.battlers[0].status = :POISON
                  @battle.battlers[0].effects[PBEffects::Toxic]
                  poisonAllPokemon(nil)
                  @scene.pbDisplay("Owen badly poisoned your party!")
                }

TARA1 = {
  "turnStart0" => proc do
                  @scene.pbTrainerSpeak("Well child, let's see how you fare!")
                  @battle.field.weather = :Starstorm
                  @battle.field.weatherDuration = 8
                  @scene.pbDisplay("Tara summoned a Starstorm!")
                  @scene.wait(16,false)
                  @battle.pbAnimation(getID(PBMoves,:STEALTHROCK),battle.battlers[1],battle.battlers[0])
                  @battle.battlers[0].pbOwnSide.effects[PBEffects::CometShards] = true
                  @scene.pbDisplay("Tara set up Comet Shards on \\PN's side!")
                  @scene.wait(16,false)
                  @battle.pbAnimation(GameData::Move.get(:AURORAVEIL).id,@battle.battlers[1],@battle.battlers[1])
                  @battle.battlers[1].pbOwnSide.effects[PBEffects::AuroraVeil] = 5
                  @scene.pbDisplay("Tara set up a protective veil of light!")
                end,
"lowHPOpp" => proc do
                  @scene.pbTrainerSpeak("Child, you're pushing me to my limits!")
                  @scene.wait(16,false)
                  EliteBattle.playCommonAnimation(:HEALTHUP,@scene,0)
                  @battle.battlers[1].pbRecoverHP(battle.battlers[0].totalhp/3)
                  @battle.battlers[1].status = 0
                  @scene.pbDisplay("Osiram tried its hardest for Tara!")
                  @scene.pbDisplay("Osiram recovered some HP and cured its status!")
                  @scene.wait(16,false)
                  @battlers[1].pbRaiseStatStageBasic(:ATTACK,1)
                  @scene.wait(16,false)
                  @scene.pbDisplay("Osiram's Attack rose!")
                  @scene.wait(16,false)
                  EliteBattle.playCommonAnimation(:POISON,@scene,0)
                  @battle.battlers[0].status = :POISON
                  @battle.battlers[0].effects[PBEffects::Toxic]
                  poisonAllPokemon(nil)
                  @scene.pbDisplay("Tara badly poisoned your party!")
                end
                }
#
  RIVAL1 = { "turnStart0" => "I'm so stoked to see your Pokémon!",
             "lowHPOpp" => "Whoa, that little guy is strong!"
           }
  RIVAL2 = { "turnStart0" => "Let's see what kind of team you're rocking!",
            "lowHPOpp" => "Oh this is gonna be a good battle!"
           }
end
