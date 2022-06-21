@echo off

  set Name=main
  set path=.\masm 6.14\bin
  set include=.\masm 6.14\include
  set lib=.\masm 6.14\lib

  ml /c /coff /Fl %Name%.asm 
  if errorlevel 1 goto errasm

  Link /subsystem:console %Name%.obj
  if errorlevel 1 goto errlink

  %Name%.exe
  goto TheEnd

:errlink
  echo Link Error !!!!!!!!!!!!!!!!!
  goto TheEnd

:errasm
  echo Assembler Error !!!!!!!!!!!!
  goto TheEnd

:TheEnd