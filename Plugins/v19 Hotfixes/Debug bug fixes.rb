#==============================================================================
# "v19 Hotfixes" plugin
# This file contains fixes for bugs relating to Debug features or compiling.
# These bug fixes are also in the master branch of the GitHub version of
# Essentials:
# https://github.com/Maruno17/pokemon-essentials
#==============================================================================



#==============================================================================
# Fix for crash when trying to edit a map's weather metadata.
#==============================================================================
module WeatherEffectProperty
  def self.set(_settingname,oldsetting)
    oldsetting = [:None, 100] if !oldsetting
    options = []
    ids = []
    default = 0
    GameData::Weather.each do |w|
      default = ids.length if w.id == oldsetting[0]
      options.push(w.real_name)
      ids.push(w.id)
    end
    cmd = pbMessage(_INTL("Choose a weather effect."), options, -1, nil, default)
    return nil if cmd < 0 || ids[cmd] == :None
    params = ChooseNumberParams.new
    params.setRange(0, 100)
    params.setDefaultValue(oldsetting[1])
    number = pbMessageChooseNumber(_INTL("Set the probability of the weather."), params)
    return [ids[cmd], number]
  end
end

#==============================================================================
# Fix for crash when trying to save tileset terrain tags in the Debug function
# "Edit Terrain Tags".
#==============================================================================
class PokemonTilesetScene
  def pbStartScene
    pbFadeInAndShow(@sprites)
    loop do
      Graphics.update
      Input.update
      if Input.repeat?(Input::UP)
        update_cursor_position(0, -1)
      elsif Input.repeat?(Input::DOWN)
        update_cursor_position(0, 1)
      elsif Input.repeat?(Input::LEFT)
        update_cursor_position(-1, 0)
      elsif Input.repeat?(Input::RIGHT)
        update_cursor_position(1, 0)
      elsif Input.repeat?(Input::JUMPUP)
        update_cursor_position(0, -Graphics.height / TILE_SIZE)
      elsif Input.repeat?(Input::JUMPDOWN)
        update_cursor_position(0, Graphics.height / TILE_SIZE)
      elsif Input.trigger?(Input::ACTION)
        commands = [
           _INTL("Go to bottom"),
           _INTL("Go to top"),
           _INTL("Change tileset"),
           _INTL("Cancel")
        ]
        case pbShowCommands(nil,commands,-1)
        when 0
          @y = @height - TILE_SIZE
          @topy = @y - Graphics.height + TILE_SIZE if @y - @topy >= Graphics.height
          pbUpdateTileset
        when 1
          @y = -TILE_SIZE
          @topy = @y if @y < @topy
          pbUpdateTileset
        when 2
          pbChooseTileset
        end
      elsif Input.trigger?(Input::BACK)
        if pbConfirmMessage(_INTL("Save changes?"))
          save_data(@tilesets_data, "Data/Tilesets.rxdata")
          $data_tilesets = @tilesets_data
          if $game_map && $MapFactory
            $MapFactory.setup($game_map.map_id)
            $game_player.center($game_player.x, $game_player.y)
            if $scene.is_a?(Scene_Map)
              $scene.disposeSpritesets
              $scene.createSpritesets
            end
          end
          pbMessage(_INTL("To ensure that the changes remain, close and reopen RPG Maker XP."))
        end
        break if pbConfirmMessage(_INTL("Exit from the editor?"))
      elsif Input.trigger?(Input::USE)
        selected = pbGetSelected(@x, @y)
        params = ChooseNumberParams.new
        params.setRange(0, 99)
        params.setDefaultValue(@tileset.terrain_tags[selected])
        pbSetSelected(selected,pbMessageChooseNumber(_INTL("Set the terrain tag."), params))
        pbUpdateTileset
      end
    end
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @tilehelper.dispose
  end
end

#==============================================================================
# Fix for crash when trying to use the Debug function "Fix Invalid Tiles".
#==============================================================================
def pbDebugFixInvalidTiles
  num_errors = 0
  num_error_maps = 0
  tilesets = $data_tilesets
  mapData = Compiler::MapData.new
  t = Time.now.to_i
  Graphics.update
  for id in mapData.mapinfos.keys.sort
    if Time.now.to_i - t >= 5
      Graphics.update
      t = Time.now.to_i
    end
    changed = false
    map = mapData.getMap(id)
    next if !map || !mapData.mapinfos[id]
    pbSetWindowText(_INTL("Processing map {1} ({2})", id, mapData.mapinfos[id].name))
    passages = mapData.getTilesetPassages(map, id)
    # Check all tiles in map for non-existent tiles
    for x in 0...map.data.xsize
      for y in 0...map.data.ysize
        for i in 0...map.data.zsize
          tile_id = map.data[x, y, i]
          next if pbCheckTileValidity(tile_id, map, tilesets, passages)
          map.data[x, y, i] = 0
          changed = true
          num_errors += 1
        end
      end
    end
    # Check all events in map for page graphics using a non-existent tile
    for key in map.events.keys
      event = map.events[key]
      for page in event.pages
        next if page.graphic.tile_id <= 0
        next if pbCheckTileValidity(page.graphic.tile_id, map, tilesets, passages)
        page.graphic.tile_id = 0
        changed = true
        num_errors += 1
      end
    end
    next if !changed
    # Map was changed; save it
    num_error_maps += 1
    mapData.saveMap(id)
  end
  if num_error_maps == 0
    pbMessage(_INTL("No invalid tiles were found."))
  else
    pbMessage(_INTL("{1} error(s) were found across {2} map(s) and fixed.", num_errors, num_error_maps))
    pbMessage(_INTL("Close RPG Maker XP to ensure the changes are applied properly."))
  end
end

#==============================================================================
# Fix for the "Give Demo Party" Debug feature adding Pokémon without clearing
# the party first, and potentially resulting in more than the maximum number of
# Pokémon allowed in the party.
#==============================================================================
DebugMenuCommands.register("demoparty", {
  "parent"      => "pokemonmenu",
  "name"        => _INTL("Give Demo Party"),
  "description" => _INTL("Give yourself 6 preset Pokémon. They overwrite the current party."),
  "effect"      => proc {
    party = []
    species = [:PIKACHU, :PIDGEOTTO, :KADABRA, :GYARADOS, :DIGLETT, :CHANSEY]
    for id in species
      party.push(id) if GameData::Species.exists?(id)
    end
    $Trainer.party.clear
    # Generate Pokémon of each species at level 20
    party.each do |species|
      pkmn = Pokemon.new(species, 20)
      $Trainer.party.push(pkmn)
      $Trainer.pokedex.register(pkmn)
      $Trainer.pokedex.set_owned(species)
      case species
      when :PIDGEOTTO
        pkmn.learn_move(:FLY)
      when :KADABRA
        pkmn.learn_move(:FLASH)
        pkmn.learn_move(:TELEPORT)
      when :GYARADOS
        pkmn.learn_move(:SURF)
        pkmn.learn_move(:DIVE)
        pkmn.learn_move(:WATERFALL)
      when :DIGLETT
        pkmn.learn_move(:DIG)
        pkmn.learn_move(:CUT)
        pkmn.learn_move(:HEADBUTT)
        pkmn.learn_move(:ROCKSMASH)
      when :CHANSEY
        pkmn.learn_move(:SOFTBOILED)
        pkmn.learn_move(:STRENGTH)
        pkmn.learn_move(:SWEETSCENT)
      end
      pkmn.record_first_moves
    end
    pbMessage(_INTL("Filled party with demo Pokémon."))
  }
})

#==============================================================================
# Fix for the Pokémon icon mover/renamer not moving shiny Pokémon icons into
# the correct folder.
#==============================================================================
module Compiler
  module_function

  def convert_pokemon_filename(full_name, default_prefix = "")
    name = full_name
    extension = nil
    if full_name[/^(.+)\.([^\.]+)$/]   # Of the format something.abc
      name = $~[1]
      extension = $~[2]
    end
    prefix = default_prefix
    form = female = shadow = crack = ""
    if default_prefix == ""
      if name[/s/] && !name[/shadow/]
        prefix = (name[/b/]) ? "Back shiny/" : "Front shiny/"
      else
        prefix = (name[/b/]) ? "Back/" : "Front/"
      end
    elsif default_prefix == "Icons/"
      prefix = "Icons shiny/" if name[/s/] && !name[/shadow/]
    end
    if name[/000/]
      species = "000"
    else
      species_number = name[0, 3].to_i
      species_data = GameData::Species.try_get(species_number)
      raise _INTL("Species {1} is not defined (trying to rename Pokémon graphic {2}).", species_number, full_name) if !species_data
      species = species_data.id.to_s
      form = "_" + $~[1].to_s if name[/_(\d+)/]
      female = "_female" if name[/f/]
      shadow = "_shadow" if name[/_shadow/]
      if name[/egg/]
        prefix = "Eggs/"
        crack = "_icon" if default_prefix == "Icons/"
        crack = "_cracks" if name[/eggCracks/]
      end
    end
    return prefix + species + form + female + shadow + crack + ((extension) ? "." + extension : ".png")
  end
end

