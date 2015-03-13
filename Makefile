SHELL = C:\windows\SYSTEM32\cmd.exe
PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)

docs:
	rm NAMESPACE
	Rscript -e "library(devtools); library(methods); document('.'); check_doc('.')"

check: vignette
	Rscript -e "library(devtools); library(methods); check('.')"

build: check
	Rscript -e "library(devtools); build('.', binary=TRUE)"
	mv -f ../$(PKGNAME)_$(PKGVERS).zip D:/packages/$(PKGNAME)_$(PKGVERS).zip
	mv -f ../$(PKGNAME)_$(PKGVERS).tar.gz D:/packages/$(PKGNAME)_$(PKGVERS).tar.gz

install: check
	Rscript -e "library(devtools); install('.')"
	
vignette: 
	Rscript -e "library(rmarkdown); library(devtools); library(methods); build_vignettes('.')"
