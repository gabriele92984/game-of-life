class GameOfLife
  def initialize
    @pattern_files = Dir.glob('patterns/*.txt')
    @grid = load_grid(select_pattern)
    @generation = 0
  end

  def start_simulation
    hide_cursor
    50.times do
      system('clear') || system('cls')
      display
      next_generation
      sleep(0.5)
    end
  ensure
    show_cursor
    puts "\nSimulation ended. Cursor restored."
  end

  private

  # Hide cursor (ANSI escape code)
  def hide_cursor
    print "\e[?25l"
  end

  # Show cursor (ANSI escape code)
  def show_cursor
    print "\e[?25h"
  end

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
    system('clear') || system('cls')
    puts "Generation #{@generation}"
    display_grid_size

    @grid.each do |row|
      puts row.map { |cell| cell == 1 ? '■' : ' ' }.join(' ')
    end
  end

  def display_grid_size
    rows = @grid.size
    cols = rows.positive? ? @grid[0].size : 0
    puts "Grid: #{rows}x#{cols} cells"
  end

  def next_generation
    new_grid = Array.new(@grid.size) { Array.new(@grid[0].size, 0) }

    @grid.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        neighbors = count_neighbors(i, j)

        # Standard Conway rules
        new_grid[i][j] = if cell == 1
                           neighbors.between?(2, 3) ? 1 : 0
                         else
                           neighbors == 3 ? 1 : 0
                         end
      end
    end

    @grid = new_grid
    @generation += 1
  end

  def count_neighbors(x, y)
    count = 0
    rows = @grid.size
    cols = @grid[0].size

    (-1..1).each do |i|
      (-1..1).each do |j|
        next if i == 0 && j == 0 # Skip the cell itself

        # Wrap around using modulo
        xi = (x + i) % rows
        yj = (y + j) % cols

        count += @grid[xi][yj]
      end
    end
    count
  end

  def load_grid(path)
    lines = File.readlines(path).map(&:chomp)

    # Add validation
    raise 'Empty pattern file' if lines.empty?

    lines.each do |line|
      raise "Invalid characters in pattern. Only '.' and '*' allowed" unless line.match?(/^[.*]+$/)
    end

    # Check for consistent line lengths
    raise 'All lines in pattern must have the same length' if lines.any? { |line| line.length != lines.first.length }

    lines.map { |line| line.chars.map { |c| c == '*' ? 1 : 0 } }
  end
end

# Execution flow
if __FILE__ == $0
  begin
    GameOfLife.new.start_simulation
  rescue StandardError => e
    puts "Error: #{e.message}"
    exit 1
  end
end
