#!/bin/bash

# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}

# define the exit codes
SUCCESS=0
ERR_CREATESTACK=10
ERR_GCPSELECTION=20
ERR_WARP=30

# add a trap to exit gracefully
function cleanExit ()
{
   local retval=$?
   local msg=""
   case "$retval" in
     $SUCCESS) msg="Processing successfully concluded";;
     $ERR_CREATESTACK) msg="gpt returned an error in CreateStack operator";;
     $ERR_GCPSELECTION) msg="gpt returned an error in GCP-Selection operator";;
     $ERR_WARP) msg="gpt returned an error in Warp operator";;
     *) msg="Unknown error";;
   esac
   [ "$retval" != "0" ] && ciop-log "ERROR" "Error $retval - $msg, processing aborted" || ciop-log "INFO" "$msg"
   exit $retval
}

trap cleanExit EXIT

# CreateStack parameters
resamplingType="`ciop-getparam resamplingType`"
extent="`ciop-getparam extent`"

# GCP-Selection
applyFineRegistration="`ciop-getparam applyFineRegistration`"        
coarseRegistrationWindowHeight="`ciop-getparam coarseRegistrationWindowHeight`"
coarseRegistrationWindowWidth="`ciop-getparam coarseRegistrationWindowWidth`"
coherenceThreshold="`ciop-getparam coherenceThreshold`"         
coherenceWindowSize="`ciop-getparam coherenceWindowSize`"            
columnInterpFactor="`ciop-getparam columnInterpFactor`"            
computeOffset="`ciop-getparam computeOffset`"               
fineRegistrationWindowHeight="`ciop-getparam fineRegistrationWindowHeight`"  
fineRegistrationWindowWidth="`ciop-getparam fineRegistrationWindowWidth`"   
gcpTolerance="`ciop-getparam gcpTolerance`"                  
maxIteration="`ciop-getparam maxIteration`"                    
numGCPtoGenerate="`ciop-getparam numGCPtoGenerate`"               
onlyGCPsOnLand="`ciop-getparam onlyGCPsOnLand`"                
rowInterpFactor="`ciop-getparam rowInterpFactor`"              
useSlidingWindow="`ciop-getparam useSlidingWindow`"           
                                           
# Warp
interpolationMethod="`ciop-getparam interpolationMethod`"
openResidualsFile="`ciop-getparam openResidualsFile`"
rmsThreshold="`ciop-getparam rmsThreshold`"
warpPolynomialOrder="`ciop-getparam warpPolynomialOrder`"

# get the master

# create a folder for the input products: master and slave(s)
mkdir -p $TMPDIR/input
  
# loop through the slave(s) 
slave_list=""
sourceBands=""
masterBands=""

while read slave
do

  local_slave=`echo $slave | ciop-copy -o $TMPDIR/input -`
  base_slave=`basename $local_slave`
  
  slave_list="$slave_list $local_slave.dim"

  if [ "$masterBands" == "" ]; then
    masterBands="`echo {Amplitude::ENVISAT-,Intensity::ENVISAT-}$base_slave | tr ' ' ','`"
  else
    if [ "$sourceBands" == "" ]; then 
      sourceBands="`echo {Amplitude::ENVISAT-,Intensity::ENVISAT-}$base_slave | tr ' ' ','`" 
    else
      sourceBands="$sourceBands,`echo {Amplitude::ENVISAT-,Intensity::ENVISAT-}$base_slave | tr ' ' ','`"
    fi
  fi 

done

ciop-log "DEBUG" "master: $masterBands"
ciop-log "DEBUG" "slave: $sourceBands"

ciop-log "INFO" "Create stack"

/application/shared/bin/gpt.sh CreateStack  \
  -Pextent="$extent" \
  -PresamplingType="$resamplingType" \
  -PmasterBands="$masterBands" \
  -PsourceBands="$sourceBands" \
  -t $TMPDIR/createstack.dim \
  $local_master $slave_list

[ $? != 0 ] && exit $ERR_CREATESTACK

ciop-log "INFO" "GCP-Selection"

/application/shared/bin/gpt.sh GCP-Selection \
  -PapplyFineRegistration="$applyFineRegistration" \
  -PcoarseRegistrationWindowHeight="$coarseRegistrationWindowHeight" \
  -PcoarseRegistrationWindowWidth="$coarseRegistrationWindowWidth" \
  -PcoherenceThreshold="$coherenceThreshold" \
  -PcoherenceWindowSize="$coherenceWindowSize" \
  -PcolumnInterpFactor="$columnInterpFactor" \
  -PcomputeOffset="$computeOffset" \
  -PfineRegistrationWindowHeight="$fineRegistrationWindowHeight" \
  -PfineRegistrationWindowWidth="$fineRegistrationWindowWidth" \
  -PgcpTolerance="$gcpTolerance" \
  -PmaxIteration="$maxIteration" \
  -PnumGCPtoGenerate="$numGCPtoGenerate" \
  -PonlyGCPsOnLand="$onlyGCPsOnLand" \
  -ProwInterpFactor="$rowInterpFactor" \
  -PuseSlidingWindow="$useSlidingWindow" \
  -t $TMPDIR/gcpselection.dim \
  $TMPDIR/createstack.dim
  
[ $? != 0 ] && exit $ERR_GCPSELECTION

ciop-log "INFO" "Warp"

/application/shared/bin/gpt.sh Warp \
  -PinterpolationMethod="$interpolationMethod" \
  -PopenResidualsFile="$openResidualsFile" \
  -PrmsThreshold="$rmsThreshold" \
  -PwarpPolynomialOrder="$warpPolynomialOrder" \
  -t $TMPDIR/coreg.dim \
  $TMPDIR/gcpselection.dim  

[ $? != 0 ] && exit $ERR_WARP

tar -C $TMPDIR -czf $TMPDIR/coreg.tgz coreg.dim coreg.data

ciop-publish -m $TMPDIR/coreg.tgz



