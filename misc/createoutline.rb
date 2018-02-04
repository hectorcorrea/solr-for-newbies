# Creates the outline from the individual markdown files
files = Dir["./docs/*.md"]
files.sort!

def link_text(text)
  # remove non alphabetical
  text.downcase.gsub("'", "").scan(/\w+/).join("-")
end

def markdown_link(text)
  text = text.gsub("\r", "").gsub("\n","")
  "[" + text + "](#" + link_text(text) + ")"
end

puts "Tutorial Outline"
puts ""
files.each do |file|
  File.readlines(file).each do |line|
    if line.start_with?("# ")
      puts ""
      puts ""
      puts "* " + markdown_link(line[2..-1])
    elsif line.start_with?("## ")
      puts "  * " + markdown_link(line[3..-1])
    elsif line.start_with?("### ")
      puts "    * " + markdown_link(line[4..-1])
    end
  end
end

puts ""
puts ""
