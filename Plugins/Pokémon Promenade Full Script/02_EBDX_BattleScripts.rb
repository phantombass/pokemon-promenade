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
  TEMPLE = {
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

#=====================
#Move Animations
#=====================
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
EliteBattle.defineMoveAnimation(:BOOMBURST) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}
  rndx = []; prndx = []
  rndy = []; prndy = []
  rangl = []
  dx = []
  dy = []
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb093_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound1")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].z = 50
    rndx.push(rand(256)); prndx.push(rand(72))
    rndy.push(rand(256)); prndy.push(rand(72))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound2")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].z = 50
    rndx.push(rand(256)); prndx.push(rand(72))
    rndy.push(rand(256)); prndy.push(rand(72))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb191_3")
    fp["#{i}s"].ox = fp["#{i}s"].bitmap.width/2
    fp["#{i}s"].oy = fp["#{i}s"].bitmap.height + 8*factor
    fp["#{i}s"].angle = rand(360)
    r = rand(2)
    fp["#{i}s"].zoom_x = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].zoom_y = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].visible = false
    fp["#{i}s"].opacity = 255 - rand(101)
    fp["#{i}s"].z = 50
  end
  shake = 4
  k = 0
  # start animation
  @vector.set(vector2)
  @sprites["battlebg"].defocus
  for i in 0...30
    if i < 10
      fp["bg"].opacity += 25.5
    elsif i < 20
      fp["bg"].color.alpha -= 25.5
    end
    pbSEPlay("EBDX/Anim/grass2") if i == 20
    fp["bg"].update
    @scene.wait(1,true)
  end
  pbSEPlay("EBDX/Anim/wind1",90)
  for i in 0...96
    pbSEPlay("EBDX/Anim/grass1",60) if i%3==0 && i < 64
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
      nextx = fp["#{j}"].x# + (x2 - x0)*0.1
      nexty = fp["#{j}"].y# + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].opacity -= 51 if nextx > cx && nexty < cy
      else
        fp["#{j}"].opacity -= 51 if nextx < cx && nexty > cy
      end
    end
    if i >= 64
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    for m in 0...8
      fp["#{m}s"].visible = true
      fp["#{m}s"].opacity -= 12
      fp["#{m}s"].oy +=6*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].x, fp["#{m}s"].y = @userSprite.getCenter
    end
    #pbSEPlay("Anim/Comet Punch") if i == 64
    fp["bg"].update
    @vector.set(vector) if i == 32
    @vector.inc = 0.1 if i == 32
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  for i in 0...20
    @targetSprite.still
    if i < 10
      fp["bg"].color.alpha += 25.5
    else
      fp["bg"].opacity -= 25.5
    end
    fp["bg"].update
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:HYPERVOICE) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}
  rndx = []; prndx = []
  rndy = []; prndy = []
  rangl = []
  dx = []
  dy = []
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound1")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].z = 50
    rndx.push(rand(256)); prndx.push(rand(72))
    rndy.push(rand(256)); prndy.push(rand(72))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound2")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].z = 50
    rndx.push(rand(256)); prndx.push(rand(72))
    rndy.push(rand(256)); prndy.push(rand(72))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb191_3")
    fp["#{i}s"].ox = fp["#{i}s"].bitmap.width/2
    fp["#{i}s"].oy = fp["#{i}s"].bitmap.height + 8*factor
    fp["#{i}s"].angle = rand(360)
    r = rand(2)
    fp["#{i}s"].zoom_x = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].zoom_y = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].visible = false
    fp["#{i}s"].opacity = 255 - rand(101)
    fp["#{i}s"].z = 50
  end
  shake = 4
  k = 0
  # start animation
  @vector.set(vector2)
  @sprites["battlebg"].defocus
  for i in 0...30
    pbSEPlay("EBDX/Anim/grass2") if i == 20
    @scene.wait(1,true)
  end
  pbSEPlay("EBDX/Anim/wind1",90)
  for i in 0...96
    pbSEPlay("EBDX/Anim/grass1",60) if i%3==0 && i < 64
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
      nextx = fp["#{j}"].x# + (x2 - x0)*0.1
      nexty = fp["#{j}"].y# + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].opacity -= 51 if nextx > cx && nexty < cy
      else
        fp["#{j}"].opacity -= 51 if nextx < cx && nexty > cy
      end
    end
    if i >= 64
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    for m in 0...8
      fp["#{m}s"].visible = true
      fp["#{m}s"].opacity -= 12
      fp["#{m}s"].oy +=6*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].x, fp["#{m}s"].y = @userSprite.getCenter
    end
    #pbSEPlay("Anim/Comet Punch") if i == 64
    @vector.set(vector) if i == 32
    @vector.inc = 0.1 if i == 32
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:CINDERRUSH) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  frame = []
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  for j in 0...16
    fp["f#{j}"] = Sprite.new(@viewport)
    fp["f#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129")
    fp["f#{j}"].ox = fp["f#{j}"].bitmap.width/2
    fp["f#{j}"].oy = fp["f#{j}"].bitmap.height/2
    fp["f#{j}"].x = @userSprite.x - 64*@userSprite.zoom_x + rand(128)*@userSprite.zoom_x
    fp["f#{j}"].y = @userSprite.y - 16*@userSprite.zoom_y + rand(32)*@userSprite.zoom_y
    fp["f#{j}"].visible = false
    z = [1,0.75,0.5,0.8][rand(4)]
    fp["f#{j}"].zoom_x = @userSprite.zoom_x*z
    fp["f#{j}"].zoom_y = @userSprite.zoom_y*z
    fp["f#{j}"].z = @userSprite.z + 1
    frame.push(0)
  end
  # animation start
  pbSEPlay("EBDX/Anim/fire2",60)
  pbSEPlay("EBDX/Anim/fire3",60)
  @sprites["battlebg"].defocus
  for i in 0...48
    for j in 0...16
      next if j>(i/2)
      fp["f#{j}"].visible = true
      fp["f#{j}"].y -= 8*@userSprite.zoom_y
      fp["f#{j}"].opacity -= 32 if frame[j] >= 8
      frame[j] += 1
    end
    fp["bg"].opacity += 8 if i >= 32
    @scene.wait(1,true)
  end
  pbSEPlay("EBDX/Anim/fire4",80)
  @vector.set(vector)
  @scene.wait(16,true)
  cx, cy = @targetSprite.getCenter
  fp["flare"] = Sprite.new(@viewport)
  fp["flare"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129_2")
  fp["flare"].ox = fp["flare"].bitmap.width/2
  fp["flare"].oy = fp["flare"].bitmap.height/2
  fp["flare"].x = cx
  fp["flare"].y = cy
  fp["flare"].zoom_x = @targetSprite.zoom_x
  fp["flare"].zoom_y = @targetSprite.zoom_y
  fp["flare"].z = @targetSprite.z
  fp["flare"].opacity = 0
  for j in 0...3
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129_3")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    fp["#{j}"].x = cx - 32 + rand(64)
    fp["#{j}"].y = cy - 32 + rand(64)
    fp["#{j}"].z = @targetSprite.z + 1
    fp["#{j}"].visible = false
    fp["#{j}"].zoom_x = @targetSprite.zoom_x
    fp["#{j}"].zoom_y = @targetSprite.zoom_y
  end
  for m in 0...12
    fp["p#{m}"] = Sprite.new(@viewport)
    fp["p#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129_4")
    fp["p#{m}"].ox = fp["p#{m}"].bitmap.width/2
    fp["p#{m}"].oy = fp["p#{m}"].bitmap.height/2
    fp["p#{m}"].x = cx - 48 + rand(96)
    fp["p#{m}"].y = cy - 48 + rand(96)
    fp["p#{m}"].z = @targetSprite.z + 2
    fp["p#{m}"].visible = false
    fp["p#{m}"].zoom_x = @targetSprite.zoom_x
    fp["p#{m}"].zoom_y = @targetSprite.zoom_y
  end
  @targetSprite.color = Color.new(0,0,0,0)
  for i in 0...64
    fp["bg"].opacity += 16 if fp["bg"].opacity < 255 && i < 32
    fp["bg"].color.alpha -= 32 if fp["bg"].color.alpha > 0
    fp["flare"].opacity += 32*(i < 8 ? 1 : -1)
    fp["flare"].angle += 32
    pbSEPlay("EBDX/Anim/fire1",80) if i == 8
    for j in 0...3
      next if i < 12
      next if j>(i-12)/4
      fp["#{j}"].visible = true
      fp["#{j}"].opacity -= 16
      fp["#{j}"].angle += 16
      fp["#{j}"].zoom_x += 0.1
      fp["#{j}"].zoom_y += 0.1
    end
    for m in 0...12
      next if i < 6
      next if m>(i-6)
      fp["p#{m}"].visible = true
      fp["p#{m}"].opacity -= 16
      fp["p#{m}"].y -= 8
    end
    if i >= 48
      fp["bg"].opacity -= 16
      @targetSprite.color.alpha -= 16
    else
      @targetSprite.color.alpha += 16 if @targetSprite.color.alpha < 192
    end
    @targetSprite.anim = true
    @scene.wait
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:SOLARWINGS) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  frame = []
  fp = {}
  for j in 0...16
    fp["f#{j}"] = Sprite.new(@viewport)
    fp["f#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129")
    fp["f#{j}"].ox = fp["f#{j}"].bitmap.width/2
    fp["f#{j}"].oy = fp["f#{j}"].bitmap.height/2
    fp["f#{j}"].x = @userSprite.x - 64*@userSprite.zoom_x + rand(128)*@userSprite.zoom_x
    fp["f#{j}"].y = @userSprite.y - 16*@userSprite.zoom_y + rand(32)*@userSprite.zoom_y
    fp["f#{j}"].visible = false
    z = [1,0.75,0.5,0.8][rand(4)]
    fp["f#{j}"].zoom_x = @userSprite.zoom_x*z
    fp["f#{j}"].zoom_y = @userSprite.zoom_y*z
    fp["f#{j}"].z = @userSprite.z + 1
    frame.push(0)
  end
  # animation start
  pbSEPlay("EBDX/Anim/fire2",60)
  pbSEPlay("EBDX/Anim/fire3",60)
  @sprites["battlebg"].defocus
  for i in 0...48
    for j in 0...16
      next if j>(i/2)
      fp["f#{j}"].visible = true
      fp["f#{j}"].y -= 8*@userSprite.zoom_y
      fp["f#{j}"].opacity -= 32 if frame[j] >= 8
      frame[j] += 1
    end
    @scene.wait(1,true)
  end
  pbSEPlay("EBDX/Anim/fire4",80)
  @vector.set(vector)
  @scene.wait(16,true)
  cx, cy = @targetSprite.getCenter
  fp["flare"] = Sprite.new(@viewport)
  fp["flare"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129_2")
  fp["flare"].ox = fp["flare"].bitmap.width/2
  fp["flare"].oy = fp["flare"].bitmap.height/2
  fp["flare"].x = cx
  fp["flare"].y = cy
  fp["flare"].zoom_x = @targetSprite.zoom_x
  fp["flare"].zoom_y = @targetSprite.zoom_y
  fp["flare"].z = @targetSprite.z
  fp["flare"].opacity = 0
  for j in 0...3
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129_3")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    fp["#{j}"].x = cx - 32 + rand(64)
    fp["#{j}"].y = cy - 32 + rand(64)
    fp["#{j}"].z = @targetSprite.z + 1
    fp["#{j}"].visible = false
    fp["#{j}"].zoom_x = @targetSprite.zoom_x
    fp["#{j}"].zoom_y = @targetSprite.zoom_y
  end
  for m in 0...12
    fp["p#{m}"] = Sprite.new(@viewport)
    fp["p#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129_4")
    fp["p#{m}"].ox = fp["p#{m}"].bitmap.width/2
    fp["p#{m}"].oy = fp["p#{m}"].bitmap.height/2
    fp["p#{m}"].x = cx - 48 + rand(96)
    fp["p#{m}"].y = cy - 48 + rand(96)
    fp["p#{m}"].z = @targetSprite.z + 2
    fp["p#{m}"].visible = false
    fp["p#{m}"].zoom_x = @targetSprite.zoom_x
    fp["p#{m}"].zoom_y = @targetSprite.zoom_y
  end
  @targetSprite.color = Color.new(0,0,0,0)
  for i in 0...64
    fp["flare"].opacity += 32*(i < 8 ? 1 : -1)
    fp["flare"].angle += 32
    pbSEPlay("EBDX/Anim/fire1",80) if i == 8
    for j in 0...3
      next if i < 12
      next if j>(i-12)/4
      fp["#{j}"].visible = true
      fp["#{j}"].opacity -= 16
      fp["#{j}"].angle += 16
      fp["#{j}"].zoom_x += 0.1
      fp["#{j}"].zoom_y += 0.1
    end
    for m in 0...12
      next if i < 6
      next if m>(i-6)
      fp["p#{m}"].visible = true
      fp["p#{m}"].opacity -= 16
      fp["p#{m}"].y -= 8
    end
    if i >= 48
      @targetSprite.color.alpha -= 16
    else
      @targetSprite.color.alpha += 16 if @targetSprite.color.alpha < 192
    end
    @targetSprite.anim = true
    @scene.wait
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:STARBEAM) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  factor = @targetIsPlayer ? 2 : 1
  @viewport.color = Color.new(255,255,255,155)
  # set up animation
  fp = {}; rndx = []; rndy = []; crndx = []; crndy = []; dx = []; dy = []
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb027_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  for i in 0...16
    fp["c#{i}"] = Sprite.new(@viewport)
    fp["c#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebStar")
    fp["c#{i}"].ox = fp["c#{i}"].bitmap.width/2
    fp["c#{i}"].oy = fp["c#{i}"].bitmap.height/2
    fp["c#{i}"].opacity = 0
    fp["c#{i}"].z = 19
    crndx.push(rand(64))
    crndy.push(rand(64))
  end
  for i in 0...72
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebStar")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 19
    rndx.push(rand(16))
    rndy.push(rand(16))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...16
    fp["c#{i}"] = Sprite.new(@viewport)
    fp["c#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebStar")
    fp["c#{i}"].ox = fp["c#{i}"].bitmap.width/2
    fp["c#{i}"].oy = fp["c#{i}"].bitmap.height/2
    fp["c#{i}"].opacity = 0
    fp["c#{i}"].z = 19
    crndx.push(rand(64))
    crndy.push(rand(64))
  end
  for i in 0...72
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebStar")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 19
    rndx.push(rand(16))
    rndy.push(rand(16))
    dx.push(0)
    dy.push(0)
  end
  @sprites["battlebg"].defocus
  # start animation
  for i in 0...96
    if i < 40
      fp["bg"].opacity += 25.5
    elsif i < 80
      fp["bg"].color.alpha -= 25.5
    end
    pbSEPlay("Anim/Ice8") if i == 12
    fp["bg"].update
    ax, ay = @userSprite.getAnchor
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...72
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        dx[j] = ax - 8*@userSprite.zoom_x*0.5 + rndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 8*@userSprite.zoom_y*0.5 + rndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
      end
      next if j>(i)
      x2 = cx - 8*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 8*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      x0 = dx[j]
      y0 = dy[j]
      fp["#{j}"].x += (x2 - x0)*0.05
      fp["#{j}"].y += (y2 - y0)*0.05
      fp["#{j}"].zoom_x = @targetIsPlayer ? @userSprite.zoom_x : @targetSprite.zoom_x
      fp["#{j}"].zoom_y = @targetIsPlayer ? @userSprite.zoom_y : @targetSprite.zoom_y
      fp["#{j}"].opacity += 32
      fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + (rand(4)==0 ? 180 : 0)
      nextx = fp["#{j}"].x + (x2 - x0)*0.05
      nexty = fp["#{j}"].y + (y2 - y0)*0.05
      if !@targetIsPlayer
        fp["#{j}"].z = @targetSprite.z - 1 if nextx > cx && nexty < cy
        fp["#{j}"].visible = false if nextx > cx && nexty < cy
      else
        fp["#{j}"].visible = false if nextx < cx && nexty > cy
      end
    end
    pbSEPlay("Anim/Ice1") if i>32 && (i-32)%4==0
    for j in 0...16
      if fp["c#{j}"].opacity == 0 && fp["c#{j}"].tone.gray == 0
        fp["c#{j}"].zoom_x = factor*@targetSprite.zoom_x
        fp["c#{j}"].zoom_y = factor*@targetSprite.zoom_x
        fp["c#{j}"].x = cx
        fp["c#{j}"].y = cy
      end
      next if j>((i-12)/4)
      next if i<12
      x2 = cx - 32*@targetSprite.zoom_x + crndx[j]*@targetSprite.zoom_x
      y2 = cy - 32*@targetSprite.zoom_y + crndy[j]*@targetSprite.zoom_y
      x0 = fp["c#{j}"].x
      y0 = fp["c#{j}"].y
      fp["c#{j}"].x += (x2 - x0)*0.2
      fp["c#{j}"].y += (y2 - y0)*0.2
      fp["c#{j}"].angle += 2
      if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
        fp["c#{j}"].opacity -= 24
        fp["c#{j}"].tone.gray += 8
        fp["c#{j}"].angle += 2
      else
        fp["c#{j}"].opacity += 35
      end
    end
    fp["bg"].opacity += 5 if fp["bg"].opacity < 255*0.5
    if i >= 32
      @targetSprite.tone.red += 5.4 if @targetSprite.tone.red < 108
      @targetSprite.tone.green += 6.4 if @targetSprite.tone.green < 128
      @targetSprite.tone.blue += 8 if @targetSprite.tone.blue < 160
      @targetSprite.still
    end
    @vector.set(vector) if i == 24
    @vector.inc = 0.1 if i == 24
    @viewport.color.alpha -= 5 if @viewport.color.alpha > 0
    @scene.wait(1,true)
  end
  20.times do
    @targetSprite.tone.red -= 5.4
    @targetSprite.tone.green -= 6.4
    @targetSprite.tone.blue -= 8
    @targetSprite.still
    fp["bg"].opacity -= 15
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @targetSprite.tone = Tone.new(0,0,0)
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:TUNGSTENTOMB) do
  factor = @targetSprite.zoom_x
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(16,true)
  factor = @targetSprite.zoom_x
  # set up animation
  fp = {}
  dx = []
  dy = []
  cx, cy = @targetSprite.getCenter(true)
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb027_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  for j in 0..16
    fp["i#{j}"] = Sprite.new(@viewport)
    fp["i#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb523")
    fp["i#{j}"].ox = fp["i#{j}"].bitmap.width/2
    fp["i#{j}"].oy = fp["i#{j}"].bitmap.height/2
    r = 72*factor
    fp["i#{j}"].x = cx - r + rand(r*2)
    fp["i#{j}"].y = cy - r*1.5 + rand(r*2)
    fp["i#{j}"].z = @targetSprite.z + (rand(2)==0 ? 1 : -1)
    fp["i#{j}"].zoom_x = factor
    fp["i#{j}"].zoom_y = factor
    fp["i#{j}"].opacity = 0
    dx.push(rand(2)==0 ? 1 : -1)
    dy.push(rand(2)==0 ? 1 : -1)
  end
  for m in 0...24
    fp["d#{m}"] = Sprite.new(@viewport)
    fp["d#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb523_2")
    fp["d#{m}"].src_rect.set(0,0,80,78)
    fp["d#{m}"].ox = fp["d#{m}"].src_rect.width/2
    fp["d#{m}"].oy = fp["d#{m}"].src_rect.height/2
    r = 32*factor
    fp["d#{m}"].x = cx - r + rand(r*2)
    fp["d#{m}"].y = cy - r + rand(r*2)
    fp["d#{m}"].z = @targetSprite.z + 1
    fp["d#{m}"].opacity = 0
    fp["d#{m}"].angle = rand(360)
  end
  for m in 0...24
    fp["s#{m}"] = Sprite.new(@viewport)
    fp["s#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb523_2")
    fp["s#{m}"].src_rect.set(80,0,80,78)
    fp["s#{m}"].ox = fp["s#{m}"].src_rect.width/2
    fp["s#{m}"].oy = fp["s#{m}"].src_rect.height/2
    r = 32*factor
    fp["s#{m}"].x = fp["d#{m}"].x
    fp["s#{m}"].y = fp["d#{m}"].y
    fp["s#{m}"].z = @targetSprite.z + 1
    fp["s#{m}"].opacity = 0
    fp["s#{m}"].angle = fp["d#{m}"].angle
  end
  for m in 0...24
    fp["d#{m}"] = Sprite.new(@viewport)
    fp["d#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb523_2")
    fp["d#{m}"].src_rect.set(0,0,80,78)
    fp["d#{m}"].ox = fp["d#{m}"].src_rect.width/2
    fp["d#{m}"].oy = fp["d#{m}"].src_rect.height/2
    r = 32*factor
    fp["d#{m}"].x = cx - r + rand(r*2)
    fp["d#{m}"].y = cy - r + rand(r*2)
    fp["d#{m}"].z = @targetSprite.z + 1
    fp["d#{m}"].opacity = 0
    fp["d#{m}"].angle = rand(360)
  end
  for m in 0...24
    fp["s#{m}"] = Sprite.new(@viewport)
    fp["s#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb523_2")
    fp["s#{m}"].src_rect.set(80,0,80,78)
    fp["s#{m}"].ox = fp["s#{m}"].src_rect.width/2
    fp["s#{m}"].oy = fp["s#{m}"].src_rect.height/2
    r = 32*factor
    fp["s#{m}"].x = fp["d#{m}"].x
    fp["s#{m}"].y = fp["d#{m}"].y
    fp["s#{m}"].z = @targetSprite.z + 1
    fp["s#{m}"].opacity = 0
    fp["s#{m}"].angle = fp["d#{m}"].angle
  end
  pbSEPlay("EBDX/Anim/iron4",100)
  for i in 0...48
    if i < 20
      fp["bg"].opacity += 25.5
    elsif i < 40
      fp["bg"].color.alpha -= 25.5
    end
    k = (i-16)/4
    pbSEPlay("EBDX/Anim/psychic4",80-20*k) if i >= 16 && i%4==0 && i < 28
    fp["bg"].update
    for j in 0...16
      next if j>(i/2)
      t = fp["i#{j}"].tone.red
      t += 32 if i%4==0
      t = 0 if t > 96
      fp["i#{j}"].tone = Tone.new(t,t,t)
      fp["i#{j}"].opacity += 16
      fp["i#{j}"].angle += dx[j]
    end
    @scene.wait
  end
  for i in 0...64
    pbSEPlay("EBDX/Anim/normal1",80) if i >= 2 && i%4==0 && i < 26
    for j in 0...16
      next if j>(i)
      fp["i#{j}"].x += (cx - fp["i#{j}"].x)*0.5
      fp["i#{j}"].y += (cy - fp["i#{j}"].y)*0.5
      fp["i#{j}"].angle += dx[j]
      fp["i#{j}"].visible = (cx - fp["i#{j}"].x)*0.5 >= 1
    end
    for m in 0...12
      next if i < 6
      next if m>(i-6)/2
      fp["d#{m}"].opacity += 32*(fp["d#{m}"].zoom_x < 1.5 ? 1 : -1)
      fp["d#{m}"].zoom_x += 0.05
      fp["d#{m}"].zoom_y += 0.05
      fp["d#{m}"].angle += 4
      fp["s#{m}"].opacity += 32*(fp["s#{m}"].zoom_x < 1.5 ? 1 : -1)
      fp["s#{m}"].zoom_x += 0.05
      fp["s#{m}"].zoom_y += 0.05
      fp["s#{m}"].angle += 4
    end
    @targetSprite.still
    @scene.wait
  end
  pbDisposeSpriteHash(fp)
  @vector.reset if !@multiHit
end

#=====================
#
#Mid Battle Scripts
#
#=====================

module BattleScripts
  BORIS = {
    "afterLastOpp" => proc do
      pname = $Trainer.name
      @scene.pbTrainerSpeak("Don't think this is over just yet, #{pname}!")
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
    "afterLastOpp" => proc do
      pname = $Trainer.name
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
      @scene.pbDisplay("Seth's underhanded tactics badly poisoned #{pname}'s party!")

  end,
  "turnStart0" => "Let's get this madness started!"
  }

  OZZY = {
    "afterLastOpp" => proc do
      pname = $Trainer.name
      @scene.pbTrainerSpeak("This battle may be saved yet! Observe, #{pname}!")
      @sprites["battlebg"].reconfigure(:CAVE, :DISTORTION)
      @battle.field.weather = :Sandstorm
      @battle.field.weatherDuration = 8
      @scene.pbDisplay("The sandstorm resurged!")
      @scene.wait(16,false)
      if @battle.battlers[0].pbOwnSide.effects[PBEffects::StealthRock] == false
        @scene.pbAnimation(GameData::Move.get(:STEALTHROCK).id,@battle.battlers[1],@battle.battlers[0])
        @battle.battlers[0].pbOwnSide.effects[PBEffects::StealthRock] = true
        @scene.pbDisplay("Ozzy set Stealth Rocks on #{pname}'s side!")
      end
    end,
    "turnStart0" => "Let's see just what you're made of!"
    }

  RALPH = {
    "afterLastOpp" => proc do
      pname = $Trainer.name
              @scene.pbTrainerSpeak("May the sun rise on our victory!")
              @sprites["battlebg"].reconfigure(:MAGMA, :DISTORTION)
              @battle.field.defaultWeather = :HarshSun
              @battle.field.weather = :HarshSun
              @scene.pbDisplay("The sun returned and intensified!")
              @scene.wait(16,false)
              EliteBattle.playCommonAnimation(:BURN,@scene,0)
              @battle.battlers[0].status = :BURN
              burnAllPokemon(nil)
              @scene.pbDisplay("The intense sun left #{pname}'s team burned!")
            end,
    "turnStart0" => "Let's get this place heated up!"
            }

  DELTA = {
    "afterLastOpp" => proc do
      pname = $Trainer.name
              @scene.pbTrainerSpeak("It's time for the tidal wave to come crashing down!")
              @sprites["battlebg"].reconfigure(:UNDERWATER, :DISTORTION)
              @battle.field.defaultWeather = :HeavyRain
              @battle.field.weather = :HeavyRain
              @scene.pbDisplay("The rain returned and intensified!")
              @scene.wait(16,false)
              if @battle.battlers[0].pbOwnSide.effects[PBEffects::StealthRock] == false
                @scene.pbAnimation(GameData::Move.get(:STEALTHROCK).id,@battle.battlers[1],@battle.battlers[0])
                @battle.battlers[0].pbOwnSide.effects[PBEffects::StealthRock] = true
                @scene.pbDisplay("Ozzy set Stealth Rocks on #{pname}'s side!")
              end
            end,
    "turnStart0" => "Come at me with all you've got!"
            }

  SEBASTIAN = {
    "afterLastOpp" => proc do
      pname = $Trainer.name
              @scene.pbTrainerSpeak("It's time for the curtain call!")
              @sprites["battlebg"].reconfigure(:STAGE, :DISTORTION)
              @battle.field.weather = :Reverb
              @battle.field.weatherDuration = 8
              @scene.pbDisplay("The Echo Chamber returned!")
              @scene.wait(16,false)
              @scene.pbAnimation(GameData::Move.get(:SPIKES).id,@battle.battlers[1],@battle.battlers[0])
              @battle.battlers[0].pbOwnSide.effects[PBEffects::Spikes] = 3
              @scene.pbDisplay("The reverberation shook 3 layers of Spikes onto #{pname}'s side!")
            end,
    "turnStart0" => "Come! Let us make a masterpiece!"
              }
  ANN = {
        "afterLastOpp" => proc do
          pname = $Trainer.name
          @scene.pbTrainerSpeak("...let the shadows come to my side.")
          @sprites["battlebg"].reconfigure(:DARKNESS, :DISTORTION)
          @battle.field.weather = :TimeWarp
          @battle.field.weatherDuration = 8
          @scene.pbDisplay("Time stopped again!")
          @scene.wait(16,false)
          EliteBattle.playCommonAnimation(:STATUP,@scene,1)
          @battlers[1].pbRaiseStatStageBasic(:DEFENSE,1)
          @battlers[1].pbRaiseStatStageBasic(:SPECIAL_DEFENSE,1)
          @scene.pbDisplay("Ann's Pokémon boosted its Defense and Special Defense!")
          @scene.wait(16,false)
          @scene.pbAnimation(GameData::Move.get(:SPIKES).id,@battle.battlers[1],@battle.battlers[0])
          @battle.battlers[0].pbOwnSide.effects[PBEffects::ToxicSpikes] = 2
          @scene.pbDisplay("The shadows managed to sneak 2 layers of Toxic Spikes onto #{pname}'s side!")
        end,
        "turnStart0" => "...let's begin."
      }

  PHOEBE = {
    "afterLastOpp" => proc do
      pname = $Trainer.name
              @scene.pbTrainerSpeak("I haven't have a battle this intense in a long time!")
              @sprites["battlebg"].reconfigure(:NET, :DISTORTION)
              @battle.field.weather = :Fog
              @battle.field.weatherDuration = 8
              @scene.pbDisplay("Fog covers the field!")
              @scene.wait(16,false)
              EliteBattle.playCommonAnimation(:STATUP,@scene,1)
              @battlers[1].pbRaiseStatStageBasic(:DEFENSE,1)
              @battlers[1].pbRaiseStatStageBasic(:SPECIAL_DEFENSE,1)
              @scene.pbDisplay("Phoebe's Pokémon boosted its Defense and Special Defense!")
              @scene.wait(16,false)
              @scene.pbAnimation(GameData::Move.get(:STEALTHROCK).id,@battle.battlers[1],@battle.battlers[0])
              @battle.battlers[0].pbOwnSide.effects[PBEffects::StealthRock] = true
              @scene.wait(16,false)
              @scene.pbAnimation(GameData::Move.get(:SPIKES).id,@battle.battlers[1],@battle.battlers[0])
              @battle.battlers[0].pbOwnSide.effects[PBEffects::Spikes] = 3
              @scene.pbDisplay("Phoebe launched Stealth Rocks and 3 layers of Spikes onto #{pname}'s side!")
            end,
            "turnStart0" => "I'm excited to have my first Gym Battle!"
            }
#============================
# Temple Guardian Battles
#============================
MARIE = {
    "turnStart0" => proc do
      pname = $Trainer.name
              @scene.pbTrainerSpeak("Be prepared for the terrible sound of defeat!")
              @battle.field.weather = :Reverb
              @battle.field.weatherDuration = 8
              @scene.pbDisplay("An echo chamber surrounds the field!")
              @scene.wait(16,false)
              if @battle.battlers[0].pbOwnSide.effects[PBEffects::CometShards] == nil
                @scene.pbAnimation(GameData::Move.get(:STEALTHROCK).id,@battle.battlers[1],@battle.battlers[0])
                @battle.battlers[0].pbOwnSide.effects[PBEffects::CometShards] = true
                @scene.pbDisplay("Marie set Comet Shards on #{pname}'s side!")
              end
            end,

"lowHPOpp" => proc do
  pname = $Trainer.name
                @scene.pbTrainerSpeak("Don't think I've given up so soon!")
                @scene.wait(16,false)
                @battle.battlers[1].pbRecoverHP(@battle.battlers[1].totalhp/3)
                @scene.pbDisplay("Meritempo tried its hardest for Marie!")
                @scene.pbDisplay("Meritempo recovered some HP!")
                @scene.wait(16,false)
                EliteBattle.playCommonAnimation(:STATUP,@scene,1)
                @battlers[1].pbRaiseStatStageBasic(:DEFENSE,1)
                @battlers[1].pbRaiseStatStageBasic(:SPEED,1)
                @scene.wait(16,false)
                @scene.pbDisplay("Meritempo's Defense and Speed rose!")
              end
              }
BURT = {
  "turnStart0" => proc do
    pname = $Trainer.name
                    @scene.pbTrainerSpeak("It takes more than just power to win some battles!")
                    @battle.field.weather = :Humid
                    @battle.field.weatherDuration = 8
                    @scene.pbDisplay("The air becomes humid!")
                    @scene.wait(16,false)
                    if @battle.battlers[0].pbOwnSide.effects[PBEffects::ToxicSpikes] == 0
                      @scene.pbAnimation(GameData::Move.get(:SPIKES).id,@battle.battlers[1],@battle.battlers[0])
                      @battle.battlers[0].pbOwnSide.effects[PBEffects::ToxicSpikes] = 2
                      @scene.pbDisplay("Burt set Toxic Spikes on #{pname}'s side!")
                    end
                  end,
"lowHPOpp" => proc do
  pname = $Trainer.name
                    @scene.pbTrainerSpeak("I can't let you break through yet. We've just begun!")
                    @scene.wait(16,false)
                    @battle.battlers[1].pbRecoverHP(@battle.battlers[1].totalhp/3)
                    @battle.battlers[1].status = 0
                    @scene.pbDisplay("Centisepa tried its hardest for Burt!")
                    @scene.pbDisplay("Centisepa recovered some HP and cured its status!")
                    @scene.wait(16,false)
                    EliteBattle.playCommonAnimation(:STATUP,@scene,1)
                    @battlers[1].pbRaiseStatStageBasic(:DEFENSE,1)
                    @battlers[1].pbRaiseStatStageBasic(:SPECIAL_DEFENSE,1,)
                    @scene.wait(16,false)
                    @scene.pbDisplay("Centisepa's Defense and Special Defense rose!")
                  end
                  }

TIM = {
  "turnStart0" => proc do
    pname = $Trainer.name
                    @scene.pbTrainerSpeak("The wind is at our backs!")
                    @battle.field.defaultWeather = :HeavyRain
                    @battle.field.weather = :HeavyRain
                    @scene.pbDisplay("Rain comes crashing down!")
                    @scene.wait(16,false)
                    if @battle.battlers[0].pbOwnSide.effects[PBEffects::Spikes] == 0
                      @scene.pbAnimation(GameData::Move.get(:SPIKES).id,@battle.battlers[1],@battle.battlers[0])
                      @battle.battlers[0].pbOwnSide.effects[PBEffects::Spikes] = 1
                      @scene.pbDisplay("Tim set a layer of Spikes on #{pname}'s side!")
                    end
                    @scene.wait(16,false)
                    @scene.pbAnimation(GameData::Move.get(:AURORAVEIL).id,@battle.battlers[1],@battle.battlers[1])
                    @battle.battlers[1].pbOwnSide.effects[PBEffects::AuroraVeil] = 8
                    @scene.pbDisplay("Tim set up a protective veil of light!")
                  end,
  "lowHPOpp" => proc do
    pname = $Trainer.name
                    @scene.pbTrainerSpeak("This storm could turn! Time to turn it up!")
                    @scene.wait(16,false)
                    @battle.battlers[1].pbRecoverHP(@battle.battlers[1].totalhp/2)
                    @battle.battlers[1].status = 0
                    @scene.pbDisplay("Orrustorm tried its hardest for Tim!")
                    @scene.pbDisplay("Orrustorm recovered some HP and cured its status!")
                    @scene.wait(16,false)
                    EliteBattle.playCommonAnimation(:STATUP,@scene,1)
                    @battlers[1].pbRaiseStatStageBasic(:SPEED,1)
                    @battlers[1].pbRaiseStatStageBasic(:SPECIAL_ATTACK,1)
                    @scene.wait(16,false)
                    @scene.pbDisplay("Orrustorm's Speed and Special Attack rose!")
                    @scene.wait(16,false)
                    @scene.pbAnimation(GameData::Move.get(:AURORAVEIL).id,@battle.battlers[1],@battle.battlers[1])
                    @battle.battlers[1].pbOwnSide.effects[PBEffects::AuroraVeil] = 8
                    @scene.pbDisplay("Tim set up a protective veil of light!")
                  end
      }

ANDY = {
    "turnStart0" => proc do
      pname = $Trainer.name
                  @scene.pbTrainerSpeak("The end shall come quickly...")
                  @battle.field.weather = :TimeWarp
                  @battle.field.weatherDuration = 8
                  @scene.pbDisplay("Time stood still!")
                  @scene.wait(16,false)
                  @scene.pbAnimation(GameData::Move.get(:STEALTHROCK),@battle.battlers[1],@battle.battlers[0])
                  @battle.battlers[0].pbOwnSide.effects[PBEffects::StealthRock] = true
                  @scene.pbDisplay("Andy set up Stealth Rocks on #{pname}'s side!")
                  @scene.wait(16,false)
                  @scene.pbAnimation(GameData::Move.get(:AURORAVEIL).id,@battle.battlers[1],@battle.battlers[1])
                  @battle.battlers[1].pbOwnSide.effects[PBEffects::AuroraVeil] = 5
                  @scene.pbDisplay("Andy set up a protective veil of light!")
                end,
      "lowHPOpp" => proc do
        pname = $Trainer.name
                  @scene.pbTrainerSpeak("This storm could turn! Time to turn it up!")
                  @scene.wait(16,false)
                  @battle.battlers[1].pbRecoverHP(@battle.battlers[1].totalhp/3)
                  @battle.battlers[1].status = 0
                  @scene.pbDisplay("Caninpu tried its hardest for Andy!")
                  @scene.pbDisplay("Caninpu recovered some HP and cured its status!")
                  @scene.wait(16,false)
                  EliteBattle.playCommonAnimation(:STATUP,@scene,1)
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
      pname = $Trainer.name
                  @scene.pbTrainerSpeak("I've been looking forward to this battle!")
                  @battle.field.weather = :Rain
                  @battle.field.weatherDuration = 8
                  @scene.pbDisplay("Rain began to fall!")
                  @scene.wait(16,false)
                  @battle.field.terrain = :Psychic
                  @battle.field.terrainDuration = 5
                  @scene.pbDisplay("The battlefield got weird!")
                  @scene.wait(16,false)
                  @scene.pbAnimation(GameData::Move.get(:STEALTHROCK),@battle.battlers[1],@battle.battlers[0])
                  @battle.battlers[0].pbOwnSide.effects[PBEffects::CometShards] = true
                  @scene.pbDisplay("Owen set up Comet Shards on #{pname}'s side!")
                  @scene.wait(16,false)
                  @scene.pbAnimation(GameData::Move.get(:AURORAVEIL).id,@battle.battlers[1],@battle.battlers[1])
                  @battle.battlers[1].pbOwnSide.effects[PBEffects::AuroraVeil] = 5
                  @scene.pbDisplay("Owen set up a protective veil of light!")
                end,
    "lowHPOpp" => proc do
      pname = $Trainer.name
                  @scene.pbTrainerSpeak("This is getting really good! Let's finish this out!")
                  @scene.wait(16,false)
                  @battle.battlers[1].pbRecoverHP(@battle.battlers[1].totalhp/2)
                  @battle.battlers[1].status = 0
                  @scene.pbDisplay("Sobekodile tried its hardest for Owen!")
                  @scene.pbDisplay("Sobekodile recovered some HP and cured its status!")
                  @scene.wait(16,false)
                  EliteBattle.playCommonAnimation(:STATUP,@scene,1)
                  @battlers[1].pbRaiseStatStageBasic(:SPEED,1)
                  @scene.wait(16,false)
                  @scene.pbDisplay("Sobekodile's Speed rose!")
                  @scene.wait(16,false)
                  EliteBattle.playCommonAnimation(:POISON,@scene,0)
                  @battle.battlers[0].status = :POISON
                  @battle.battlers[0].effects[PBEffects::Toxic]
                  poisonAllPokemon(nil)
                  @scene.pbDisplay("Owen badly poisoned your party!")
                end
                }

TARA = {
  "turnStart0" => proc do
    pname = $Trainer.name
                  @scene.pbTrainerSpeak("Well child, let's see how you fare!")
                  @battle.field.weather = :Starstorm
                  @battle.field.weatherDuration = 8
                  @scene.pbDisplay("Tara summoned a Starstorm!")
                  @scene.wait(16,false)
                  @scene.pbAnimation(GameData::Move.get(:STEALTHROCK),@battle.battlers[1],@battle.battlers[0])
                  @battle.battlers[0].pbOwnSide.effects[PBEffects::CometShards] = true
                  @scene.pbDisplay("Tara set up Comet Shards on #{pname}'s side!")
                  @scene.wait(16,false)
                  @scene.pbAnimation(GameData::Move.get(:AURORAVEIL).id,@battle.battlers[1],@battle.battlers[1])
                  @battle.battlers[1].pbOwnSide.effects[PBEffects::AuroraVeil] = 5
                  @scene.pbDisplay("Tara set up a protective veil of light!")
                end,
"lowHPOpp" => proc do
  pname = $Trainer.name
                  @scene.pbTrainerSpeak("Child, you're pushing me to my limits!")
                  @scene.wait(16,false)
                  @battle.battlers[1].pbRecoverHP(@battle.battlers[1].totalhp/3)
                  @battle.battlers[1].status = 0
                  @scene.pbDisplay("Osiram tried its hardest for Tara!")
                  @scene.pbDisplay("Osiram recovered some HP and cured its status!")
                  @scene.wait(16,false)
                  EliteBattle.playCommonAnimation(:STATUP,@scene,1)
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

TUYA = {
  "turnStart0" => proc do
    pname = $Trainer.name
                  @scene.pbTrainerSpeak("Boss said to go all out against you!")
                  @battle.field.weather = :VolcanicAsh
                  @battle.field.weatherDuration = 8
                  @scene.pbDisplay("Tuya summoned Volcanic Ash!")
                  @scene.wait(16,false)
                  @scene.pbAnimation(GameData::Move.get(:SPIKES),@battle.battlers[1],@battle.battlers[0])
                  @battle.battlers[0].pbOwnSide.effects[PBEffects::Spikes] = 2
                  @scene.pbDisplay("Tuya set up 2 layers of Spikes on #{pname}'s side!")
                  @scene.wait(16,false)
                  @scene.pbAnimation(GameData::Move.get(:AURORAVEIL).id,@battle.battlers[1],@battle.battlers[1])
                  @battle.battlers[1].pbOwnSide.effects[PBEffects::AuroraVeil] = 5
                  @scene.pbDisplay("Tuya set up a protective veil of light!")
                end,
  "lowHPOpp" => proc do
    pname = $Trainer.name
                  @scene.pbTrainerSpeak("You are testing my patience!")
                  @scene.wait(16,false)
                  @battle.battlers[1].pbRecoverHP(@battle.battlers[1].totalhp/3)
                  @battle.battlers[1].status = 0
                  @scene.pbDisplay("Bastungsten tried its hardest for Tuya!")
                  @scene.pbDisplay("Bastungsten recovered some HP and cured its status!")
                  @scene.wait(16,false)
                  EliteBattle.playCommonAnimation(:STATUP,@scene,1)
                  @battlers[1].pbRaiseStatStageBasic(:DEFENSE,1)
                  @battlers[1].pbRaiseStatStageBasic(:SPECIAL_DEFENSE,1)
                  @scene.wait(16,false)
                  @scene.pbDisplay("Bastungsten's Defense and Special Defense rose!")
                  @scene.wait(16,false)
                  EliteBattle.playCommonAnimation(:POISON,@scene,0)
                  @battle.battlers[0].status = :POISON
                  @battle.battlers[0].effects[PBEffects::Toxic]
                  poisonAllPokemon(nil)
                  @scene.pbDisplay("Tuya badly poisoned your party!")
                end
                }
SETI = {
    "turnStart0" => proc do
      pname = $Trainer.name
                  @scene.pbTrainerSpeak("Boss said to stop you at all costs!")
                  @battle.field.weather = :Eclipse
                  @battle.field.weatherDuration = 8
                  @scene.pbDisplay("Seti summoned an Eclipse!")
                  @scene.wait(16,false)
                  @scene.pbAnimation(GameData::Move.get(:STEALTHROCK),@battle.battlers[1],@battle.battlers[0])
                  @battle.battlers[0].pbOwnSide.effects[PBEffects::CometShards] = true
                  @scene.pbDisplay("Seti set up Comet Shards on #{pname}'s side!")
                  @scene.wait(16,false)
                  @scene.pbAnimation(GameData::Move.get(:AURORAVEIL).id,@battle.battlers[1],@battle.battlers[1])
                  @battle.battlers[1].pbOwnSide.effects[PBEffects::AuroraVeil] = 5
                  @scene.pbDisplay("Seti set up a protective veil of light!")
                end,
  "lowHPOpp" => proc do
    pname = $Trainer.name
                  @scene.pbTrainerSpeak("Time to end this!")
                  @scene.wait(16,false)
                  @battle.battlers[1].pbRecoverHP(@battle.battlers[1].totalhp/3)
                  @battle.battlers[1].status = 0
                  @scene.pbDisplay("Fenixet tried its hardest for Seti!")
                  @scene.pbDisplay("Fenixet recovered some HP and cured its status!")
                  @scene.wait(16,false)
                  EliteBattle.playCommonAnimation(:STATUP,@scene,1)
                  @battlers[1].pbRaiseStatStageBasic(:SPECIAL_ATTACK,1)
                  @scene.wait(16,false)
                  @scene.pbDisplay("Fenixet's Special Attack rose!")
                  @scene.wait(16,false)
                  EliteBattle.playCommonAnimation(:BURN,@scene,0)
                  @battle.battlers[0].status = :BURN
                  burnAllPokemon(nil)
                  @scene.pbDisplay("Tuya burned your party!")
                end
                }
RAMESES = {
      "turnStart0" => proc do
        pname = $Trainer.name
                  @scene.pbTrainerSpeak("It's time you learned your lesson!")
                  @scene.wait(16,false)
                  @scene.pbAnimation(GameData::Move.get(:SPIKES),@battle.battlers[1],@battle.battlers[0])
                  @battle.battlers[0].pbOwnSide.effects[PBEffects::ToxicSpikes] = 2
                  @scene.pbDisplay("Rameses set up 2 layers of Toxic Spikes on #{pname}'s side!")
                  @scene.wait(16,false)
                  @scene.pbAnimation(GameData::Move.get(:AURORAVEIL).id,@battle.battlers[1],@battle.battlers[1])
                  @battle.battlers[1].pbOwnSide.effects[PBEffects::AuroraVeil] = 5
                  @scene.pbDisplay("Rameses set up a protective veil of light!")
                end,
  "lowHPOpp" => proc do
    pname = $Trainer.name
                  @scene.pbTrainerSpeak("Time to end this!")
                  @scene.wait(16,false)
                  @battle.battlers[1].pbRecoverHP(@battle.battlers[1].totalhp/2)
                  @battle.battlers[1].status = 0
                  @scene.pbDisplay("Mauselynx tried its hardest for Rameses!")
                  @scene.pbDisplay("Mauselynx recovered some HP and cured its status!")
                  @scene.wait(16,false)
                  EliteBattle.playCommonAnimation(:STATUP,@scene,1)
                  @battlers[1].pbRaiseStatStageBasic(:SPECIAL_ATTACK,1)
                  @scene.wait(16,false)
                  @scene.pbDisplay("Mauselynx's Special Attack rose!")
                  @scene.wait(16,false)
                  @scene.pbAnimation(GameData::Move.get(:AURORAVEIL).id,@battle.battlers[1],@battle.battlers[1])
                  @battle.battlers[1].pbOwnSide.effects[PBEffects::AuroraVeil] = 5
                  @scene.pbDisplay("Rameses set up a protective veil of light!")
                end
                }
EUCAL = {
      "turnStart0" => proc do
        pname = $Trainer.name
                  @scene.pbTrainerSpeak("You could have been one of my top Scientists...")
                  @scene.wait(16,false)
                  @scene.pbAnimation(GameData::Move.get(:SPIKES),@battle.battlers[1],@battle.battlers[0])
                  @battle.battlers[0].pbOwnSide.effects[PBEffects::ToxicSpikes] = 2
                  @scene.pbDisplay("Eucal set up 2 layers of Toxic Spikes on #{pname}'s side!")
                  @scene.wait(16,false)
                  @scene.pbAnimation(GameData::Move.get(:AURORAVEIL).id,@battle.battlers[1],@battle.battlers[1])
                  @battle.battlers[1].pbOwnSide.effects[PBEffects::AuroraVeil] = 5
                  @scene.pbDisplay("Eucal set up a protective veil of light!")
                end,
  "lowHPOpp" => proc do
    pname = $Trainer.name
    rname = $game_variables[12]
                  @scene.pbTrainerSpeak("I knew you and #{rname} would become rather challenging if I let you go.\nBut I had to choose between stopping you two early or delaying the coup.\nSo clearly you see which choice I made...")
                  @scene.wait(16,false)
                  @battle.battlers[1].pbRecoverHP(@battle.battlers[1].totalhp/3)
                  @battle.battlers[1].status = 0
                  @scene.pbDisplay("Apophicary tried its hardest for Eucal!")
                  @scene.pbDisplay("Apophicary recovered some HP and cured its status!")
                  @scene.wait(16,false)
                  EliteBattle.playCommonAnimation(:STATUP,@scene,1)
                  @battlers[1].pbRaiseStatStageBasic(:SPECIAL_ATTACK,1)
                  @scene.wait(16,false)
                  @scene.pbDisplay("Apophicary's Special Attack rose!")
                  @scene.wait(16,false)
                  @scene.pbAnimation(GameData::Move.get(:SPIKES),@battle.battlers[1],@battle.battlers[0])
                  @battle.battlers[0].pbOwnSide.effects[PBEffects::Spikes] = 2
                  @scene.pbDisplay("Eucal set up 2 layers of Spikes on #{pname}'s side!")
                end
                }
LYPTUS = {
      "turnStart0" => proc do
        pname = $Trainer.name
        rname = $game_variables[12]
                  @scene.pbTrainerSpeak("I've had my eye on you and #{rname} since you both set out!\nI am so excited for this battle!")
                  @scene.wait(16,false)
                  @scene.pbAnimation(GameData::Move.get(:STEALTHROCK),@battle.battlers[1],@battle.battlers[0])
                  @battle.battlers[0].pbOwnSide.effects[PBEffects::CometShards] = true
                  @scene.pbDisplay("Dr. Lyptus set up Comet Shards on #{pname}'s side!")
                  @scene.wait(16,false)
                  @scene.pbAnimation(GameData::Move.get(:AURORAVEIL).id,@battle.battlers[1],@battle.battlers[1])
                  @battle.battlers[1].pbOwnSide.effects[PBEffects::AuroraVeil] = 5
                  @scene.pbDisplay("Dr. Lyptus set up a protective veil of light!")
                end,
  "lowHPOpp" => proc do
    pname = $Trainer.name
                  @scene.pbTrainerSpeak("This is what this challenge is all about!\nBringing each other to our absolute limit and seeing who is the stronger!\nNow hit me with all you've got!")
                  @scene.wait(16,false)
                  @battle.battlers[1].pbRecoverHP(@battle.battlers[1].totalhp/3)
                  @battle.battlers[1].status = 0
                  @scene.pbDisplay("Falkmunra tried its hardest for Dr. Lyptus!")
                  @scene.pbDisplay("Falmunra recovered some HP and cured its status!")
                  @scene.wait(16,false)
                  EliteBattle.playCommonAnimation(:STATUP,@scene,1)
                  @battlers[1].pbRaiseStatStageBasic(:SPECIAL_ATTACK,1)
                  @scene.wait(16,false)
                  @scene.pbDisplay("Falkmunra's Special Attack rose!")
                  @scene.wait(16,false)
                  @battle.field.weather = :Starstorm
                  @battle.field.weatherDuration = 8
                  @scene.pbDisplay("Dr. Lyptus called down a Starstorm!")
                end
                }
EUCALFINAL = {
  "afterLastOpp" => proc do
    pname = $Trainer.name
                  @scene.pbTrainerSpeak("I cannot have you ruining my plans. This is MY Zharo! The way I want it!")
                  @battle.field.weather = :AcidRain
                  @battle.field.weatherDuration = 8
                  @scene.pbDisplay("Acid Rain pours down!")
                  @scene.wait(16,false)
                  EliteBattle.playCommonAnimation(:STATUP,@scene,1)
                  @battlers[1].pbRaiseStatStageBasic(:DEFENSE,1)
                  @battlers[1].pbRaiseStatStageBasic(:SPECIAL_DEFENSE,1)
                  @battlers[1].pbRaiseStatStageBasic(:SPECIAL_ATTACK,1)
                  @scene.pbDisplay("Apophicary boosted its Defense, Special Attack and Special Defense!")
                end
                }
  RIVAL1 = { "turnStart0" => "I'm so stoked to see your Pokémon!",
             "lowHPOpp" => "Whoa, that little guy is strong!"
           }
  RIVAL2 = { "turnStart0" => "Let's see what kind of team you're rocking!",
            "afterLastOpp" => "Oh this is gonna be a good battle!"
           }

  RIVAL3 = { "turnStart0" => "Just wait til you see the team I've raised!",
            "afterLastOpp" => proc do
              pname = $Trainer.name
              @scene.pbTrainerSpeak("Wow! Your team is looking really good, #{pname}!")
            end
           }
  RIVAL4 = { "turnStart0" => "Burt has been teaching me a few things!",
           "afterLastOpp" => proc do
             pname = $Trainer.name
             rname = $game_variables[12]
             poke = @battlers[1].name
             @scene.pbTrainerSpeak("Your team is looking great as ever, #{pname}! Now check this out!")
             EliteBattle.playCommonAnimation(:STATUP,@scene,1)
             @battlers[1].pbRaiseStatStageBasic(:DEFENSE,1)
             @battlers[1].pbRaiseStatStageBasic(:SPECIAL_DEFENSE,1)
             @battlers[1].pbRaiseStatStageBasic(:SPEED,1)
             @scene.pbDisplay("#{rname} boosted #{poke}'s defenses and Speed!")
           end
          }
  RIVAL5 = { "turnStart0" => "You ready to head back to the Mainland?",
           "afterLastOpp" => proc do
             pname = $Trainer.name
             rname = $game_variables[12]
             poke = @battlers[1].name
             @scene.pbTrainerSpeak("You look fired up, #{pname}! Let's get this going!")
             EliteBattle.playCommonAnimation(:STATUP,@scene,1)
             @battlers[1].pbRaiseStatStageBasic(:DEFENSE,1)
             @battlers[1].pbRaiseStatStageBasic(:SPECIAL_DEFENSE,1)
             @battlers[1].pbRaiseStatStageBasic(:SPEED,1)
             @scene.pbDisplay("#{rname} boosted #{poke}'s defenses and Speed!")
           end
          }
  RIVAL6 = { "turnStart0" => "Let me see how your team is looking!",
           "afterLastOpp" => proc do
             pname = $Trainer.name
             rname = $game_variables[12]
             poke = @battlers[1].name
             @scene.pbTrainerSpeak("You evolved your starter too, #{pname}! This is awesome!")
             EliteBattle.playCommonAnimation(:STATUP,@scene,1)
             @battlers[1].pbRaiseStatStageBasic(:DEFENSE,1)
             @battlers[1].pbRaiseStatStageBasic(:SPECIAL_DEFENSE,1)
             @battlers[1].pbRaiseStatStageBasic(:SPEED,1)
             @scene.pbDisplay("#{rname} boosted #{poke}'s defenses and Speed!")
           end
          }
  RIVAL7 = { "turnStart0" => "I really hope you're ready...",
         "afterLastOpp" => proc do
           pname = $Trainer.name
           rname = $game_variables[12]
           poke = @battlers[1].name
           @scene.pbTrainerSpeak("I think you got this, #{pname}! But let's toss one final test in!")
           EliteBattle.playCommonAnimation(:STATUP,@scene,1)
           @battlers[1].pbRaiseStatStageBasic(:DEFENSE,1)
           @battlers[1].pbRaiseStatStageBasic(:SPECIAL_DEFENSE,1)
           @battlers[1].pbRaiseStatStageBasic(:SPEED,1)
           @scene.pbDisplay("#{rname} boosted #{poke}'s defenses and Speed!")
         end
        }
  RIVAL8 = { "turnStart0" => "Let's see who's more ready for the Pokémon League!",
         "afterLastOpp" => proc do
           pname = $Trainer.name
           rname = $game_variables[12]
           poke = @battlers[1].name
           @scene.pbTrainerSpeak("No shenanigans this time, #{pname}! Let's finish this!")
         end
        }
end
