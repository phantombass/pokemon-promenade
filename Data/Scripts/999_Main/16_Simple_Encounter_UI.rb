############################################
#    Simple Encounter List Window by raZ   #
#     Additions from Nuri Yuri, Vendily    #
#                  v1.2                    #
#   Icon edits + NatDex iter. by Zaffre    #
############################################
#    To use it, call EncounterListUI       #
#    like any other screen:                #
#                                          #
#    screen = EncounterListUI.new          #
#                                          #
#   PLEASE NOTE: Icon version only works   #
#       with 3 rows of encounters!         #
############################################

# just note that the species text is using whatever colour ID 0 is, black by default
# if your message box background is dark, you can either edit the default colour
# to be white, or add in a <c2> where it says <al>%s</al> with the white colour

class EncounterListUI
  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @viewport2 = Viewport.new(30, 120, Graphics.width, Graphics.height)
    @viewport2.z = 999999
    @sprites = {}
    @encarray = []
    @pkmnsprite = []
    encstringarray = [] # Savordez simplified this on discord but I kept it for me to understand better
    getEncData
    # Following variable is unused, but can be a good sub in if you need it
    #textColor=["0070F8,78B8E8","E82010,F8A8B8","0070F8,78B8E8"][$Trainer.gender]

    loctext = _INTL("<ac><c2=43F022E8>{1}</c2></ac>", $game_map.name)
    temparray = @encarray.dup  # doing `if @encarray.pop==7` actually pops the last species off before the loop!
    if temparray.pop==7  # i picked 7 cause funny
      loctext += sprintf("<al><c2=7FF05EE8>This area has no encounters</c2></al>")
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
      loctext += sprintf("<al><c2=7FF05EE8>Total encounters for area: %s</c2></al>",@encarray.length)
      loctext += sprintf("<c2=63184210>-----------------------------------------</c2>")
      #loctext += sprintf("<al>%s</al>",encstringarray.join(", "))#.map{|a| a.to_s})
    end
    @sprites["locwindow"]=Window_AdvancedTextPokemon.new(loctext)
    @sprites["locwindow"].viewport=@viewport
    @sprites["locwindow"].x=0
    @sprites["locwindow"].y=20
    @sprites["locwindow"].width=512 #if @sprites["locwindow"].width<420
    @sprites["locwindow"].height=344
    @sprites["locwindow"].visible=true
    main
  end

  def pbStartMenu # honestly Im almost certain this doesnt even do anything. just edit above.
    getEncData
    # Following variable is unused, but can be a good sub in if you need it
    textColor = ["0070F8,78B8E8","E82010,F8A8B8","0070F8,78B8E8"][$Trainer.gender]

    loctext = _INTL("<ac><c2=06644bd2>{1}</c2></ac>", $game_map.name)
    temparray = @encarray.dup
    if temparray.pop==7  # i picked 7 cause funny
      loctext += sprintf("<al><c2=7FF05EE8>This area has no encounters</c2></al>")
      loctext += sprintf("<c2=63184210>-------------------------------------</c2>")
    else
      @encarray.each do |specie|
      loctext += _INTL("<ac><c2=7FFF5EF7>{1}</c2></ac>",PBSpecies.getName(specie))
      end
    end
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
      @encarray = pbListOfEncounters(enctypes)
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
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::C) || Input.trigger?(Input::B)
        break
      end
    end
    dispose
  end

  def dispose
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @viewport2.dispose
  end
end
