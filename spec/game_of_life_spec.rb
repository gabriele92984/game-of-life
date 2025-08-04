# spec/game_of_life_spec.rb
$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'game_of_life'

RSpec.describe GameOfLife do
  # Test patterns directory (matches your structure)
  PATTERNS_DIR = File.expand_path('../patterns', __dir__)

  # Helper to create temporary test patterns
  def with_test_pattern(content)
    path = File.join(__dir__, 'test_pattern.txt')
    File.write(path, content)
    yield path
  ensure
    File.delete(path) if File.exist?(path)
  end

  # Testable version that bypasses user input
  class TestGame < GameOfLife
    def initialize(pattern_path)
      @pattern_files = [pattern_path]
      @grid = load_grid(pattern_path)
      @generation = 0
    end
  end

  describe "File Input" do
    it "loads valid patterns from patterns directory" do
      game = TestGame.new(File.join(PATTERNS_DIR, 'glider.txt'))
      expect(game.instance_variable_get(:@grid)).to be_a(Array)
    end

    it "rejects files with invalid characters" do
      with_test_pattern("*X*\n...") do |path|
        expect { TestGame.new(path) }.to raise_error(/Invalid/)
      end
    end

    it "requires uniform row lengths" do
      with_test_pattern(".*\n***") do |path|
        expect { TestGame.new(path) }.to raise_error(/Uneven/)
      end
    end
  end

  describe "Game Logic" do
    before do
      @game = TestGame.new(File.join(PATTERNS_DIR, 'glider.txt'))
      @game.instance_variable_set(:@grid, [
        [0, 1, 0],
        [1, 1, 1],
        [0, 1, 0]
      ])
    end

    it "counts neighbors with edge wrapping" do
      expect(@game.send(:count_neighbors, 0, 0)).to eq(3)
      expect(@game.send(:count_neighbors, 1, 1)).to eq(4)
    end

    it "updates grid correctly" do
      @game.send(:next_generation)
      expect(@game.instance_variable_get(:@grid)).to eq([
        [1, 1, 1],
        [1, 0, 1],
        [1, 1, 1]
      ])
    end
  end
end