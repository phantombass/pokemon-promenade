module LvlCap
  Switch = 111               #Switch that turns on Trainer Difficulty Control
  LevelCap = 106             #Variable for the Level Cap
  Gym = 70                   #Switch for Gym Battles
  Rival = 69                 #Switch for Rival Battles
  LvlTrainer = 83
  Rival2 = 85
  Elite4 = 86
  Ace = 129                  #Switch for Ace Trainer Battles
  Guardian = 189
end

class Level_Scaling
  def self.activate
    $game_switches[LvlCap::Switch] = true
  end

  def self.level_cap
    return LEVEL_CAP[$game_system.level_cap]
  end

  def self.gym
    $game_switches[LvlCap::Gym] = true
  end

  def self.guardian
    $game_switches[LvlCap::Guardian] = true
  end

  def self.ace
    $game_switches[LvlCap::Ace] = true
  end

  def self.rival
    $game_switches[LvlCap::Rival] = true
  end

  def self.rival2
    $game_switches[LvlCap::Rival2] = true
  end

  def self.elite4
    $game_switches[LvlCap::Elite4] = true
  end

  def self.end_battle
    switches = [69,70,83,85,86,129,189]
    switches.each {|switch| $game_switches[switch] = false}
  end

  def self.trainer_max_level
    return $Trainer.party.map { |e| e.level  }.max
  end

  def self.reset_moves?
    return ($game_switches[LvlCap::Gym] == false && $game_switches[LvlCap::Ace] == false &&
      $game_switches[LvlCap::LvlTrainer] == false && $game_switches[LvlCap::Guardian] == false &&
      $game_switches[LvlCap::Rival2] == false && $game_switches[LvlCap::Rival] == false)
  end

end

Events.onTrainerPartyLoad+=proc {| sender, trainer |
   if trainer # Trainer data should exist to be loaded, but may not exist somehow
     party = trainer[0].party   # An array of the trainer's Pokémon
    if $game_switches && $game_switches[LvlCap::Switch] && $Trainer
       levelcap = Level_Scaling.level_cap
       badges = $Trainer.badge_count
       mlv = Level_Scaling.trainer_max_level
      for i in 0...party.length
        level = 0
        level=1 if level<1
        if $game_switches[LvlCap::Gym]
          level = levelcap - rand(1)
        elsif $game_switches[LvlCap::Elite4]
          level = levelcap
        elsif $game_switches[LvlCap::Rival2]
          level = party[i].level
        elsif $game_switches[LvlCap::Rival] && badges == 0
          level = mlv <= 5 ? 5 : levelcap
        elsif $game_switches[LvlCap::Rival] && badges > 0
          level = mlv - rand(1)
        elsif $game_switches[LvlCap::Ace]
          level = mlv - 1 - rand(1)
        elsif $game_switches[LvlCap::Guardian]
          level = party[i].level
        elsif $game_switches[LvlCap::LvlTrainer]
          level =  mlv - 5
        else
          level = mlv - 2 - rand(4)
        end
        level = 1 if level < 1
        party[i].level = level
        party[i].calc_stats
        if Level_Scaling.reset_moves?
          party[i].reset_moves
        end
      end #end of for
     end
    end
}
