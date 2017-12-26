# Author: Dominik Harmim <xharmi00@stud.fit.vutbr.cz>

PROJ = xharmi00

INC_DIR = inc


$(PROJ).pdf: $(PROJ).tex
	pdflatex $<
	pdflatex $<


.PHONY: clean
clean:
	rm -f $(PROJ).aux $(PROJ).dvi $(PROJ).log $(PROJ).ps $(PROJ).synctex.gz \
		$(PROJ).fls $(PROJ).fdb_latexmk $(PROJ).bbl $(PROJ).blg $(PROJ).out \
		$(INC_DIR)/*-eps-converted-to* $(PROJ).toc
