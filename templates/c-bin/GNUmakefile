# hello-world -- Template C application
# Copyright (C) 2023 Archit Gupta <archit@accelbread.com>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <https://www.gnu.org/licenses/>.
#
# SPDX-License-Identifier: AGPL-3.0-or-later

CFLAGS ?= -std=gnu17 -O3 -flto -Wall -Wextra
BUILDDIR ?= build
DESTDIR ?= /usr/local

NAME := hello-world

BIN := $(BUILDDIR)/$(NAME)
SRCS := $(shell find src -name '*.c')
OBJS := $(patsubst %.c,$(BUILDDIR)/%.o,$(SRCS))
CPPFLAGS += -Isrc

MAKEFLAGS += --no-builtin-rules
.DELETE_ON_ERROR:

.PHONY: all clean

all: $(BIN)

$(BIN): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJS) $(LDLIBS)

$(BUILDDIR)/%.d: %.c $(MAKEFILE_LIST)
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) -MM -MP -MT'$(@:.d=.o) $@' -MF$@ $<

$(BUILDDIR)/%.o: %.c $(MAKEFILE_LIST)
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ -c $<

clean:
	-rm -r $(BUILDDIR)

install:
	install -D $(BIN) $(DESTDIR)/bin/$(NAME)

include $(OBJS:.o=.d)
