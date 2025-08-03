# lib/game.rb
class GameOfLife
  def initialize(path)
    @grid = load_grid(path)
    @generation = 0
  end

  private

  # Load and convert pattern file
  def load_grid(path)
    lines = read_lines(path)
    validate_lines(lines)
    lines.map { |line| convert_line(line) }
  end

  # Read file with basic checks
  def read_lines(path)
    raise "File missing: #{path}" unless File.exist?(path)
    lines = File.readlines(path).map(&:chomp)
    raise "File empty" if lines.empty?
    lines
  end

  # Validate pattern format
  def validate_lines(lines)
    lines.each do |line|
      unless valid_line?(line)
        raise "Invalid line: #{line.inspect}"
      end
    end
    validate_lengths(lines)
  end

  # Check line characters
  def valid_line?(line)
    line.match?(/^[.*]+$/)
  end

  # Validate uniform lengths
  def validate_lengths(lines)
    first_length = lines.first.length
    lines.each do |line|
      unless line.length == first_length
        raise "Uneven line lengths"
      end
    end
  end

  # Convert symbols to numbers
  def convert_line(line)
    line.chars.map do |char|
      char == '*' ? 1 : 0
    end
  end
end

begin
  game = GameOfLife.new("patterns/glider.txt")
rescue => e
  puts "ERROR: #{e.message}"
  exit 1
end
