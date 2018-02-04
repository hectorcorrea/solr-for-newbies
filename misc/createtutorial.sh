# Create a new file with the outline
ruby ./misc/createoutline.rb > ./docs/00_outline.md

# Regenerates a single tutorial.md from the invidivual files
cat ./docs/*.md > tutorial.md
