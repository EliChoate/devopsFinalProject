#! /bin/bash

strIP=$1
strTicketID=$2
strUsername=$3
eval "$(ssh-agent -s)"

ssh-add .ssh/gcp
scp -i .ssh/gcp serverSetup.sh "${strUsername}"@"${strIP}":/home/"${strUsername}"

ssh ${strUsername}@${strIP} "chmod 755 serverSetup.sh"
ssh ${strUsername}@${strIP} "./serverSetup.sh ${strIP} ${strTicketID}
