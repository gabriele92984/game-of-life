$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'game_of_life'

RSpec.describe GameOfLife do
  class TestGame < GameOfLife
    def initialize(pattern_path)
      @pattern_files = [pattern_path]
      @grid = load_grid(pattern_path)
      @generation = 0
    end
  end

  describe "File Input" do
    it "loads valid patterns" do
      game = TestGame.new('patterns/glider.txt')
      expect(game.instance_variable_get(:@grid)).to be_a(Array)
    end

    it "rejects files with invalid characters" do
      invalid_pattern = StringIO.new("*X*\n...")
      allow(File).to receive(:readlines).and_return(invalid_pattern)
      
      expect { TestGame.new('bad.txt') }.to raise_error(/Invalid characters/)
    end

    it "requires uniform row lengths" do
      uneven_pattern = StringIO.new(".*.\n**")
      allow(File).to receive(:readlines).and_return(uneven_pattern)
      
      expect { TestGame.new('uneven.txt') }.to raise_error(/same length/)
    end
  end

  describe "Game Logic" do
    before do
      @game = TestGame.new('patterns/glider.txt')
      # Test pattern that gives predictable results
      @game.instance_variable_set(:@grid, [
        [0, 1, 0, 0],
        [1, 0, 1, 0],
        [0, 1, 0, 0],
        [0, 0, 0, 0]
      ])
    end

    it "counts neighbors with edge wrapping" do
      # Center cell (1,1) has 4 neighbors
      expect(@game.send(:count_neighbors, 1, 1)).to eq(4)
      # Top-left corner (0,0) wraps to bottom-right
      expect(@game.send(:count_neighbors, 0, 0)).to eq(2)
    end

    it "updates grid correctly" do
      @game.send(:next_generation)
      expect(@game.instance_variable_get(:@grid)).to eq([
        [0, 1, 0, 0],
        [1, 0, 1, 0],
        [0, 1, 0, 0],
        [0, 0, 0, 0]
      ])
    end
  end
end
