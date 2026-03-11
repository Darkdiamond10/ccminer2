# allow to use Host cuda functions in C/C++
#DEF_INCLUDES = @CUDA_INCLUDES@

if WANT_JANSSON
JANSSON_INCLUDES= -I$(top_srcdir)/compat/jansson
else
JANSSON_INCLUDES=
endif

EXTRA_DIST		= autogen.sh README.md README.txt LICENSE.txt \
			  ccminer.sln ccminer.vcxproj ccminer.vcxproj.filters \
			  compat/gettimeofday.c compat/getopt/getopt_long.c

SUBDIRS = compat

bin_PROGRAMS = ccminer

ccminer_SOURCES	= elist.h miner.h compat.h \
			  compat/inttypes.h compat/stdbool.h compat/unistd.h bignum.cpp bignum.hpp \
			  compat/sys/time.h compat/getopt/getopt.h \
			  crc32.c \
			  ccminer.cpp pools.cpp util.cpp bench.cpp \
			  api.cpp hashlog.cpp stats.cpp sysinfos.cpp \
			  equi/equi-stratum.cpp verus/verusscan.cpp \
			  verus/haraka.c verus/verus_clhash.cpp



if HAVE_WINDOWS
ccminer_SOURCES += compat/winansi.c
endif

ccminer_LDFLAGS  = $(PTHREAD_FLAGS)

# We filter out standard -lcurl etc from @LIBS@ in a way that doesn't upset automake
# Wait, autotools doesn't like backticks or fancy sed in _LDADD variables. Let's just use @LIBS@.
# We'll just put LIBCURL_STATIC first so it takes precedence over any generic -lcurl in LIBS.
ccminer_LDADD    = @LIBCURL_STATIC@ @JANSSON_LIBS@ @PTHREAD_LIBS@ @WS2_LIBS@ @OPENMP_CFLAGS@ @LIBS@
ccminer_CPPFLAGS = @OPENMP_CFLAGS@ $(CPPFLAGS) $(PTHREAD_FLAGS) -march=native -fno-strict-aliasing $(JANSSON_INCLUDES) -I$(top_srcdir)/curl-static/include $(DEF_INCLUDES) -O3


if HAVE_OSX
ccminer_CXXFLAGS = -std=c++11
ccminer_CPPFLAGS += -I/usr/local/llvm/lib/clang/4.0.0/include
endif




