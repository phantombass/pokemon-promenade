#######################
#
# DEXNAV
#
# thesuzerain
#
# Implements the "dexnav" from the latest Pokemon games as seen in Insurgence.
# Sort of a "gadget belt" or "cell phone" kind of menu.
# Contains options such as pokemon hunting, online play, etc
#
# To open it, use the script:
#   $scene = Scene_DexNav.new
# when in the overworld.
#######################


class Scene_DexNav
  # update the scene
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
       _INTL("DexNav"),2,-18,256,64,@viewport)
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


class DexNavScreen
  def initialize(scene)
    @scene = scene
  end
  def pbStartScreen
    commands = []
    cmdDexNav = -1
    commands[cmdDexNav = commands.length]   = _INTL("Search")
    commands[commands.length] = _INTL("Exit")
    @scene.pbStartScene(commands)
    loop do
      cmd = @scene.pbScene
    if cmd<0
    pbPlayCloseMenuSE
      break
    elsif cmdDexNav>=0 && cmd==cmdDexNav
        if $currentDexSearch != nil
          Kernel.pbMessage("You're already searching for one. Try having a look around!")
          break
        else
          ary=DexNav.getPokemonInArea($game_map.map_id)
          ary=ary.select { |a| $Trainer.seen[a] }
          ary2=DexNav.getPokemonInArea($game_map.map_id)
          ary2=ary.select { |a| $Trainer.seen[a] }
          ary=ary.map { |a| PBSpecies.getName(a) }
          if ary.length == 0
            Kernel.pbMessage("No Pokemon data was found for this area.")
            Kernel.pbMessage("Catch Pokemon to have them appear here!")
            break
          else
          ary.unshift("(Cancel)")
          val=Kernel.pbMessage("Select a Pokemon to filter for.",ary,0)
            if val!=0
              # Once they've chosen one, there is some random chance they find it
              Kernel.pbMessage("Searching...")
              if rand(2) == 0
                 Kernel.pbMessage("Oh! A Pokemon was found nearby!")
                 species=ary2[val-1]
                 # We generate the pokemon they found (added to the encounters),
                 # giving it some rare "egg moves"to incentivize using  this function
                 $currentDexSearch=[species,DexNav.addRandomEggMove(species),DexNav.addRandomEggMove(species)]
                 Kernel.pbMessage("Try looking in wild Pokemon spots near you- it might appear!")
                 break
              else
                 Kernel.pbMessage("Nothing was found. Try looking somewhere else!")
              end
            end
          end
        end
      else
        pbPlayCloseMenuSE
        break
      end
    end
    @scene.pbEndScene
  end
end

Events.onWildPokemonCreate+=proc {|sender,e|
    pokemon=e[0]
    # Checks current search value, if it exists, sets the Pokemon to it
    if $currentDexSearch != nil && $currentDexSearch.is_a?(Array)
        pokemon.species=$currentDexSearch[0]
        pokemon.level=pokemon.level
        pokemon.name=PBSpecies.getName(pokemon.species)
        pokemon.setAbility(2) if rand(100)+1<51
        pokemon.resetMoves
        pokemon.moves[2]=PBMove.new($currentDexSearch[1]) if $currentDexSearch[1]
        if $currentDexSearch[1] != $currentDexSearch[2]
          pokemon.moves[3]=PBMove.new($currentDexSearch[2]) if $currentDexSearch[2]
        end

        # There is a higher chance for shininess, so we give it another chance to force it to be shiny
        tempInt = $PokemonBag.pbQuantity(PBItems::SHINYCHARM)>0 ? 256 : 768
        if rand(tempInt)==1
         pokemon.makeShiny
       end
        $currentDexSearch = nil
    end
}

class DexNav

  # This method triggers every time the dexnav is used (1 more to the chain)
  # It recalculates the odds for a shiny, adds egg moves and so on
  # It updates into $dexNavData which is retrieved with getThisPokemonData
  def self.addToChain
    $dexNavData=[0,0,0] if !$dexNavData
    $dexNavData += 1
    if rand(8192/DexNav.getShinyMultiplier($dexNavData).floor)==0
      $dexNavData[1]=true
    end
    $dexNavData[2]=DexNav.addRandomEggMove(pokemon)
    $dexNavData[3]=DexNav.getAppropriateLevel($dexNavData)
  end

  def self.getAppropriateLevel(datum)
      return ((datum[0]%100)/5).floor
  end


  #This method just returns the temporary data for the next pokemon to be encountered.
  def self.getThisPokemonData
    $dexNavData=[0,0,0,0] if !$dexNavData
    return $dexNavData
  end


  # Returns an array of available pokemon species in a map
  def self.getPokemonInArea(map_id)
    # Opens the encounter list
    data=load_data("Data/encounters.dat")
    if data.is_a?(Hash) && data[map_id]
      density=data[map_id][0]
      enctypes=data[map_id][1]
    else
      density=nil
      enctypes=[]
    end
    speciesAry=[]
    # Iterates through every possible encounter type
    # Only takes species that player could currently see
    # (ie: will only add water encounters if the player is surfing)
    for i in 0..17
      if [EncounterTypes::Land,EncounterTypes::HighBridge,EncounterTypes::Sand,EncounterTypes::Graveyard,EncounterTypes::Snow].include?(i) && ($PokemonGlobal.surfing || $PokemonGlobal.fishing)
        next
      end
      if [EncounterTypes::Water].include?(i) && !$PokemonGlobal.surfing
        next
      end
      if enctypes[i] && enctypes[i].is_a?(Array) && enctypes[i][0]
        tempAry=[]
        for j in 0..99
          v=enctypes[i][j]
          tempAry.push(v[0]) if v && v[0] && !tempAry.include?(v[0])
        end
        speciesAry.push(tempAry)
      end
    end
    newAry=[]
    for i in speciesAry
      for j in i
        newAry.push(j)
      end
    end

    return newAry
  end

  # This method gets the appropriate shiny rate multiplier for a certain chain value
  def self.getShinyMultiplier(datum)
    value=1
    if datum[0]<80
      return value*datum[0]
    else
      return 80
    end
  end

  # This method gets a random ID of a legal egg move and returns it as a move object.
  def self.addRandomEggMove(species)
    baby = pbGetBabySpecies(species)
    egg = pbGetSpeciesEggMoves(baby)
    moveChoice = rand(egg.length)
    moves = egg[moveChoice]
    return moves
end
end
