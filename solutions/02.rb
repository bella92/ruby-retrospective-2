class Song
  attr_accessor :name, :artist, :album

  def initialize(name, artist, album)
    @name, @artist, @album = name, artist, album
  end
end

class Collection
  include Enumerable

  attr_accessor :songs

  def initialize(songs)
    @songs = songs
  end

  def each
    @songs.each { |song| yield song }
  end

  def self.parse(text)
    parsed_songs = text.split("\n").each_slice(4).map do |name, artist, album|
      Song.new(name, artist, album)
    end
    Collection.new(parsed_songs)
  end

  def names
    @songs.map(&:name).uniq
  end

  def artists
    @songs.map(&:artist).uniq
  end

  def albums
    @songs.map(&:album).uniq
  end

  def filter(criteria)
    Collection.new(@songs.select { |song| criteria.meets?(song) })
  end

  def adjoin(collection)
    Collection.new(@songs | collection.songs)
  end
end

class Criteria
  def initialize(&selector)
    @selector = selector
  end

  def meets?(song)
    @selector.call(song)
  end

  class << self
    def name(request)
      Criteria.new { |song| request == song.name }
    end

    def artist(request)
      Criteria.new { |song| request == song.artist }
    end

    def album(request)
      Criteria.new { |song| request == song.album }
    end
  end

    def &(other)
    Criteria.new { |song| meets?(song) & other.meets?(song) }
  end

  def |(other)
    Criteria.new { |song| meets?(song) | other.meets?(song) }
  end

  def !
    Criteria.new { |song| !meets?(song) }
  end
end