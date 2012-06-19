CFLAGS := -m32 -fPIC -MMD -MP
LDFLAGS := -m32 -shared -Wl,--version-script=dmfifo.gld

TARGET := dmfifo.so
OBJS := dmfifo.o
LIBS :=


ifdef DEBUG
CFLAGS += -g -Wall -ansi -pedantic
else
CFLAGS += -O3
LDFLAGS += -O3
STRIP := strip ${TARGET}
endif


.PHONY: all clean install

all: ${TARGET}

-include ${OBJS:.o=.d}

clean:
	rm -f ${TARGET} *.o *.d

install: ${TARGET}
	install -d ~/.byond/bin
	install ${TARGET} ~/.byond/bin

${TARGET}: ${OBJS}
	${CXX} ${LDFLAGS} -o $@ $+ ${LIBS}
	${STRIP}

.c.o:
	${CC} ${CFLAGS} ${$@_CFLAGS} -c $<
