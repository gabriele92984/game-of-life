class GameOfLife
  def initialize
    @pattern_files = Dir.glob('patterns/*.txt')
    @grid = load_grid(select_pattern)
    @generation = 0
  end

  def start_simulation
    50.times do
      system('clear') || system('cls')
      display
      next_generation
      sleep(0.5)
    end
  end

  private

  def select_pattern
    puts "\nAvailable patterns:"
    @pattern_files.each_with_index do |file, index|
      puts "#{index + 1}. #{File.basename(file)}"
    end

    choice = 0
    until choice.between?(1, @pattern_files.size)
      print "\nSelect a pattern (1-#{@pattern_files.size}): "
      choice = gets.chomp.to_i
    end
    @pattern_files[choice - 1]
  end

  def display
    puts "Generation #{@generation}"
    @grid.each do |row|
      puts row.map { |cell| cell == 1 ? '■' : ' ' }.join(' ')
    end
  end

  def next_generation
    new_grid = Array.new(@grid.size) { Array.new(@grid[0].size, 0) }
    @grid.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        neighbors = count_neighbors(i, j)
        new_grid[i][j] = cell == 1 ? [2, 3].include?(neighbors) ? 1 : 0 : neighbors == 3 ? 1 : 0
      end
    end
    @grid = new_grid
    @generation += 1
  end

  def count_neighbors(x, y)
    count = 0
    (-1..1).each do |i|
      (-1..1).each do |j|
        next if i == 0 && j == 0
        xi, yj = x + i, y + j
        count += @grid[xi][yj] if xi.between?(0, @grid.size-1) && yj.between?(0, @grid[0].size-1)
      end
    end
    count
  end

  def load_grid(path)
    lines = File.readlines(path).map(&:chomp)
    lines.map { |line| line.chars.map { |c| c == '*' ? 1 : 0 } }
  end
end

if __FILE__ == $0
  GameOfLife.new.start_simulation
end
