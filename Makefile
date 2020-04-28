CFLAGS=-Wall -std=gnu99 -g -I. -O0
OBJS=cpp.o debug.o dict.o gen.o lex.o list.o parse.o string.o error.o
SELF=cpp.s debug.s dict.s gen.s lex.s list.s parse.s string.s error.s main.s
TESTS := $(patsubst %.c,%.bin,$(wildcard test/*.c))

SmileyBASIC: 8cc.h main.o $(OBJS)
	$(CC) -o $@ main.o $(OBJS) $(LDFLAGS)

$(OBJS) utiltest.o main.o: 8cc.h

utiltest: 8cc.h utiltest.o $(OBJS)
	$(CC) -o $@ utiltest.o $(OBJS) $(LDFLAGS)

test: utiltest $(TESTS)
	@echo
	./utiltest
	@for test in $(TESTS); do  \
	    ./$$test || exit;      \
	done
	./test.sh

test/%.o: test/%.c SmileyBASIC
	./SmileyBASIC -c $<

test/%.bin: test/%.o test/main/testmain.s SmileyBASIC
	$(CC) -o $@ $< test/main/testmain.o $(LDFLAGS)

$(SELF) test/main/testmain.s: SmileyBASIC test/main/testmain.c
	./SmileyBASIC -c $(@:s=c)

self: $(SELF)
	rm -f SmileyBASIC utiltest
	$(MAKE) SmileyBASIC

fulltest:
	$(MAKE) clean
	$(MAKE) test
	cp SmileyBASIC gen1
	rm $(OBJS) main.o
	$(MAKE) self
	$(MAKE) test
	cp SmileyBASIC gen2
	rm $(OBJS) main.o
	$(MAKE) self
	$(MAKE) test
	cp SmileyBASIC gen3
	diff gen2 gen3

clean:
	rm -f SmileyBASIC *.o *.s tmp.* test/*.s test/*.o sample/*.o
	rm -f utiltest gen[1-9] test/util/testmain.[os]
	rm -f $(TESTS)

all: SmileyBASIC

.PHONY: clean test all
