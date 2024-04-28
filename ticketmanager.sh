#! /bin/bash
#author:Eli Choate
mkdir configurationLogs
#ticketID and IPaddress as user inputs for this script
intIPaddress=$1
strTicketID=$2
#URL containing tickets
strURL="https://www.swollenhippo.com/ServiceNow/systems/devTickets.php"
#URL curled into a json file
strCurledURL=$(curl -s "$strURL" | jq '.')
#index variable for itteration through parsed file
intIndex=0
intLen=$(echo ${strCurledURL} | jq "length")
#loop to itterate through json file from URL
while [ $intIndex -lt $intLen ]; do
#if statment to insure only desired ticket gets logged
if [ ${strTicketID} = $(echo ${strCurledURL} | jq -r .[${intIndex}].ticketID) ]; then
strTicketIDlog=$(echo ${strCurledURL} | jq -r .[${intIndex}].ticketID)
strRequestor=$(echo ${strCurledURL} | jq -r .[${intIndex}].requestor)
strStandardConfig=$(echo ${strCurledURL} | jq -r .[${intIndex}].standardConfig)

#debugging
echo ${strTicketIDlog}
echo ${strRequestor}
echo ${strStandardConfig}
fi







((intIndex++))
done



