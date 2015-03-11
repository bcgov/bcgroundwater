SHELL = C:\windows\SYSTEM32\cmd.exe

all: build install

docs:
	rm NAMESPACE
	Rscript -e "library(devtools); library(methods); document('.'); check_doc('.')"

check:
	Rscript -e "library(devtools); library(methods); check('.')"

build: check
	Rscript -e "library(devtools); build('.', binary=TRUE)"
	cp ../bcgroundwater_0.2.zip ../bcgroundwater_0.2.tar.gz "D:/_dev/packages/"

install: check
	Rscript -e "library(devtools); install('.')"
