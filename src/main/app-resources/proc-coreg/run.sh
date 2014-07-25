#!/bin/bash

# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}

# define the exit codes
SUCCESS=0
ERR_BINNING=20
ERR_PCONVERT=30

# add a trap to exit gracefully
function cleanExit ()
{
   local retval=$?
   local msg=""
   case "$retval" in
     $SUCCESS) msg="Processing successfully concluded";;
     $ERR_BINNING) msg="gpt returned an error";;
     $ERR_PCONVERT) msg="pconvert returned an error";;
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
master="`ciop-getparam master`"
local_master=`echo $master | ciop-copy -o $TMPDIR/input -`
base_master=`basename $local_master`
  
masterBands="`echo {Amplitude::ENVISAT-,Intensity::ENVISAT-}$base_master`"
  
# loop through the slave(s) 
slave_list=""
$sourceBands=""
while read slave
do

  local_slave=`echo $slave | ciop-copy -o $TMPDIR/input -`
  base_slave=`basename $local_slave`
  
  slave_list="$slave_list $local_slave"

  if [ "$sourceBands" == "" ]; then 
    sourceBands="`echo {Amplitude::ENVISAT-,Intensity::ENVISAT-}$base_slave | tr ' ' ','`" 
  else
    sourceBands="$sourceBands,`echo {Amplitude::ENVISAT-,Intensity::ENVISAT-}$base_slave | tr ' ' ','`"
  fi

done

/application/shared/bin/gpt.sh CreateStack  \
  -Pextent=$extent \
  -PresamplingType=$resamplingType \
  -PmasterBands=$masterBands \
  -PsourceBands=$sourceBands \
  -t $TMPDIR/createstack.dim \
  $local_master $slave_list

/application/shared/bin/gpt.sh GCP-Selection \
  -PapplyFineRegistration=$applyFineRegistration \
  -PcoarseRegistrationWindowHeight=$coarseRegistrationWindowHeight \
  -PcoarseRegistrationWindowWidth=$coarseRegistrationWindowWidth \
  -PcoherenceThreshold=$coherenceThreshold \
  -PcoherenceWindowSize=$coherenceWindowSize \
  -PcolumnInterpFactor=$columnInterpFactor \
  -PcomputeOffset=$computeOffset \
  -PfineRegistrationWindowHeight=$fineRegistrationWindowHeight \
  -PfineRegistrationWindowWidth=$fineRegistrationWindowWidth \
  -PgcpTolerance=$gcpTolerance \
  -PmaxIteration=$maxIteration \
  -PnumGCPtoGenerate=$numGCPtoGenerate \
  -PonlyGCPsOnLand=$onlyGCPsOnLand \
  -ProwInterpFactor=$rowInterpFactor \
  -PuseSlidingWindow=$useSlidingWindow \
  -t $TMPDIR/gcpselection.dim \
  $TMPDIR/createstack.dim
  

/application/shared/bin/gpt.sh Warp \
  -PinterpolationMethod=$interpolationMethod \
  -PopenResidualsFile=$openResidualsFile \
  -PrmsThreshold=$rmsThreshold \
  -PwarpPolynomialOrder=$warpPolynomialOrder \
  -t $TMPDIR/coreg.dim        

tar -C $TMPDIR -f $TMPDIR/coreg.tgz -cz $TMPDIR/coreg.d*

ciop-publish -m $TMPDIR/coreg.tgz



