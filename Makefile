SHELL = C:\windows\SYSTEM32\cmd.exe

docs:
	rm NAMESPACE
	Rscript -e "library(devtools); library(methods); document('.'); check_doc('.')"

check:
	Rscript -e "library(devtools); library(methods); check('.')"

build:
	Rscript -e "library(devtools); build('.', binary=TRUE)"
	cp ../bcgroundwater_0.2.zip ../bcgroundwater_0.2.tar.gz "I:/SPD/Science Policy & Economics/State of Environment/_dev/packages/"

install:
	Rscript -e "library(devtools); install('.')"
