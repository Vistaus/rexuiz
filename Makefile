.PHONY: all clean engine curl freetype stand-alone stand-alone-data stand-alone-engine update-qc gmqcc
PWD=$(shell pwd)

DPDIR=DarkPlacesRM

ifneq ($(CROSSPREFIX),)
CC=$(CROSSPREFIX)-gcc
CXX=$(CROSSPREFIX)-g++
AR=$(CROSSPREFIX)-ar
RANLIB=$(CROSSPREFIX)-ranlib
STRIP=$(CROSSPREFIX)-strip
else
CC=gcc
CXX=g++
AR=ar
RANLIB=ranlib
STRIP=strip
endif
LD=$(CC)

ifeq ($(shell uname -s),Linux)
ifeq ($(shell uname -m),x86_64)
DPTARGET=linux64
else
ifeq ($(shell uname -m),aarch64)
DPTARGET=linux-arm64
else
ifeq ($(shell uname -m),armv7l)
DPTARGET=linux-arm32
else
DPTARGET=linux32
endif
endif
endif
else
ifeq ($(shell uname -s),Darwin)
ifeq ($(shell uname -m),x86_64)
DPTARGET=mac64
else
DPTARGET=mac32
endif
else
ifeq ($(shell uname -m),x86_64)
DPTARGET=win64
else
DPTARGET=win32
endif
endif
endif

LIBDIR=$(PWD)/libs/$(DPTARGET)/
LIBSAMPLERATEVERSION=0.2.2
LIBSAMPLERATEDIR=libsamplerate-$(LIBSAMPLERATEVERSION)
LIBSAMPLERATETARXZ=$(LIBSAMPLERATEDIR).tar.xz
LIBSAMPLERATEFILES=$(LIBDIR)/lib/libsamplerate.a
LIBPNGDIR=libpng-1.6.36
LIBPNGTARGZ=$(LIBPNGDIR).tar.gz
LIBPNGFILES=$(LIBDIR)/lib/libpng.a $(LIBDIR)/lib/libpng16.a
ZLIBDIR=zlib-1.2.12
ZLIBTARGZ=$(ZLIBDIR).tar.gz
ZLIBFILES=$(LIBDIR)/lib/libz.a
JPEGTARGZ=jpegsrc.v9d.tar.gz
JPEGDIR=jpeg-9d
JPEGFILES=$(LIBDIR)/lib/libjpeg.a
SDLDIR=SDL2-2.0.20
SDLTARGZ=$(SDLDIR).tar.gz
ifeq ($(DPTARGET),android)
HIDAPIFILES=$(LIBDIR)/lib/libhidapi.so
SDLFILES=$(LIBDIR)/lib/libSDL2.so
else
SDLFILES=$(LIBDIR)/bin/sdl2-config
endif
LIBMICROHTTPDFILES=$(LIBDIR)/lib/libmicrohttpd.a
FREETYPEDIR=freetype-2.10.4
FREETYPETARGZ=$(FREETYPEDIR).tar.gz
CURLDIR=curl-7.68.0
CURLTARGZ=$(CURLDIR).tar.gz
LIBOGGDIR=libogg-1.3.2
LIBOGGTARGZ=$(LIBOGGDIR).tar.gz
LIBOGGFILES=$(LIBDIR)/lib/libogg.a
LIBVORBISDIR=libvorbis-1.3.5
LIBVORBISTARGZ=$(LIBVORBISDIR).tar.gz
LIBVORBISFILES=$(LIBDIR)/lib/libvorbis.a $(LIBDIR)/lib/libvorbisenc.a $(LIBDIR)/lib/libvorbisfile.a
LIBTHEORADIR=libtheora-1.1.1
LIBTHEORATARGZ=$(LIBTHEORADIR).tar.gz
LIBTHEORAFILES=$(LIBDIR)/lib/libtheora.a $(LIBDIR)/lib/libtheoraenc.a
LIBMICROHTTPDDIR=libmicrohttpd-0.9.75
LIBMICROHTTPDTARGZ=$(LIBMICROHTTPDDIR).tar.gz
OPUSDIR=opus-1.3.1
OPUSTARGZ=$(OPUSDIR).tar.gz
OPUSFILES=$(LIBDIR)/lib/libopus.a
DPMAKEOPTS=CC='$(CC) -I$(LIBDIR)/include/SDL2 -I$(LIBDIR)/include -L$(LIBDIR)/lib' LD='$(CC) -L$(LIBDIR)/lib' STRIP=$(STRIP) DP_LINK_ZLIB=shared DP_LINK_JPEG=shared DP_LINK_PNG=shared SDL_CONFIG='$(LIBDIR)/bin/sdl2-config' DP_LIBMICROHTTPD=static DP_LINK_OGGVORBIS=static DP_LINK_ZLIB=static DP_LINK_JPEG=static DP_LINK_PNG=static DP_LINK_OPUS=static $(DPMAKEOPTS_EXTRA)
ifneq ($(DPTARGET),android)
DPMAKEOPTS:=$(DPMAKEOPTS) DP_SDL_STATIC=yes
endif

ifeq ($(DPTARGET),linux32)
ARCHSUFFIX=i686
DPTARGET_LINUX=y
DPMAKEOPTS:=$(DPMAKEOPTS) DP_MAKE_TARGET=linux
endif
ifeq ($(DPTARGET),linux64)
ARCHSUFFIX=x86_64
DPTARGET_LINUX=y
DPMAKEOPTS:=$(DPMAKEOPTS) DP_MAKE_TARGET=linux
endif
ifeq ($(DPTARGET),linux-arm64)
ARCHSUFFIX=aarch64
DPTARGET_LINUX=y
DPMAKEOPTS:=$(DPMAKEOPTS) DP_MAKE_TARGET=linux CFLAGS_SSE="" CFLAGS_SSE2=""
endif
ifeq ($(DPTARGET),linux-arm32)
ARCHSUFFIX=armv7l
DPTARGET_LINUX=y
DPMAKEOPTS:=$(DPMAKEOPTS) DP_MAKE_TARGET=linux CFLAGS_SSE="" CFLAGS_SSE2=""
endif
ifeq ($(DPTARGET),win32)
DPMAKEOPTS:=$(DPMAKEOPTS) DP_MAKE_TARGET=mingw TARGET=$(CROSSPREFIX) LIB_LIBMICROHTTPD='-lmicrohttpd -lws2_32' OBJ_ICON=rexuiz.o
DPTARGET_WIN=y
ARCHSUFFIX=i686
endif
ifeq ($(DPTARGET),win64)
DPMAKEOPTS:=$(DPMAKEOPTS) DP_MAKE_TARGET=mingw TARGET=$(CROSSPREFIX) MINGWARCH=x86_64 LIB_LIBMICROHTTPD='-lmicrohttpd -lws2_32' OBJ_ICON=rexuiz.o
DPTARGET_WIN=y
ARCHSUFFIX=x86_64
endif
ifeq ($(DPTARGET),mac32)
ARCHSUFFIX=i686
DPTARGET_MAC=y
endif
ifeq ($(DPTARGET),mac64)
ARCHSUFFIX=x86_64
DPTARGET_MAC=y
endif
ifeq ($(DPTARGET),android)
EXTRALIBS_LINKONLY=$(LIBOGGFILES) $(LIBVORBISFILES)
SDLDEPS=
else
EXTRALIBS_LINKONLY=$(LIBOGGFILES) $(LIBVORBISFILES) $(LIBTHEORAFILES)
SDLDEPS=$(LIBSAMPLERATEFILES)
endif
ifeq ($(DPTARGET_WIN),y)
FREETYPEFILES=$(LIBDIR)/bin/libfreetype-6.dll
CURLFILES=$(LIBDIR)/bin/libcurl-4.dll
EXTRALIBS=$(FREETYPEFILES) $(CURLFILES)
else
ifeq ($(DPTARGET_MAC),y)
DPMAKEOPTS:=$(DPMAKEOPTS) DP_MAKE_TARGET=macosx
FREETYPEFILES=$(LIBDIR)/lib/libfreetype.dylib
CURLFILES=$(LIBDIR)/lib/libcurl.dylib
EXTRALIBS=
else
ifeq ($(DPTARGET),android)
DPMAKEOPTS:=$(DPMAKEOPTS) DP_FS_BASEDIR=/sdcard/Rexuiz/ DP_MAKE_TARGET=android DP_VIDEO_CAPTURE=disabled
CURLFILES=$(LIBDIR)/lib/libcurl.so
FREETYPEFILES=$(LIBDIR)/lib/libfreetype.so
EXTRALIBS=$(CURLFILES) $(FREETYPEFILES)
else
DPMAKEOPTS:=$(DPMAKEOPTS) DP_FS_BASEDIR=/usr/share/rexuiz/
FREETYPEFILES=$(LIBDIR)/lib/libfreetype.so
CURLFILES=$(LIBDIR)/lib/libcurl.so
EXTRALIBS=$(CURLFILES) $(FREETYPEFILES)
endif
endif
endif

SDLFILES_FORDP=$(SDLFILES)


all: stand-alone

nexuiz-252.zip:
	wget -O temp_$@ "http://downloads.sourceforge.net/project/nexuiz/NexuizRelease/Nexuiz%202.5.2/$@"
	mv temp_$@ $@

$(CURLTARGZ):
	wget -O temp_$@ https://curl.haxx.se/download/$@
	mv temp_$@ $@

$(LIBOGGTARGZ):
	wget -O temp_$@ http://downloads.xiph.org/releases/ogg/$@
	mv temp_$@ $@

$(LIBVORBISTARGZ):
	wget -O temp_$@ http://downloads.xiph.org/releases/vorbis/$@
	mv temp_$@ $@

$(LIBTHEORATARGZ):
	wget -O temp_$@ http://downloads.xiph.org/releases/theora/$@
	mv temp_$@ $@

$(FREETYPETARGZ):
	wget -O temp_$@ http://download.savannah.gnu.org/releases/freetype/$@
	mv temp_$@ $@

$(SDLTARGZ):
	wget -O temp_$@ https://www.libsdl.org/release/$@
	mv temp_$@ $@

$(JPEGTARGZ):
	wget -O temp_$@ http://www.ijg.org/files/$@
	mv temp_$@ $@

$(ZLIBTARGZ):
	wget -O temp_$@ http://zlib.net/$@
	mv temp_$@ $@

$(LIBPNGTARGZ):
	wget -O temp_$@ http://prdownloads.sourceforge.net/libpng/libpng-1.6.36.tar.gz?download
	mv temp_$@ $@

$(LIBSAMPLERATETARXZ):
	wget -O temp_$@ https://github.com/libsndfile/libsamplerate/releases/download/$(LIBSAMPLERATEVERSION)/$@
	mv temp_$@ $@

$(LIBMICROHTTPDTARGZ):
	wget -O temp_$@ http://ftp.gnu.org/gnu/libmicrohttpd/$@
	mv temp_$@ $@

$(OPUSTARGZ):
	wget -O temp_$@ https://archive.mozilla.org/pub/opus/$@
	mv temp_$@ $@

$(LIBPNGFILES): $(LIBPNGTARGZ) $(ZLIBFILES)
	tar xzf $(LIBPNGTARGZ)
	cd $(LIBPNGDIR) && CC="$(CC) -I$(LIBDIR)/include -L$(LIBDIR)/lib" CFLAGS="-I$(LIBDIR)/include" LDFLAGS="-L$(LIBDIR)/lib" ./configure --host=$(CROSSPREFIX) --disable-shared --enable-static --prefix=$(LIBDIR) && make && make install

$(LIBSAMPLERATEFILES): $(LIBSAMPLERATETARXZ)
	tar xJf $(LIBSAMPLERATETARXZ)
	cd $(LIBSAMPLERATEDIR) && CFLAGS="-std=c99" ./configure --host=$(CROSSPREFIX) --disable-sndfile --disable-alsa --disable-fftw --disable-shared --enable-static --prefix=$(LIBDIR) && make && make install

$(ZLIBFILES): $(ZLIBTARGZ)
	tar xzf $(ZLIBTARGZ)
	cd $(ZLIBDIR) && CC="$(CC)" AR="$(AR)" RANLIB="$(RANLIB)" ./configure --static --prefix=$(LIBDIR)
	cd $(ZLIBDIR) && make && make install
	$(RANLIB) $(LIBDIR)/lib/libz.a

$(JPEGFILES): $(JPEGTARGZ)
	tar xzf $(JPEGTARGZ)
	cd $(JPEGDIR) && CC="$(CC)" ./configure --disable-shared --host=$(CROSSPREFIX) --enable-static --prefix=$(LIBDIR) && make && make install

$(FREETYPEFILES): $(FREETYPETARGZ)
	tar xzf $(FREETYPETARGZ)
	cd $(FREETYPEDIR) && CC="$(CC)" ./configure --with-png=no --with-harfbuzz=no --with-zlib=no --with-bzip2=no --enable-shared --host=$(CROSSPREFIX) --disable-static --prefix=$(LIBDIR) && make && make install

$(OPUSFILES): $(OPUSTARGZ)
	tar xzf $(OPUSTARGZ)
	cd $(OPUSDIR) && CC="$(CC)" AR="$(AR)" ./configure --enable-static --disable-shared --host=$(CROSSPREFIX) --prefix=$(LIBDIR) --disable-extra-programs && make && make install

$(CURLFILES): $(CURLTARGZ)
	tar xzf $(CURLTARGZ)
ifeq ($(DPTARGET_WIN),y)
	cd $(CURLDIR) && CC="$(CC) -static-libgcc" ./configure --without-zlib --enable-shared --host=$(CROSSPREFIX) --disable-static --prefix=$(LIBDIR) --disable-pthreads && make && make install
else
	cd $(CURLDIR) && CC="$(CC)" ./configure --without-ssl --without-gnutls --without-zlib --disable-ldap --enable-shared --host=$(CROSSPREFIX) --disable-static --prefix=$(LIBDIR) && make && make install
endif

$(LIBOGGFILES): $(LIBOGGTARGZ)
	tar xzf $(LIBOGGTARGZ)
	cd $(LIBOGGDIR) && CC="$(CC)" ./configure --disable-shared --host=$(CROSSPREFIX) --enable-static --prefix=$(LIBDIR) && make && make install

$(LIBVORBISFILES): $(LIBVORBISTARGZ) $(LIBOGGFILES)
	tar xzf $(LIBVORBISTARGZ)
ifeq ($(DPTARGET),android)
	sed -i 's/-mno-ieee-fp//' $(LIBVORBISDIR)/configure
endif
	cd $(LIBVORBISDIR) && PKG_CONFIG_PATH="$(LIBDIR)/lib/pkgconfig" CC="$(CC)" CFLAGS="-I$(LIBDIR)/include" LDFLAGS="-L$(LIBDIR)/lib" ./configure --disable-shared --host=$(CROSSPREFIX) --enable-static --prefix=$(LIBDIR) && make && make install

$(LIBTHEORAFILES): $(LIBTHEORATARGZ) $(LIBOGGFILES)
	tar xzf $(LIBTHEORATARGZ)
	tr -d '\015' < $(LIBTHEORADIR)/win32/xmingw32/libtheoradec-all.def > $(LIBTHEORADIR)/win32/xmingw32/libtheoradec-all.def.fixed
	mv $(LIBTHEORADIR)/win32/xmingw32/libtheoradec-all.def.fixed $(LIBTHEORADIR)/win32/xmingw32/libtheoradec-all.def
	tr -d '\015' < $(LIBTHEORADIR)/win32/xmingw32/libtheoraenc-all.def > $(LIBTHEORADIR)/win32/xmingw32/libtheoraenc-all.def.fixed
	mv $(LIBTHEORADIR)/win32/xmingw32/libtheoraenc-all.def.fixed $(LIBTHEORADIR)/win32/xmingw32/libtheoraenc-all.def
	cd $(LIBTHEORADIR) && sed -i s/cross_compiling=no/cross_compiling=yes/ configure && sed -i '263i |aarch64 \\'  config.sub
ifeq ($(DPTARGET_WIN),y)
	cd $(LIBTHEORADIR) && HAVE_PDFLATEX=no HAVE_DOXYGEN=no HAVE_BIBTEX=no CC="$(CC) -static-libgcc" CFLAGS="-I$(LIBDIR)/include" LDFLAGS="-L$(LIBDIR)/lib -static-libgcc" ./configure --disable-examples --disable-shared --host=$(CROSSPREFIX) --enable-static --prefix=$(LIBDIR) --disable-examples && make && make install
else
ifeq ($(ARCHSUFFIX),x86_64)
	cd $(LIBTHEORADIR) && HAVE_PDFLATEX=no HAVE_DOXYGEN=no HAVE_BIBTEX=no CC="$(CC)" CFLAGS="-I$(LIBDIR)/include" LDFLAGS="-L$(LIBDIR)/lib" ./configure --disable-shared --build=$(CROSSPREFIX) --disable-examples --enable-static --prefix=$(LIBDIR) && make && make install
else
	cd $(LIBTHEORADIR) && HAVE_PDFLATEX=no HAVE_DOXYGEN=no HAVE_BIBTEX=no CC="$(CC)" CFLAGS="-I$(LIBDIR)/include" LDFLAGS="-L$(LIBDIR)/lib" ./configure --disable-shared --build=$(CROSSPREFIX) --disable-examples --enable-static --prefix=$(LIBDIR) --disable-asm && make && make install
endif
endif

$(LIBMICROHTTPDFILES): $(LIBMICROHTTPDTARGZ)
	tar xzf $(LIBMICROHTTPDTARGZ)
	cd $(LIBMICROHTTPDDIR) && CC="$(CC)" CFLAGS="-I$(LIBDIR)/include" LDFLAGS="-L$(LIBDIR)/lib" ./configure --disable-shared --host=$(CROSSPREFIX) --enable-static --disable-https --prefix=$(LIBDIR) && make && make install

$(SDLFILES): $(SDLTARGZ) $(SDLDEPS)
	tar xzf $(SDLTARGZ)
ifeq ($(DPTARGET_WIN),y)
	cd $(SDLDIR) && CC="$(CC)" CXX="$(CXX)" host_os=mingw CFLAGS="-I$(LIBDIR)/include" LDFLAGS="-L$(LIBDIR)/lib" ./configure --host=$(CROSSPREFIX) --target=$(CROSSPREFIX) --enable-static --disable-shared --enable-libsamplerate --disable-libsamplerate-shared --prefix=$(LIBDIR)
	cd $(SDLDIR) && make
	cd $(SDLDIR) && make install
else
ifeq ($(DPTARGET_MAC),y)
	cd $(SDLDIR) && CC="$(CC)" CXX="$(CXX)" CFLAGS="-I$(LIBDIR)/include" LDFLAGS="-L$(LIBDIR)/lib" ./configure --host=$(CROSSPREFIX) --target=$(CROSSPREFIX) --x-includes=$(MAC_OS_SDK)/usr/include --disable-cpuinfo --disable-video-x11 --enable-static --disable-shared --prefix=$(LIBDIR) && make && make install
else
ifeq ($(DPTARGET),android)
ifeq ($(ANDROID_ABI),)
	echo ANDROID_ABI must be set
	exit 1
endif
	mkdir -m755 -p $(SDLDIR)/buildtree
	cd $(SDLDIR) && patch -p1 < ../SDL2.patch
	cd $(SDLDIR)/buildtree && CC="$(CC) -static-libstdc++" CXX="$(CXX) -static-libstdc++" CFLAGS="-I$(LIBDIR)/include" LDFLAGS="-L$(LIBDIR)/lib" cmake -DANDROID=1 -DCMAKE_LIBRARY_PATH=${ANDROID_NDK_ROOT}/usr/lib/${CROSSPREFIX}/$(ANDROID_ABI)/ -DANDROID_NDK=${ANDROID_NDK_HOME} -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_INSTALL_PREFIX=$(LIBDIR) -DCMAKE_CROSSCOMPILING=1 -DIMPORTED_NO_SONAME=1 -DNO_SONAME=1 .. && make && make install
	#cd $(SDLDIR) && CC="$(CC) -static-libstdc++" CXX="$(CXX) -static-libstdc++" CFLAGS="-I$(LIBDIR)/include" LDFLAGS="-L$(LIBDIR)/lib" ./configure --oldincludedir=$(LIBDIR)/include --host=$(CROSSPREFIX) --target=$(CROSSPREFIX) --disable-static --enable-shared --prefix=$(LIBDIR) --disable-libsamplerate --disable-pulseaudio --disable-video-x11 --disable-video-wayland --disable-video-kmsdrm --disable-pipewire && make && make install
	sed -i 's/-I\/usr\/include//' $(LIBDIR)/bin/sdl2-config
	cd $(SDLDIR)/src/hidapi/android/ && $(CXX) -O2 -Wall -I$(LIBDIR)/include `$(LIBDIR)/bin/sdl2-config --cflags` -L$(LIBDIR)/lib hid.cpp -static-libstdc++ `$(LIBDIR)/bin/sdl2-config --libs` -llog -shared -o $(HIDAPIFILES)
else
	#cd $(SDLDIR) && CC="$(CC)" CXX="$(CXX)" CFLAGS="-I$(LIBDIR)/include" LDFLAGS="-L$(LIBDIR)/lib" ./configure --host=$(CROSSPREFIX) --target=$(CROSSPREFIX) --enable-static --disable-shared --disable-video-wayland --disable-pulseaudio --disable-video-kmsdrm --disable-pipewire --prefix=$(LIBDIR) && make && make install
	cd $(SDLDIR) && CC="$(CC)" CXX="$(CXX)" CFLAGS="-I$(LIBDIR)/include" LDFLAGS="-L$(LIBDIR)/lib" ./configure --host=$(CROSSPREFIX) --target=$(CROSSPREFIX) --enable-static --disable-shared --prefix=$(LIBDIR) && make && make install
endif
endif
endif

clean:
	rm -rf $(ZLIBDIR) $(JPEGDIR) $(LIBPNGDIR) $(SDLDIR) $(LIBDIR) $(LIBOGGDIR) $(LIBVORBISDIR) $(LIBTHEORADIR) $(CURLDIR) $(FREETYPEDIR) $(LIBMICROHTTPDDIR) $(LIBSAMPLERATEDIR) $(OPUSDIR)
	rm -rf $(LIBDIR)
	cd $(DPDIR) && make clean

engine: $(LIBPNGFILES) $(JPEGFILES) $(ZLIBFILES) $(SDLFILES_FORDP) $(EXTRALIBS_LINKONLY) $(LIBMICROHTTPDFILES) $(OPUSFILES)
ifeq ($(DPTARGET),android)
	cd $(DPDIR) && PKG_CONFIG_PATH="$(LIBDIR)/lib/pkgconfig" make android-rexuiz $(DPMAKEOPTS)
else
	cd $(DPDIR) && PKG_CONFIG_PATH="$(LIBDIR)/lib/pkgconfig" make sdl-rexuiz $(DPMAKEOPTS)
ifeq ($(DPTARGET_LINUX),y)
	cd $(DPDIR) && PKG_CONFIG_PATH="$(LIBDIR)/lib/pkgconfig" make sv-rexuiz $(DPMAKEOPTS)
endif
endif

stand-alone: stand-alone-data stand-alone-engine

stand-alone-data: nexuiz-252.zip
ifeq ($(DPTARGET),android)
	rm -f Rexuiz/data/rexuiz.pk3
	rm -f Rexuiz/data/rexuiz-data.pk3
	cd rexuiz.pk3 && zip -r ../rexuiz-android/app/src/main/assets/rexuiz/data/rexuiz.pk3 *
	cd rexuiz-data.pk3 && zip -r ../rexuiz-android/app/src/main/assets/rexuiz/data/rexuiz-data.pk3 *
	cd zmobile.pk3 && zip -r ../rexuiz-android/app/src/main/assets/rexuiz/data/zmobile.pk3 *
else
	make update-qc
	mkdir -m 755 -p Rexuiz/sources
	echo "https://github.com/kasymovga/rexuiz" > Rexuiz/sources/sources.txt
	mkdir -m 755 -p Rexuiz/data/dlcache
	rm -f Rexuiz/data/rexuiz.pk3
	rm -f Rexuiz/data/rexuiz-data.pk3
	cd rexuiz.pk3 && zip -r ../Rexuiz/data/rexuiz.pk3 *
	cd rexuiz-data.pk3 && zip -r ../Rexuiz/data/rexuiz-data.pk3 *
	test -f Rexuiz/data/common-spog.pk3 || unzip -j nexuiz-252.zip Nexuiz/data/common-spog.pk3 -d Rexuiz/data
	test -f Rexuiz/gpl.txt || unzip -j nexuiz-252.zip Nexuiz/gpl.txt -d Rexuiz
	test -f Rexuiz/data/dlcache/csprogs.dat.408476.61283 || (rm -f csprogs.dat && unzip -j nexuiz-252.zip Nexuiz/data/data20091001.pk3 && unzip -j data20091001.pk3 csprogs.dat && mv csprogs.dat Rexuiz/data/dlcache/csprogs.dat.408476.61283 && rm -f data20091001.pk3)
	cd rexdlc && make base essential
	cp rexdlc/*.pk3 Rexuiz/data/dlcache/
	mv Rexuiz/data/dlcache/zzz-rexdlc_base-* Rexuiz/data/
	for F in Rexuiz/data/zzz-rexdlc_base-* ; do mv "$$F" Rexuiz/data/rexuiz-$${F#Rexuiz/data/zzz-rexdlc_} ; done
	install -m644 scripts/server-example.cfg Rexuiz/data/server-example.cfg
endif

stand-alone-engine: engine $(EXTRALIBS)
ifeq ($(DPTARGET),android)
ifeq ($(ANDROID_ARCH),)
	echo ANDROID_ARCH must be set
	exit 1
else
	mkdir -p rexuiz-android/app/src/main/jniLibs/$(ANDROID_ARCH)
	install -m755 $(DPDIR)/librexuiz-android.so rexuiz-android/app/src/main/jniLibs/$(ANDROID_ARCH)/
	install -m755 $(FREETYPEFILES) rexuiz-android/app/src/main/jniLibs/$(ANDROID_ARCH)/
	install -m755 $(CURLFILES) rexuiz-android/app/src/main/jniLibs/$(ANDROID_ARCH)/
	install -m755 $(HIDAPIFILES) rexuiz-android/app/src/main/jniLibs/$(ANDROID_ARCH)/
	install -m755 $(SDLFILES) rexuiz-android/app/src/main/jniLibs/$(ANDROID_ARCH)/
	mkdir -m 755 -p rexuiz-android/app/src/main/java/org/libsdl/app/
	install -m644 $(SDLDIR)/android-project/app/src/main/java/org/libsdl/app/*.java rexuiz-android/app/src/main/java/org/libsdl/app/
endif
else
	mkdir -m 755 -p Rexuiz/sources
ifeq ($(DPTARGET_WIN),y)
	install -m644 $(DPDIR)/rexuiz-sdl-$(ARCHSUFFIX).exe Rexuiz/rexuiz-sdl-$(ARCHSUFFIX).exe
ifeq ($(ARCHSUFFIX), x86_64)
	install -m644 scripts/run_server_win64.cmd Rexuiz/server/
endif
ifeq ($(ARCHSUFFIX),i686)
	install -m644 scripts/run_server_win32.cmd Rexuiz/server/
endif
ifeq ($(DPTARGET),win32)
	mkdir -m755 -p Rexuiz/bin32
	install -m644 $(EXTRALIBS) Rexuiz/bin32/
endif
ifeq ($(DPTARGET),win64)
	mkdir -m755 -p Rexuiz/bin64
	install -m644 $(EXTRALIBS) Rexuiz/bin64/
endif
endif
ifeq ($(DPTARGET_LINUX),y)
	mkdir -p Rexuiz/linux-bins/$(ARCHSUFFIX)
	mkdir -p Rexuiz/server
	install -m 755 $(DPDIR)/rexuiz-sdl Rexuiz/linux-bins/$(ARCHSUFFIX)/rexuiz-sdl
	install -m644 $(CURLFILES) Rexuiz/linux-bins/$(ARCHSUFFIX)/libcurl-fallback.so
	install -m644 $(FREETYPEFILES) Rexuiz/linux-bins/$(ARCHSUFFIX)/libfreetype-fallback.so
	install -m 755 $(DPDIR)/rexuiz-dedicated Rexuiz/linux-bins/$(ARCHSUFFIX)/rexuiz-dedicated
	cat scripts/run_client | sed 's/@@ARCH@@/$(ARCHSUFFIX)/g' | sed 's/@@BINARY_NAME@@/rexuiz-sdl/g' > Rexuiz/rexuiz-linux-sdl-$(ARCHSUFFIX)
	chmod 755 Rexuiz/rexuiz-linux-sdl-$(ARCHSUFFIX)
	cat scripts/run_server | sed 's/@@ARCH@@/$(ARCHSUFFIX)/g' | sed 's/@@BINARY_NAME@@/rexuiz-dedicated/g' > Rexuiz/server/rexuiz-linux-dedicated-$(ARCHSUFFIX)
	chmod 755 Rexuiz/server/rexuiz-linux-dedicated-$(ARCHSUFFIX)
	install -m755 scripts/update.sh Rexuiz/server/update.sh
endif
ifeq ($(DPTARGET_MAC),y)
	mkdir -m755 -p Rexuiz/Rexuiz.app/Contents/MacOS
	mkdir -m755 -p Rexuiz/Rexuiz.app/Contents/Resources/English.lproj
	install -m 755 scripts/Rexuiz.app/Contents/MacOS/rexuiz-dprm-sdl Rexuiz/Rexuiz.app/Contents/MacOS/
	install -m 755 scripts/Rexuiz.app/Contents/PkgInfo Rexuiz/Rexuiz.app/Contents/
	install -m 755 scripts/Rexuiz.app/Contents/Resources/English.lproj/InfoPlist.strings Rexuiz/Rexuiz.app/Contents/Resources/English.lproj/
	install -m 755 scripts/Rexuiz.app/Contents/Resources/Rexuiz.icns Rexuiz/Rexuiz.app/Contents/Resources/
	install -m 755 scripts/Rexuiz.app/Contents/Info.plist Rexuiz/Rexuiz.app/Contents/
	install -m 755 $(DPDIR)/rexuiz-sdl Rexuiz/Rexuiz.app/Contents/MacOS/rexuiz-dprm-sdl-bin
endif
endif

stand-alone: stand-alone-engine stand-alone-data

gmqcc:
	cd gmqcc && cmake . && make

update-qc: gmqcc
	cd 1vs1 && make QCC=../../../gmqcc/gmqcc SV_PROGNAME=progs.dat CL_PROGNAME=csprogs.dat CFG_NAME=rexuiz-extra.cfg SET_CURL_PACKAGE=no
	install -m 644 1vs1/progs.dat 1vs1/csprogs.dat 1vs1/menu.dat 1vs1/rexuiz-extra.cfg rexuiz.pk3/
	install -m 644 1vs1/translations/*.po 1vs1/rexuiz-extra.cfg rexuiz-data.pk3/
