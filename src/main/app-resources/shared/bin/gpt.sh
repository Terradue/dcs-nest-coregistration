#! /bin/sh

export NEST_HOME=$_CIOP_APPLICATION_PATH/shared

if [ -z "$NEST_HOME" ]; then
    echo
    echo Error: NEST_HOME not found in your environment.
    echo Please set the NEST_HOME variable in your environment to match the
    echo location of the NEST 5.x installation
    echo
    exit 2
fi

. "$NEST_HOME/bin/detect_java.sh"

$app_java_home/bin/java \
	-server -Xms512M -Xmx3000M -XX:PermSize=512m -XX:MaxPermSize=512m -Xverify:none \
    -XX:+AggressiveOpts -XX:+UseFastAccessorMethods \
    -XX:+UseParallelGC -XX:+UseNUMA -XX:+UseLoopPredicate -XX:+UseStringCache \
    -Dceres.context=nest \
    "-Dnest.mainClass=org.esa.beam.framework.gpf.main.Main" \
    "-Dnest.home=$NEST_HOME" \
	-Dnest.application_tmp_folder=$TMPDIR \
	"-Dncsa.hdf.hdflib.HDFLibrary.hdflib=$NEST_HOME/lib/libjhdf.so" \
    "-Dncsa.hdf.hdf5lib.H5.hdf5lib=$NEST_HOME/lib/libjhdf5.so" \
    -jar $NEST_HOME/lib/ceres-launcher.jar "$@"

exit 0
