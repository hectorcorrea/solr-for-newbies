# Creates a PDF version of tutorial.md 
# via pandoc and wkhtmltopdf.

# Convert the markdown file to HTML
# https://pandoc.org/MANUAL.html
#
pandoc tutorial.md \
-f markdown \
-t html -s -o tutorial.html \
--toc \
--include-before-body=doc_header.html \
--metadata pagetitle="Solr for newbies"

# Convert the HTML file to PDF
# https://wkhtmltopdf.org/usage/wkhtmltopdf.txt
#
wkhtmltopdf \
--footer-line \
--footer-left "Solr for newbies" \
--footer-right "[page]/[toPage]" \
--footer-spacing 20 \
--margin-top 20 \
--margin-left 20 \
--margin-bottom 40 \
--margin-right 20 \
tutorial.html tutorial.pdf


