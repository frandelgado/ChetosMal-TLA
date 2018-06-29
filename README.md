# Teoria de lenguajes, automatas y compiladores TPE
## Building the parser
To compile the pareser you can use the built-in script by running
```
./make.sh
```
In order to compile a .dank program you can run the compiled dankparser with an associated input and output file
```
./dankcompiler my_dank_file.dank my_dank_out_file.c 
```
An input file must be specified, but if no output file is specified it will default to out.c
```
You can also use the dank compilation bash script to compile derectly to an executable like so:
```
./dank my_dank_file.dank
```
Or
```
./dank my_dank_file.dank my_exe


## Authors

* **Francisco Delgado**
* **Lucas Emery**
* **Diego Orlando**
* **Andrés Carlos Digiovanni Martinez**