#scala version 2.11.12
MOD_BAT=openmodbat-3.3.jar
.PHONY: build clean run-simple run-complex show-trace
build:
	mkdir -p build
	scalac \
		-classpath lib/${MOD_BAT} \
		-sourcepath src \
		-deprecation \
		-verbose \
		-d build \
		-g:vars \
		src/model/*/*.scala
clean:
	rm -rf build
run-simple:
	time \
		scala \
		-classpath build lib/${MOD_BAT} \
		-s=10 \
		-n=5 \
		--abort-probability=0.02 \
		model.simple.SimpleListModel
run-complex:
	time \
		scala \
		-classpath build lib/${MOD_BAT} \
		-s=5 \
		-n=1000 \
		--abort-probability=0.02 \
		model.complex.LinkedListModel
run-counter:
	time \
		scala \
		-classpath build lib/${MOD_BAT} \
		-s=5 \
		-n=1000 \
		--abort-probability=0.02 \
		model.counter.Test
#example: make show-trace FILE=<file name>
show-trace:
	if [ "`echo ${FILE} | grep .err`" = "" ]
	then
		FILE1="${FILE}.err"
	else
		FILE1="${FILE}"
	fi
	cat $FILE1 | \
		sed -e 's/^\([a-z._A-Z]*Exception\)$/[91m\1[0m/' \
		-e 's/^\(.WARNING.\|.ERROR.\)/[31m\1[0m/' \
		-e 's/\([a-z/._A-Z:0-9]*\): *\([^:]*\): \(.*\)$/[40m[93m\1[0m:\2: [40m[97m\3[0m/'
