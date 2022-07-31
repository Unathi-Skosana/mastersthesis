TARGET := master
BUILD_DIR := build
SUBMIT_DIR := submit
LATEX  := latexmk
LATEXOPTS := -output-directory=$(BUILD_DIR) \
			 -aux-directory=$(BUILD_DIR) \
			 -interaction=nonstopmode \
			 -shell-escape

# Spell checking using aspell
ASPELL=aspell
CHECK_ARGS=check
CHECK=$(ASPELL) $(CHECK_ARGS)

# Commands for running continuous preview with latexmk
PREVIEW_ARGS=$(LATEXOPTS) -pvc
PREVIEW=$(LATEX) $(PREVIEW_ARGS)

CONTENT = $(wildcard *.tex)
FIGS = $(wildcard figures/**/*)
BIB = $(wildcard *.bib)

.PHONY: all clean prepare main reduce submit preview

all: prepare main reduce submit preview

main: $(BUILD_DIR)/$(TARGET).pdf

$(BUILD_DIR)/$(TARGET).pdf: $(CONTENT) $(BIB) $(FIGS)
	# Compile pdf
	$(LATEX) $(LATEXOPTS) $(TARGET).tex

preview:
	$(LATEX) $(LATEXOPTS) -pvc

clean:
	rm -rf $(BUILD_DIR) $(SUBMIT_DIR)
	latexmk -c

# Spell checker
check:
	for f in $(CONTENT) ; do echo $$f ; $(CHECK) $$f | sort | uniq -c ; done

# reduce pdf size
reduce:
	gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -dNOPAUSE -dQUIET -dBATCH -sOutputFile=$(SUBMIT_DIR)/$(TARGET)_reduced.pdf $(TARGET).pdf

prepare:
	mkdir -p $(BUILD_DIR) $(SUBMIT_DIR)

submit:
	cp $(BUILD_DIR)/*.pdf $(SUBMIT_DIR)
