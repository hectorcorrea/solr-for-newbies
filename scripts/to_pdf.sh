# Creates a PDF version of tutorial.md 
# via pandoc and wkhtmltopdf.

# Convert the markdown file to HTML
# https://pandoc.org/MANUAL.html
#
pandoc tutorial.md \
-f markdown \
-t html -s -o tutorial.html \
--toc \
--include-before-body=cover_page.html \
--metadata pagetitle="Solr for newbies workshop"

# Convert the HTML file to PDF
# https://wkhtmltopdf.org/usage/wkhtmltopdf.txt
#
wkhtmltopdf \
--footer-line \
--footer-left "Solr for newbies workshop" \
--footer-right "[page]/[toPage]" \
--footer-spacing 20 \
--margin-top 15 \
--margin-left 15 \
--margin-bottom 30 \
--margin-right 15 \
--dpi 120 \
tutorial.html tutorial.pdf

# Other settings that I tried
#
# --dpi 200 \
# --zoom 1.3 \
# --disable-smart-shrinking \
# --print-media-type \
# --lowquality \
# --page-size Letter \
#

