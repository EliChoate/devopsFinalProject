#! /bin/bash
#author:Eli Choate
mkdir -p configurationLogs
#ticketID and IPaddress as user inputs for this script
intIPaddress=$1
strTicketID=$2
strHostname=$(hostname)
touch ${strTicketID}.log
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
strDateTime=$(date +"%Y-%m-%d %H:%M:%S")
echo -e "TicketID: ${strTicketID}\nStart DateTime: ${strDateTime}\nRequestor: ${strRequestor}\nExternal IP address: ${intIPaddress}\nHostname: ${strHostname}\nStandard Configuration: ${strStandardConfig}\n\n " >> ${strTicketID}.log
for package in $(echo ${strCurledURL} | jq -r .[${intIndex}].softwarePackages[].install); do
strPackageName=$(echo "${strCurledURL}" | jq -r .[${intIndex}].softwarePackages[].name)
echo $strPackageName
echo -e "softwarePackage -  ${strPackageName}" >> ${strTicketID}.log
yes | sudo apt-get install ${package}
done
for config in $(echo "${strCurledURL}" | jq -r .[${intIndex}].additionalConfigs[].config); do
strConfigName=$(echo "${strCurledURL}" | jq -r .[${intIndex}].additionalConfigs[].name)
echo -e "\nadditional Config - ${strConfigName}" >> ${strTicketID}.log
strConfig=$(echo "${strCurledURL}" | jq -r '.[].additionalConfigs[].config')
if [[ ${config} == *"touch"* ]]; then
strConfig=$(echo "${strCurledURL}" | jq -r '.['${intIndex}'].additionalConfigs[] | select(.config | contains("touch")) | .config')
strTemp=$(echo "${strCurledURL}" | jq -r '.['${intIndex}'].additionalConfigs[] | select(.config | contains("touch")) | .config' | sed -n 's/.*\(\/var\/etc\/www\).*/\1/p')
mkdir -p $strTemp
fi
#debugging
echo "strConfigName: $strConfigName"
echo "strTemp: $strTemp"
echo "strConfig: $strConfig"
echo "config: $config"
eval "$strConfig"
done
for package in $(echo ${strCurledURL} | jq -r .[${intIndex}].softwarePackages[].install); do
strPackageName=$(echo "${strCurledURL}" | jq -r .[${intIndex}].softwarePackages[].name)
strVersionMsg=$(${package} -v)
echo $strPackageName
echo -e "Version - ${strPackageName} - ${strVersion}\n " >> ${strTicketID}.log
done
#debugging
echo ${strTicketIDlog}
echo ${strRequestor}
echo ${strStandardConfig}
echo ${strDateTime}
echo ${strSoftwarePackage}
fi
((intIndex++))
done
strDateTime=$(date +"%Y-%m-%d %H:%M:%S")
echo -e "\nTicket Closed\n" >> ${strTicketID}.log
echo -e "Completed On: ${strDateTime}" >> ${strTicketID}.log
