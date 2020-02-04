#!/bin/sh
#
# Makefile for FF v 1.0
#

####### DIRECTORY

#output directory. If it is a relative path, it is relative to the project root
OUTPUT_DIR = build/
# where the generated headers are. If it is relative, it is relative to OUTPUT_DIR
GENERATED_HEADERS = include/
# where the generated source are. If it is relative, it is relative to OUTPUT_DIR
GENERATED_SOURCES = c/
#folder where the sources (.c) are. If it is a relative path, it is relative to the build directory.
SOURCE_DIR = ../
#folder where the sources (.h) are. If it is a relative path, it is relative to the build directory.
HEADER_DIR = ../
#folder where the flex sources (.l) are. If it is a relative path, it is relative to the build directory.
FLEX_DIR = ../
#folder where the bison sources (.y) are. If it is a relative path, it is relative to the build directory.
BISON_DIR = ../

####### FLAGS

TYPE	= 
ADDONS	= 

CC      = gcc
C_STANDARD=c99
CFLAGS	= -Werror=implicit-function-declaration -fmax-errors=1 -I$(HEADER_DIR) -I$(GENERATED_HEADERS) -O6 -Wall -g -std=$(C_STANDARD) $(TYPE) $(ADDONS)
# some headers (the parser ones) are present in the build directory as well
FLEX_FLAGS =
BISON_FLAGS =
LIBS    = -lm

ifeq ($(OS),Windows_NT)
	CFLAGS := $(CFLAGS) -DWINDOWS -D_CRT_SECURE_NO_WARNINGS -Dfileno=_fileno -Disatty=_isatty -Dlineno=_lineno
	FLEX_FLAGS := $(FLEX_FLAGS) --nounistd
	BISON_FLAGS := $(BISON_FLAGS)
	OUTPUTNAME := ff.exe
else
	CFLAGS := $(CFLAGS) -DLINUX -D_POSIX_SOURCE
	# -DLINUX our custom macro to make the code aware we're buildin on linux
	# -D_POSIX_SOURCE: lineno is present in stdio
	FLEX_FLAGS := $(FLEX_FLAGS)
	BISON_FLAGS := $(BISON_FLAGS)
	OUTPUTNAME := ff
endif

####### Files

PDDL_PARSER_C_SRC_FILENAME	= \
	lex-fct_pddl.c \
	lex-ops_pddl.c \
	scan-fct_pddl.c \
	scan-ops_pddl.c
	
PDDL_PARSER_OBJ_FILENAME = \
	lex-fct_pddl.o \
	lex-ops_pddl.o \
	scan-fct_pddl.o \
	scan-ops_pddl.o \

SOURCES_FILENAME = \
	main.c \
	memory.c \
	output.c \
	parse.c \
	inst_pre.c \
	inst_easy.c \
	inst_hard.c \
	inst_final.c \
	expressions.c \
	relax.c \
	search.c \
	times.c \
	random.c

OBJECTS_FILENAME = $(SOURCES_FILENAME:.c=.o) 

# PDDL_PARSER_C_SRC_PATH = $(addprefix $(OUTPUT_DIR), $(PDDL_PARSER_C_SRC_FILENAME))
# PDDL_PARSER_OBJ_PATH = $(addprefix $(OUTPUT_DIR), $(PDDL_PARSER_OBJ_FILENAME))
# SOURCES_PATH = $(addprefix $(OUTPUT_DIR), $(SOURCES_FILENAME))
# OBJECTS_PATH 	= $(SOURCES_PATH:.c=.o)

####### Implicit rules

.DEFAULT_GOAL := all

.phony: all clean veryclean makedirs info lint copy-resources

all: info makedirs $(OUTPUTNAME)
	@echo "ALL WORK HAS BEEN DONE! :D"

info:
	@echo "OUTPUT_DIR = "$(OUTPUT_DIR)
	@echo "OBJECTS_FILENAME = "$(OBJECTS_FILENAME)

makedirs:
	@mkdir -pv $(OUTPUT_DIR)$(GENERATED_HEADERS)
	@mkdir -pv $(OUTPUT_DIR)$(GENERATED_SOURCES)

copy-resources:
	@cp -v pddl/* $(OUTPUT_DIR)

# .SUFFIXES:
# .SUFFIXES: .c .o

####### Build rules

# .c.o: 
# 	@echo "Compiling file $<..." 
# 	cd $(OUTPUT_DIR) && $(CC) -c $(CFLAGS) -o $<.o $(SOURCEDIR)$<

%.o: %.c
	@echo "Compiling file $@..." 
	cd $(OUTPUT_DIR) && $(CC) -c $(CFLAGS) -o $@ $(SOURCE_DIR)$<

$(OUTPUTNAME): makedirs $(OBJECTS_FILENAME) $(PDDL_PARSER_OBJ_FILENAME) copy-resources
	@echo "Compiling $(OUTPUTNAME)"
	cd $(OUTPUT_DIR) && $(CC) -o $(OUTPUTNAME) $(OBJECTS_FILENAME) $(PDDL_PARSER_OBJ_FILENAME) $(CFLAGS) $(LIBS)

# pddl syntax
lex-fct_pddl.c: makedirs lex-fct_pddl.l 
	cd $(OUTPUT_DIR) && flex \
		--header-file="$(GENERATED_HEADERS)lex-fct_pddl.h" \
		--prefix=fct_pddl \
		--outfile="$(GENERATED_SOURCES)lex-fct_pddl.c" \
		$(FLEX_FLAGS) \
		$(FLEX_DIR)lex-fct_pddl.l

lex-ops_pddl.c: makedirs lex-ops_pddl.l
	cd $(OUTPUT_DIR) && flex \
		--header-file="$(GENERATED_HEADERS)lex-ops_pddl.h" \
		--prefix=ops_pddl \
		--outfile="$(GENERATED_SOURCES)lex-ops_pddl.c" \
		$(FLEX_FLAGS) \
		$(FLEX_DIR)lex-ops_pddl.l

scan-fct_pddl.c: makedirs scan-fct_pddl.y
	cd $(OUTPUT_DIR) && bison \
		--defines="$(GENERATED_HEADERS)scan-fct_pddl.h" \
		--name-prefix="fct_pddl" \
		--file-prefix="scan-fct_pddl" \
		--output="$(GENERATED_SOURCES)scan-fct_pddl.c" \
		$(BISON_FLAGS) \
		$(BISON_DIR)scan-fct_pddl.y

scan-ops_pddl.c: makedirs scan-ops_pddl.y
	cd $(OUTPUT_DIR) && bison \
		--defines="$(GENERATED_HEADERS)scan-ops_pddl.h" \
		--name-prefix="ops_pddl" \
		--file-prefix="scan-ops_pddl" \
		--output="$(GENERATED_SOURCES)scan-ops_pddl.c" \
		$(BISON_FLAGS) \
		$(BISON_DIR)scan-ops_pddl.y

lex-fct_pddl.o: makedirs lex-fct_pddl.c scan-fct_pddl.c
	@echo "Compiling fct lexer"
	cd $(OUTPUT_DIR) && $(CC) -c $(CFLAGS) -o $@ $(GENERATED_SOURCES)lex-fct_pddl.c

lex-ops_pddl.o: makedirs lex-ops_pddl.c scan-ops_pddl.c
	@echo "Compiling ops lexer"
	cd $(OUTPUT_DIR) && $(CC) -c $(CFLAGS) -o $@ $(GENERATED_SOURCES)lex-ops_pddl.c

scan-fct_pddl.o: makedirs scan-fct_pddl.c lex-fct_pddl.o
	@echo "Compiling fct parser"
	cd $(OUTPUT_DIR) && $(CC) -c $(CFLAGS) -o $@ $(GENERATED_SOURCES)scan-fct_pddl.c

scan-ops_pddl.o: makedirs scan-ops_pddl.c lex-ops_pddl.o
	@echo "Compiling ops parser"
	cd $(OUTPUT_DIR) && $(CC) -c $(CFLAGS) -o $@ $(GENERATED_SOURCES)scan-ops_pddl.c


# misc
clean:
	rm -vf $(OUTPUT_DIR)*.o

veryclean:
	rm -rfv $(OUTPUT_DIR)

lint:
	lclint -booltype Bool $(SOURCES_FILENAME) 2> output.lint

# DO NOT DELETE