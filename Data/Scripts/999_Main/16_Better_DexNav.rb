PluginManager.register({
  :name => "Better DexNav",
  :version => "1.0",
  :credits => ["Phantombass, with portions of code taken from:","Suzerain","Nuri Yuri","Developers of SimpleEncounterUI"],
  :link => "https://reliccastle.com/resources/520/"
})

class NewDexNav

  def initialize
    @viewport1 = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport1.z = 99999
    @viewport2 = Viewport.new(30, 120, Graphics.width, Graphics.height)
    @viewport2.z = 999999
    @viewport3 = Viewport.new(0, 120, Graphics.width, Graphics.height)
    @viewport3.z = 999999
    $viewport1 = nil
    searchmon = 0
    @sprites = {}
    @encarray = []
    @pkmnsprite = []
    @navChoice = 0
    navAbil = []
    @ab = []
    encstringarray = [] # Savordez simplified this on discord but I kept it for me to understand better
    getEncData
    # Following variable is unused, but can be a good sub in if you need it
    #textColor=["0070F8,78B8E8","E82010,F8A8B8","0070F8,78B8E8"][$Trainer.gender]
    loctext = _INTL("<ac><c2=43F022E8>{1}</c2></ac>", $game_map.name)
    temparray = @encarray.dup  # doing `if @encarray.pop==7` actually pops the last species off before the loop!
    if temparray.pop==7  # i picked 7 cause funny
      loctext += sprintf("<al><c2=FFCADE00>This area has no encounters</c2></al>")
      loctext += sprintf("<c2=63184210>-----------------------------------------</c2>")
    else
      i = 0
      @encarray.each do |specie|
     #   loctext += _INTL("<ar><c2=7FFF5EF7>{1}</c2></ar>",PBSpecies.getName(specie))
         encstringarray.push(PBSpecies.getName(specie))#+", ")
         @pkmnsprite[i]=PokemonSpeciesIconSprite.new(specie,@viewport2)
         if i > 6 && i < 14
           @pkmnsprite[i].y += 64
           @pkmnsprite[i].x = (64 * (i-7))
         elsif i > 13
           @pkmnsprite[i].y += 128
           @pkmnsprite[i].x = (64 * (i-14))
         else
           @pkmnsprite[i].x += 64 * i
         end
         i +=1
       end
      loctext += sprintf("<al><c2=FFCADE00>Total encounters for area: %s</c2></al>",@encarray.length)
      loctext += sprintf("<c2=63184210>-----------------------------------------</c2>")
      #loctext += sprintf("<al>%s</al>",encstringarray.join(", "))#.map{|a| a.to_s})
    end
    @sprites["locwindow"]=Window_AdvancedTextPokemon.new(loctext)
    @sprites["locwindow"].viewport=@viewport1
    @sprites["locwindow"].x=0
    @sprites["locwindow"].y=20
    @sprites["locwindow"].width=512 #if @sprites["locwindow"].width<420
    @sprites["locwindow"].height=344
    @sprites["locwindow"].setSkin("Graphics/Windowskins/frlgtextskin")
    @sprites["locwindow"].opacity=200
    @sprites["locwindow"].visible=true
    @sprites["nav"] = AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport3)
    @sprites["nav"].x = 5
    @sprites["nav"].y = 18
    @sprites["nav"].visible
    @sprites["nav"].play
    pbFadeInAndShow(@sprites)
    main
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def dispose
    pbFadeOutAndHide(@sprites) {pbUpdate}
    pbDisposeSpriteHash(@sprites)
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end

  def pbListOfEncounters(encounter)   # this method is from Nuri Yuri
    return [] unless encounter

    encable = encounter.compact # remove nils
    encable.map! { |enc_list| enc_list.map { |enc| enc[0] } }
    encable.flatten! # transform array of array into array
    encable.uniq! # prevent duplication

    return encable
  end

  def getEncData
    encdata = load_data("Data/encounters.dat")
    mapid = $game_map.map_id
    if encdata.is_a?(Hash) && encdata[mapid]
      enctypes = encdata[mapid][1]
      pLoc = $game_map.terrain_tag($game_player.x,$game_player.y)
      if PBTerrain.isSnow?(pLoc)
        encTerr = enctypes[17]
      elsif PBTerrain.isGrass?(pLoc) || PBTerrain.isLand?(pLoc)
        if enctypes[1] == nil
          encTerr = enctypes[0]
        else
          encTerr = enctypes[1]
        end
      elsif PBTerrain.isHighBridge?(pLoc)
        encTerr = enctypes[14]
      elsif PBTerrain.isGraveyard?(pLoc)
        encTerr = enctypes[16]
      elsif PBTerrain.isSandy?(pLoc) || PBTerrain.isSand?(pLoc)
        encTerr = enctypes[15]
      elsif EncounterTypes::Cave
        encTerr = enctypes[1]
      elsif PBTerrain.isSurfable?(pLoc)
        encTerr = enctypes[2]
      end
      enc = encTerr.map { |e| e[0]  }
      enc2 = enc.flatten
      enc3 = enc2.uniq
      @encarray = enc3
      @temp = 0
      for i in 0..@encarray.length-1
        j = @encarray.length-2
        while (j >= i)
          if getID(PBSpecies,pbGetSpeciesConst(@encarray[j])) > getID(PBSpecies,pbGetSpeciesConst(@encarray[j+1]))
            #Kernel.pbMessage(_INTL("{1}",PBSpecies::pbGetSpeciesConst(@encarray[j])))
            @temp = @encarray[j]
            @encarray[j] = @encarray[j+1]
            @encarray[j+1] = @temp
          end
          j -= 1
        end
      end
    else
      @encarray = [7]  # i picked 7 cause funny
    end
  end

  def main
    navMon = 0
    @navChoice = 0
    lastMon = @encarray.length - 1
    @sprites["navMon"]=Window_AdvancedTextPokemon.new(_INTL("<c2=FFCADE00>{1}</c2>",PBSpecies.getName(@encarray[navMon])))
    @sprites["navMon"].viewport = @viewport1
    @sprites["navMon"].x=340
    @sprites["navMon"].y=52
    @sprites["navMon"].width=156
    @sprites["navMon"].windowskin = nil
    loop do
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
      if Input.trigger?(Input::DOWN)
        next if lastMon < 7 && @navChoice < 7
        next if lastMon > 6 && lastMon <14 && @navChoice > 6 && @navChoice < 14
        next if (@navChoice + 7) > lastMon
        @navChoice +=7
        navMon += 7
        @sprites["nav"].y += 64
        @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",PBSpecies.getName(@encarray[navMon]))
      elsif Input.trigger?(Input::UP) && @navChoice > 6
        @navChoice -=7
        navMon -=7
        @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",PBSpecies.getName(@encarray[navMon]))
        @sprites["nav"].y -= 64
      elsif Input.trigger?(Input::LEFT) && (@navChoice != 0 && @navChoice != 7 && @navChoice != 14)
        @navChoice -=1
        navMon -=1
        @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",PBSpecies.getName(@encarray[navMon]))
        @sprites["nav"].x -= 64
      elsif Input.trigger?(Input::RIGHT)
        if @navChoice == 6 || @navChoice == 13 || @navChoice == 20 || @navChoice == lastMon
          next
        elsif (@navChoice !=6 && @navChoice !=13 && @navChoice !=20) || (@navChoice != lastMon)
        @navChoice +=1
        navMon +=1
        @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",PBSpecies.getName(@encarray[navMon]))
        @sprites["nav"].x += 64
        end
      elsif Input.trigger?(Input::C)
        if !$Trainer.seen[@encarray[navMon]]
          Kernel.pbMessage("<c2=318c675a>You cannot search for this Pokémon yet!</c2>")
          Kernel.pbMessage("<c2=318c675a>Try looking for it first to register it to your Pokédex!</c2>")
          next
        elsif $currentDexSearch != nil
          Kernel.pbMessage("<c2=318c675a>You're already searching for one. Try having a look around!</c2>")
          @viewport2.dispose
          break
        else
          Kernel.pbMessage("<c2=318c675a>Searching...</c2>")
            if rand(2) == 0
               Kernel.pbMessage("<c2=318c675a>Oh! A Pokemon was found nearby!</c2>")
                species=@encarray[@navChoice]
               # We generate the pokemon they found (added to the encounters),
                # giving it some rare "egg moves"to incentivize using  this function
               $currentDexSearch=[species,DexNav.addRandomEggMove(species)]
               Kernel.pbMessage("<c2=318c675a>Try looking in wild Pokemon spots near you- it might appear!</c2>")
               pbFadeOutAndHide(@sprites)
               break
            else
               Kernel.pbMessage("<c2=318c675a>Nothing was found. Try looking somewhere else!</c2>")
            end
          end
      elsif Input.trigger?(Input::B)
        navMon = -1
        dispose
        break
      else
        next
      end
    end
    if navMon != -1
      @viewport2.dispose
      main2
    end
  end

  def main2
    searchmon = getID(PBSpecies,pbGetSpeciesConst($currentDexSearch[0]))
    maps = pbGetMetadata($game_map.map_id,MetadataMapPosition)   # Map IDs for Zharonian Forme
    form = 0
    if form == 0 && maps && maps[0]==0
      if isConst?(searchmon,PBSpecies,:RIOLU)||isConst?(searchmon,PBSpecies,:LUCARIO)||isConst?(searchmon,PBSpecies,:BUNEARY)||isConst?(searchmon,PBSpecies,:LOPUNNY)||isConst?(searchmon,PBSpecies,:NUMEL)||isConst?(searchmon,PBSpecies,:CAMERUPT)||isConst?(searchmon,PBSpecies,:ROCKRUFF)||isConst?(searchmon,PBSpecies,:YAMASK)
        form = 2
      elsif isConst?(searchmon,PBSpecies,:CACNEA)||isConst?(searchmon,PBSpecies,:CACTURNE)||isConst?(searchmon,PBSpecies,:SANDYGAST)||isConst?(searchmon,PBSpecies,:PALOSSAND)||isConst?(searchmon,PBSpecies,:DEINO)||isConst?(searchmon,PBSpecies,:ZWEILOUS)||isConst?(searchmon,PBSpecies,:HYDREIGON)||isConst?(searchmon,PBSpecies,:TRAPINCH)||isConst?(searchmon,PBSpecies,:HORSEA)||isConst?(searchmon,PBSpecies,:SEADRA)||isConst?(searchmon,PBSpecies,:EXEGGCUTE)||isConst?(searchmon,PBSpecies,:EXEGGUTOR)||isConst?(searchmon,PBSpecies,:SEEL)||isConst?(searchmon,PBSpecies,:DEWGONG)||isConst?(searchmon,PBSpecies,:DROWZEE)||isConst?(searchmon,PBSpecies,:PHANPY)||isConst?(searchmon,PBSpecies,:ZEBSTRIKA)
        form = 1
      else
        form = form
      end
    end
    navRand = rand(3)
    $game_variables[400] = navRand
    hAbil = pbGetSpeciesData(searchmon,form,SpeciesHiddenAbility)
    navAbil1 = pbGetSpeciesData(searchmon,form,SpeciesAbilities)
    if navAbil1[1] != nil
      navAbil = [navAbil1[0],navAbil1[1],hAbil[0]]
    else
      navAbil = [navAbil1[0],navAbil1[0],hAbil[0]]
    end
    ab = PBAbilities.getName(navAbil[navRand])
    Graphics.update
    if $currentDexSearch[1] == nil
      dexMove = "-"
    else
      dexMove = $currentDexSearch[1]
    end
    searchtext = [PBSpecies.getName(searchmon),ab,PBMoves.getName(dexMove)]
    @sprites["search"] = Window_AdvancedTextPokemon.newWithSize("",265,250,250,126,@viewport1)
    if navRand == 2
      @sprites["search"].text = _INTL("{1}\n<c2=463F0000>{2}</c2>\n{3}",searchtext[0],searchtext[1],searchtext[2])
    else
      @sprites["search"].text = _INTL("{1}\n{2}\n{3}",searchtext[0],searchtext[1],searchtext[2])
    end
    @sprites["search"].setSkin("Graphics/Windowskins/frlgtextskin")
    @sprites["search"].opacity = 200
    @sprites["searchIcon"] = PokemonSpeciesIconSprite.new(getID(PBSpecies,searchmon),@viewport1)
    @sprites["searchIcon"].x = 450
    @sprites["searchIcon"].y = 185
    $viewport1 = @viewport1
    pbFadeInAndShow(@sprites) {pbUpdate}
    $game_switches[350] = true
  end
end

Events.onStartBattle+=proc {|_sender,e|
  if $game_switches[350] == true
    $viewport1.dispose
    $game_switches[350] = false
  end
}

Events.onMapChanging +=proc {|_sender,e|
  if $game_switches[350] == true
    $viewport1.dispose
    $currentDexSearch = nil
    $game_switches[350] = false
  end
}

Events.onWildPokemonCreate+=proc {|sender,e|
    pokemon=e[0]
    # Checks current search value, if it exists, sets the Pokemon to it
    if $currentDexSearch != nil && $currentDexSearch.is_a?(Array)
        pokemon.species=$currentDexSearch[0]
        pokemon.level=pokemon.level
        pokemon.name=PBSpecies.getName(pokemon.species)
        pokemon.setAbility($game_variables[400])
        maps = pbGetMetadata($game_map.map_id,MetadataMapPosition)
        pform = 0
        if pform == 0 && maps && maps[0]==0
          if isConst?(pokemon.species,PBSpecies,:RIOLU)||isConst?(pokemon.species,PBSpecies,:LUCARIO)||isConst?(pokemon.species,PBSpecies,:BUNEARY)||isConst?(pokemon.species,PBSpecies,:LOPUNNY)||isConst?(pokemon.species,PBSpecies,:NUMEL)||isConst?(pokemon.species,PBSpecies,:CAMERUPT)||isConst?(pokemon.species,PBSpecies,:ROCKRUFF)||isConst?(pokemon.species,PBSpecies,:YAMASK)
            pform += 2
          elsif isConst?(pokemon.species,PBSpecies,:CACNEA)||isConst?(pokemon.species,PBSpecies,:CACTURNE)||isConst?(pokemon.species,PBSpecies,:SANDYGAST)||isConst?(pokemon.species,PBSpecies,:PALOSSAND)||isConst?(pokemon.species,PBSpecies,:DEINO)||isConst?(pokemon.species,PBSpecies,:ZWEILOUS)||isConst?(pokemon.species,PBSpecies,:HYDREIGON)||isConst?(pokemon.species,PBSpecies,:TRAPINCH)||isConst?(pokemon.species,PBSpecies,:HORSEA)||isConst?(pokemon.species,PBSpecies,:SEADRA)||isConst?(pokemon.species,PBSpecies,:EXEGGCUTE)||isConst?(pokemon.species,PBSpecies,:EXEGGUTOR)||isConst?(pokemon.species,PBSpecies,:SEEL)||isConst?(pokemon.species,PBSpecies,:DEWGONG)||isConst?(pokemon.species,PBSpecies,:DROWZEE)||isConst?(pokemon.species,PBSpecies,:PHANPY)||isConst?(pokemon.species,PBSpecies,:ZEBSTRIKA)
            pform += 1
          else
            pform = pform
          end
        end
        pokemon.form = pform
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
    $dexNavData=[0,0,0] if !$dexNavData
    return $dexNavData
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
    maps = pbGetMetadata($game_map.map_id,MetadataMapPosition)
    form = 0
    if form == 0 && maps && maps[0]==0
      if isConst?(baby,PBSpecies,:RIOLU)||isConst?(baby,PBSpecies,:LUCARIO)||isConst?(baby,PBSpecies,:BUNEARY)||isConst?(baby,PBSpecies,:LOPUNNY)||isConst?(baby,PBSpecies,:NUMEL)||isConst?(baby,PBSpecies,:CAMERUPT)||isConst?(baby,PBSpecies,:ROCKRUFF)||isConst?(baby,PBSpecies,:YAMASK)
        form += 2
      elsif isConst?(baby,PBSpecies,:CACNEA)||isConst?(baby,PBSpecies,:CACTURNE)||isConst?(baby,PBSpecies,:SANDYGAST)||isConst?(baby,PBSpecies,:PALOSSAND)||isConst?(baby,PBSpecies,:DEINO)||isConst?(baby,PBSpecies,:ZWEILOUS)||isConst?(baby,PBSpecies,:HYDREIGON)||isConst?(baby,PBSpecies,:TRAPINCH)||isConst?(baby,PBSpecies,:HORSEA)||isConst?(baby,PBSpecies,:SEADRA)||isConst?(baby,PBSpecies,:EXEGGCUTE)||isConst?(baby,PBSpecies,:EXEGGUTOR)||isConst?(baby,PBSpecies,:SEEL)||isConst?(baby,PBSpecies,:DEWGONG)||isConst?(baby,PBSpecies,:DROWZEE)||isConst?(baby,PBSpecies,:PHANPY)||isConst?(baby,PBSpecies,:ZEBSTRIKA)
        form += 1
      else
        form = form
      end
    end
    egg = pbGetSpeciesEggMoves(baby,form)
    moveChoice = rand(egg.length)
    moves = egg[moveChoice]
    return moves
  end
end
