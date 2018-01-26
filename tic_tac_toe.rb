class Board

  attr_accessor :cases
  def initialize
    @cases = []                                                                                                 #L'Array @cases contiendra l'ensemble des BoardCases, ajoutées ligne suivante.
    9.times {|x| @cases << instance_variable_set("@case#{x+1}", BoardCase.new(x+1, (x/3.to_i+1), ((x%3)+1))) }  #Instancie 9 variables contenant des instances de BoardCase avec pour noms @caseX. Génère les coordonnées.
  end
  def set_case(x, char)
    eval("@case#{x}.state = char")                                                                              #Rempli la case donnée par le char choisi en début de partie
  end
  def check_win(a_case, player)                                                                                 #Récupération des diagonales et de la ligne et de la colonne de la case jouée
    hash_case = @cases.group_by {|c| c.coo[0] == c.coo[1] }
    diag1 = hash_case[true].to_a
    hash_case = @cases.group_by {|c| c.coo[0] + c.coo[1] == 4 }
    diag2 = hash_case[true].to_a
    hash_case = @cases.group_by {|c| c.coo[0] == ((a_case.to_i-1)/3.to_i+1) }
    line = hash_case[true].to_a
    hash_case = @cases.group_by {|c| c.coo[1]%3 == (a_case.to_i%3) }
    column = hash_case[true].to_a
    return player.name if is_full?(column) || is_full?(line) || is_full?(diag1) || is_full?(diag2)              #Return du winner si une combinaison est gagnante.
    return nil                                                                                                  #Sinon, return nil.
  end
  def is_full?(obj)
    obj[0].state == obj[1].state && obj[0].state == obj[2].state && obj[0].state != " "                         #Vérification: Cette combinaison est-elle gagnante?
  end
  def gui(x=0)
    system "clear"
    Menuing.gui_head
    puts "                                *************"                                                        #Affichage du GUI
    puts "                                _____________"
    puts "                                |   |   |   |"
    puts "                                | #{@case1.state} | #{@case2.state} | #{@case3.state} |"
    puts "                                |___|___|___|"
    puts "                                |   |   |   |"
    puts "                                | #{@case4.state} | #{@case5.state} | #{@case6.state} |"
    puts "                                |___|___|___|"
    puts "                                |   |   |   |"
    puts "                                | #{@case7.state} | #{@case8.state} | #{@case9.state} |"
    puts "                                |___|___|___|"
    puts ""
    puts "                                *************"
    puts ""
    puts "                                  Player  #{x}" unless x = 0
  end

end

class BoardCase

  attr_accessor :state, :name, :coo
  def initialize(num, x, y)
    @name = num
    @coo = [x, y]
    @state = " "
  end

end

class Player

  attr_reader :name, :sym
  @@group = []                                                #@@group est un Array contenant l'intégralité des joueurs.
  def initialize(num)
    puts "Name of player#{num}?"                              #Initialise les joueurs avec un nom et un char quelconque
    @name = gets.chomp
    puts "What symbol do you use?"
    @sym = gets.chomp
    @@group << self
  end
  def self.group
    @@group
  end

end

class Game

  def initialize
    board = Board.new                                                                  #Creation du board
    nb_player = 2
    nb_player.times {|x| instance_variable_set("@player#{x+1}", Player.new(x+1))}      #Creation des joueurs (scalable)
    turner = Player.group                                                              #Turner est ma "timeline", me permettant de dire de quel joueur c'est le tour.
    finish_screen(launch_game(board, turner), board)                                   #Lance le finish_screen avec comme valeur de "winner" le résultat renvoyé par l'appel de launch_game. 
  end
  def launch_game(board, turner)
    winner = nil
    case_turn = 0 
    while true                                                                         #Boucle infinie
      y = 1
      turner.each {|actual_player|                                                     #On enclenche la Timeline. Pour chaque joueur:
        board.gui(y)                                                                   #On affiche la GUI
        free_cases = []
        board.cases.each {|x| free_cases << x.name.to_s if x.state == " " }            #On mets dans free_cases toutes les cases dont la valeur est " "
        return "nul" if free_cases.length == 0                                         #On renvoies "nul" comme Winner si il n'y a plus de cases vide.
        until free?(case_turn, free_cases)                                             #Tant que la case séléctionnée n'est pas libre:
          puts "#{actual_player.name}, What case do you choose?"
          puts ""
          puts "Number from 1 to 9 (1,2,3,"
          puts "                    4,5,6,"
          puts "                    7,8,9)"
          case_turn = gets.chomp                                                       #On demande quelle case sélectionner.
          puts "Enter the number of a free case." unless free?(case_turn, free_cases)
        end
        board.set_case(case_turn, actual_player.sym)                                   #On actualise le statut de la case sélectionnée.
        winner = board.check_win(case_turn, actual_player)                             #Le winner devient le résultat de l'appel de la fonction check_win.
        y += 1
        return winner unless winner == nil                                             #On sort de la boucle si et seulement si il y'a un gagnant.
      }
    end
  end
  def free?(case_turn, free_cases)                                                     #Pour vérifier si une case est libre:
    free_cases.each {|x| return true if case_turn == x }                               #On itère chaque case libre et on check si elle est égale a la case actuelle.
    false                                                                              #Si aucun check ne passe on renvoie false.
  end
  def finish_screen(winner, board)
    board.gui
    puts "#{winner} win."
    gets.chomp
  end

end

class Menuing

  def initialize
    while true
      system "clear"
      Menuing.gui_head
      puts "What do you want to do?"
      puts "1) Play a game"
      puts "2) Know the rules"
      puts "3) Have Tips"
      puts "4) Exit this shitty game"
      choice = gets.chomp
      case choice
      when "1"
        Game.new
      when "2"
        puts "You need to align 3 of your char in a row. Com' ooon, you really don't know it?"
        gets.chomp
      when "3"
        system "clear"
        puts "\n\n\n\n\n\n\n\n\n\n\n\n"
        puts "             ******* for have the best game experience possible, i provide you some very nice tips:\n\n"
        puts "                          1). Prepare you a drink and some junky food. This game is very strategic and some plays can be very long.\n\n"
        puts "                          2). Take care to painstakingly apply the tip n°2!\n\n"
        puts "                          3). Never forget: the essential thing is not to have won, but to have humiliate your opponent well.\n\n"
        puts "                          3). And the MOST IMPORTANT part: rm this file, go to RELOADED or SKYDROW and download a real strategy game. Fuck this shit.\n\n"
        gets.chomp
      when "4"
        system "clear"
        puts "\n \n \n \n \n \n \n \n \n \n \n \n"
        puts "Shitty? DO YOU THINK I'M A FUCKING JOKE??? You will NEVER LEAVE THIS GAME HAHAHAHAHAHAHAHAHA"
        gets.chomp
      else
        puts "Sorry i can't understand when DUMMIES write a MOTHERFUCKING WRONG INPUT"
        puts "Press Enter for retry more correctly, asshole."
        gets.chomp
      end
    end
  end

  def self.gui_head                                                                                   #Header général
    puts "***___      ___    ___     _____    ____    _______     ___     __     _ ***        "
    puts "   |  \\    /  |   /   \\   |  _  \\  |  _ \\  |__   __|   /   \\   |  \\   | |           "
    puts "   |   \\  /   |  /     \\  | | | |  | | \\ \\    | |     /     \\  |   \\  | |      _    "
    puts "   |    \\/    | |   _   | | |_| /  | |_/ |    | |    |   _   | |    \\ | |     | |   "
    puts "   | |\\    /| | |  |_|  | |    /   |  __/     | |    |  |_|  | | |\\  \\| |     |_|   " 
    puts "   | | \\__/ | | |       | | |\\ \\   | |        | |    |       | | | \\    |      _    "
    puts "   | |      | |  \\     /  | | \\ \\  | |      __| |__   \\     /  | |  \\   |     | |   "
    puts "   |_|      |_|   \\___/   |_|  \\_\\ |_|     |_______|   \\___/   |_|   \\__|     |_|   "
    puts ""
    puts ""
    puts "                               THE ONLY TRUE REAL"
    puts "                                                              (Yeah, it's on your screen!)"
    puts "                                                              (Amazing, hmm?)"
  end

end


Menuing.new
