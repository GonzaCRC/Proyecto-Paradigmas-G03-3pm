﻿/*
Creador:
Carlos Loría Saenz
EIF400 loriacarlos@gmail.com

Colaboradores:
Erick Vargas Arias 
Esteban Zúñiga Cruz
Gonzalo Gonzalez Garro
Gabriel Araya Ruiz
*/

:- module(rsCompiler, [compile/0, compile/1, compile/3]).

:- use_module(rsParser).
:- use_module(rsGenerator).
:- use_module(rsSemanter).
:- use_module(rsTriggerSort).

compile(InPath, OutPath, Filename) :-
   atom_concat(InPath, Filename, PathInFile),
   exists_file(PathInFile), !,
   format('*** Compiling :"~a" *** ~n', [PathInFile]),
   rsParser:parse(PathInFile, P),
   atom_concat(OutPath, Filename, PathOutFile),
   atom_concat(PathOutFile, '.out', RSOutFile),
   format('*** Writing   :"~a" *** ~n', [RSOutFile]),
   rsGenerator:genCodeToFile(RSOutFile, P),
   catch(rsSemanter:checkSemantic(Filename), 
        Err, (
		atom_concat(OutPath, Filename, FailFile), 
		atom_concat(FailFile, '.out', FailFile2),
		delete_file(FailFile2),
		throw(Err))
	),
   rsTriggerSort:sortTriggers(Filename)
.

compile(InPath, _, Filename) :-
   atom_concat(InPath, Filename, PathInFile),
   format('*** RSCompiler: File Not found :"~a" *** ~n', [PathInFile]),
   fail
.
compile(Filename) :- compile('./cases/', './riveRepository/', Filename)
.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Default test case %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
compile :- 
    File = 'micro.rive',
    compile(File)
.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Entry Point %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
main :-
    writeln('*** Starting compilation ***'),
    current_prolog_flag(argv, AllArgs),
    [E|_] = AllArgs,
    compile(E),
   writeln('*** Sucessful compilation ***'), !
.
main :-
    writeln('*** Provide an existing test case file ***')
.