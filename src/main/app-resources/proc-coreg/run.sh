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



while read list
do
  # create a folder for the input products (results of node_expression) 
  mkdir -p $TMPDIR/input

  # copy the list
  ciop-log "DEBUG" "list: $list"
  local_list=`echo $list | ciop-copy -o $TMPDIR -`

  /application/shared/bin/gpt.sh CreateStack  \
    -Pextent=$extent \
    -PresamplingType=$resamplingType \
    -PmasterBands=i::subset_of_ERS-1_SAR_SLC-ORBIT_21159_DATE__1-AUG-1995_21_16_39,q::subset_of_ERS-1_SAR_SLC-ORBIT_21159_DATE__1-AUG-1995_21_16_39 \
    -PsourceBands=i::subset_of_ERS-2_SAR_SLC-ORBIT_1486_DATE__2-AUG-1995_21_16_42,q::subset_of_ERS-2_SAR_SLC-ORBIT_1486_DATE__2-AUG-1995_21_16_42 /Users/fbrito/Downloads/Etna_ERS/subset_of_ERS-1_SAR_SLC-ORBIT_21159_DATE__1-AUG-1995_21_16_39.dim /Users/fbrito/Downloads/Etna_ERS/subset_of_ERS-2_SAR_SLC-ORBIT_1486_DATE__2-AUG-1995_21_16_42.dim \
    -t $TMPDIR/createstack.dim

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
    -t $TMPDIR/warp.dim        
  
  
   
done



