# Creates a PDF version of tutorial.md 
# via pandoc and wkhtmltopdf.

# Convert the markdown file to HTML
# https://pandoc.org/MANUAL.html
#
pandoc workshop.md \
-f markdown \
-t html -s -o workshop.html \
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
--margin-top 20 \
--margin-left 20 \
--margin-bottom 40 \
--margin-right 20 \
workshop.html workshop.pdf


