require "spec_helper"

describe "MusicLibraryController" do
  describe "#initialize" do
    it "accepts one argument, the path to the MP3 files to be imported" do
      expect{ MusicLibraryController.new("./spec/fixtures/mp3s") }.to_not raise_error
    end

    it "creates a new MusicImporter object, passing in the 'path' value" do
      expect(MusicImporter).to receive(:new).with("./spec/fixtures/mp3s").and_return(double(MusicImporter, import: true))

      MusicLibraryController.new("./spec/fixtures/mp3s")
    end

    it "the 'path' argument defaults to './db/mp3s'" do
      expect(MusicImporter).to receive(:new).with("./db/mp3s").and_return(double(MusicImporter, import: true))

      MusicLibraryController.new
    end

    it "invokes the #import method on the created MusicImporter object" do
      music_importer = MusicImporter.new("./spec/fixtures/mp3s")

      expect(MusicImporter).to receive(:new).and_return(music_importer)
      expect(music_importer).to receive(:import)

      MusicLibraryController.new
    end
  end

  describe "#call" do
    let(:music_library_controller) { MusicLibraryController.new("./spec/fixtures/mp3s") }

    it "welcomes the user" do
      allow(music_library_controller).to receive(:gets).and_return("exit")

      expect($stdout).to receive(:puts).with("Welcome to your music library!")
      expect($stdout).to receive(:puts).with("To list all of your songs, enter 'list songs'.")
      expect($stdout).to receive(:puts).with("To list all of the artists in your library, enter 'list artists'.")
      expect($stdout).to receive(:puts).with("To list all of the genres in your library, enter 'list genres'.")
      expect($stdout).to receive(:puts).with("To list all of the songs by a particular artist, enter 'list artist'.")
      expect($stdout).to receive(:puts).with("To list all of the songs of a particular genre, enter 'list genre'.")
      expect($stdout).to receive(:puts).with("To play a song, enter 'play song'.")
      expect($stdout).to receive(:puts).with("To quit, type 'exit'.")
      expect($stdout).to receive(:puts).with("What would you like to do?")

      music_library_controller.call
    end

    it "asks the user for input" do
      allow(music_library_controller).to receive(:gets).and_return("exit")

      expect(music_library_controller).to receive(:gets)

      capture_puts { music_library_controller.call }
    end

    it "loops and asks for user input until they type in exit" do
      allow(music_library_controller).to receive(:gets).and_return("a", "b", "c", "exit")

      expect(music_library_controller).to receive(:gets).exactly(4).times

      capture_puts { music_library_controller.call }
    end
  end
end

class MusicLibraryController

  def initialize(path = "./db/mp3s")
    MusicImporter.new(path).import
  end

  def call
    input = ""
    until input == "exit"
      input = gets
      case input
      when "list songs"
        list_songs
      when "list artists" 
        list_artists
      when "list genres"
        list_genres
      when "play song"
        play_song
      when "list artist"
        list_artist
      when "list genre"
        list_genre
      when "exit"
        puts "Goodbye" 
      end
    end
  end

  def list_songs
    Song.all.each_with_index {|song,index|puts "#{index+1}. #{song.artist.name} - #{song.name} - #{song.genre.name}"}
  end

  def list_artists
    Artist.all.each {|artist| puts artist.name}
  end

  def list_genres
    Genre.all.each {|genre| puts genre.name}
  end

  def play_song
    song = Song.all[gets.to_i - 1]
    puts "Playing #{song.artist.name} - #{song.name} - #{song.genre.name}"
  end

  def list_artist
    specific_artist = gets
    puts Artist.find_by_name(specific_artist).songs.each {|song| puts "#{song.artist.name} - #{song.name} - #{song.genre.name}"}
  end

  def list_genre
    specific_genre = gets
    puts Genre.find_by_name(specific_genre).songs.each {|song| puts "#{song.artist.name} - #{song.name} - #{song.genre.name}"}
  end

end 