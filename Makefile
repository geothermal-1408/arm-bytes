AS := as
CC := clang -lc
#DEBUG_TOOL := gdb
ASFLAGS := -arch arm64

SRCS := $(wildcard *.s)
OBJS := $(SRCS:%.s=obj/%.o)
BINS := $(SRCS:%.s=bin/%)

ifeq ($(DBG),1)
    ASFLAGS += -g
endif

.PHONY: all clean

all: $(BINS)

%: bin/%
	@true

.SECONDARY:

obj/%.o: %.s
	@mkdir -p $(@D)
	$(AS) $(ASFLAGS) $< -o $@

bin/%: obj/%.o
	@mkdir -p $(@D)
	$(CC) $< -o $@

run-%: bin/%
	./$<

clean:
	rm -rf obj bin
