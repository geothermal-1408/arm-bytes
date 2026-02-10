AS := as
CC := clang -lc
#DEBUG_TOOL := gdb
ASFLAGS := -arch arm64

SRCS := $(wildcard *.s)
OBJS := $(SRCS:%.s=obj/%.o)
BINS := $(SRCS:%.s=bin/%)

# Files to build with debug info (passed from command line)
DEBUG ?=
DEBUG_OBJS := $(DEBUG:%.s=obj/%.o)

# Add -g only for selected object files
$(DEBUG_OBJS): ASFLAGS += -g


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
