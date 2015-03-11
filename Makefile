SHELL = C:\windows\SYSTEM32\cmd.exe

all: build install demo

docs:
	rm NAMESPACE
	Rscript -e "library(devtools); library(methods); document('.'); check_doc('.')"

check: vignette
	Rscript -e "library(devtools); library(methods); check('.')"

build: check
	Rscript -e "library(devtools); build('.', binary=TRUE)"
	mv -f ../bcgroundwater_0.2.zip D:/packages/
	mv -f ../bcgroundwater_0.2.tar.gz D:/packages/

install: check
	Rscript -e "library(devtools); install('.')"
	
vignette: 
	Rscript -e "library(rmarkdown); library(devtools); library(methods);\
	build_vignettes('.');\
	render('vignettes/bcgroundwater.Rmd', output_format = 'md_document', output_dir = '../demo')"
	rm vignettes/bcgroundwater.R

demo: 
	Rscript -e "library(rmarkdown); library(methods);\
	render('vignettes/bcgroundwater.Rmd', output_format = 'md_document', output_dir = '../demo')"
