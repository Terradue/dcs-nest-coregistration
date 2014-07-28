#!/bin/bash

# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}

# define the exit codes
SUCCESS=0
ERR_GPT=10

# add a trap to exit gracefully
function cleanExit ()
{
   local retval=$?
   local msg=""
   case "$retval" in
     $SUCCESS) msg="Processing successfully concluded";;
     $ERR_GPT) msg="gpt returned an error";;
     *) msg="Unknown error";;
   esac
   [ "$retval" != "0" ] && ciop-log "ERROR" "Error $retval - $msg, processing aborted" || ciop-log "INFO" "$msg"
   exit $retval
}

trap cleanExit EXIT

# Apply-Orbit-File parameters
orbitType="`ciop-getparam orbitType`"

mkdir -p $TMPDIR/output

# loop through the inputs
while read input
do
  mkdir -p $TMPDIR/output

  local_input=`echo $input | ciop-copy -o $TMPDIR -`
  base_input=`basename $local_input | sed "s/.N1//"`

  ciop-log "INFO" "Processing $base_input" 

  /application/shared/bin/gpt.sh -e Apply-Orbit-File \
    -PorbitType="$orbitType" \
    -t $TMPDIR/output/${base_input}.dim \
    -Ssource=$local_input
  
  [ $? != 0 ] && exit $ERR_GPT 
 
  ciop-log "DEBUG" "`tree $TMPDIR`"
   
  tar -C $TMPDIR/output -f $TMPDIR/output/${base_input}.tgz -cz  $TMPDIR/output/${base_input}.d*
  
  ciop-publish $TMPDIR/output/${base_input}.tgz
  
  rm -f $local_input
  rm -fr $TMPDIR/output
done
