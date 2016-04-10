#!/bin/bash

REQNUM=4
ST=5
ECHOCMD="$( which echo )"
CURLCMD="$( which curl )"
GREPCMD="$( which grep )"
SLEEPCMD="$( which sleep )"
AMBSERVER="server.devops.internal"
APIURL="http://$AMBSERVER:8080/api/v1"
USPW="admin:admin"
HTAG="X-Requested-By:MyCompany"



echo $ECHOCMD
echo $CURLCMD
echo $GREPCMD
echo $SLEEPCMD


function log() {
    $ECHOCMD "[$(date +"%T")][Cluster Deployment] ${1}"
}

function wait4hosts()
{
    local HOSTNUM=$( $CURLCMD -sS -u $USPW -X GET -i $APIURL/hosts | $GREPCMD -c 'host_name' )

    while [[ $HOSTNUM -lt $REQNUM ]]
        do
            log "Required hosts number is $REQNUM and we have $HOSTNUM"
            log "Waiting until hosts number will reach $HOSTNUM, sleeping for $ST seconds"
            $SLEEPCMD $ST
        done
    $ECHOCMD "All $HOSTNUM hosts are ready for deployment"
}

#wait4hosts

# Register Blueprint with Ambari
# $CURLCMD -u $USPW -X POST -H '$HTAG' $APIURL/blueprints/AutoClusterbp?validate_topology=false -d @bp.json
# log "REGISTERING BLUEPRINT WITH $HOSTNUM HOSTS" 
# $SLEEPCMD $ST
# Create cluster
# $CURLCMD -u $USPW -X POST -H '$HTAG' $APIURL/clusters/AutoCluster1 -d @map.json
# $ECHOCMD "CREATING CLUSTER"
