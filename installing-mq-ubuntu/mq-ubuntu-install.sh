#!/bin/bash
# -*- mode: sh -*-


# Script para instalar IBM MQ on Ubuntu
# Requiere apt
# Se necesita permisos root para algunos pasos

# Directorio a descargar MQ Packages
MQ_PACKAGES_DOWNLOAD_DIRECTORY=/tmp
MQ_FILE=9.3.5.0-IBM-MQ-Advanced-for-Developers-UbuntuLinuxX64

# Create group "mqm"
echo "******* Create Group mqm *******"
echo
getent group mqm
returnCode=$?
if [ $returnCode -eq 0 ]
then
    echo ">>>>> Group mqm exists. Proceeding with install. <<<<<"
    echo
else
    echo ">>>>> Group mqm does not exist! <<<<<"
    echo ">>>>> Adding group mqm. <<<<<"
    addgroup --gid 1001 mqm
    echo ">>>>> Group mqm added successfully! <<<<<"
    echo
fi

# Create user "mqm"
echo "******* Create User mqm *******"
echo
#grep mqm /etc/passwd
getent passwd mqm
returnCode=$?
if [ $returnCode -eq 0 ]
then
    echo ">>>>> User mqm exists. Proceeding with install. <<<<<"
    echo
else
    echo ">>>>> User mqm does not exist! <<<<<" 
    echo ">>>>> Adding user mqm. <<<<<"
    useradd -d /var/mqm --uid 1001 mqm -g mqm
    echo ">>>>> User mqm added successfully! <<<<<"
    echo
fi

# Create group "mqclient"
echo "******* Create Group mqclient *******"
echo
getent group mqclient
returnCode=$?
if [ $returnCode -eq 0 ]
then
    echo ">>>>> Group mqclient exists. Proceeding with install. <<<<<"
    echo
else
    echo ">>>>> Group mqclient does not exist! <<<<<" 
    echo ">>>>> Adding group mqclient. <<<<<"
    addgroup mqclient
    echo ">>>>> Group mqclient added successfully! <<<<<"
fi

# Create user "app"
echo "******* Create User app *******"
echo
grep app /etc/passwd
returnCode=$?
if [ $returnCode -eq 0 ]
then
    echo ">>>>> User app exists. Proceeding with install. <<<<<"
    adduser app mqclient
    echo
else
    echo ">>>>> User app does not exist! <<<<<" 
    echo ">>>>> Adding user app. <<<<<"
    useradd app -g mqclient
    echo ">>>>> User app added successfully! <<<<<"
    echo
fi

# Navigating to a directory that is accessible by the user _apt (suggested is /tmp - could be replaced)
echo "******* Navigating to directory "${MQ_PACKAGES_DOWNLOAD_DIRECTORY} " *******"
cd ~
cd ${MQ_PACKAGES_DOWNLOAD_DIRECTORY}

# Unzip and extract .tar.gz file
echo "******* Unzip and extract .tar.gz file *******"
gunzip ${MQ_FILE}.tar.gz
echo ".gz extract complete"
echo
tar -xf ./${MQ_FILE}.tar
returnCode=$?
if [ $returnCode -eq 0 ]
then 
    echo "File extraction complete"
    echo
else
    echo "File extraction failed. See return code: " $returnCode
    exit $returnCode
fi

# Accept the license
cd MQServer
./mqlicense.sh -accept
returnCode=$?
if [ $returnCode -eq 0 ]
then
    echo "license accepted"
    echo
else
    echo "license not accepted"
    exit $returnCode
fi

# Create a .list file to let the system add the new packages to the apt cache
cd /etc/apt/sources.list.d
MQ_PACKAGES_LOCATION=${MQ_PACKAGES_DOWNLOAD_DIRECTORY}/MQServer
echo "deb [trusted=yes] file:$MQ_PACKAGES_LOCATION ./" > mq-install.list
apt-get update
returnCode=$?
if [ $returnCode -eq 0 ]
then
    echo "apt cache update succeeded."
    echo
else
    echo "apt cache update failed! See return code: " $returnCode
    exit $returnCode
fi

echo "Beginning MQ install"
apt-get install -y "ibmmq-*"
returnCode=$?
if [ $returnCode -eq 0 ]
then
    echo "Install succeeded."
else
    echo "Install failed. See return code: " $returnCode
    exit $returnCode
fi

echo "Checking MQ version"
/opt/mqm/bin/dspmqver
returnCode=$?
if [ $returnCode -ne 0 ]
then
    echo "Error with dspmqver. See return code: " $returnCode
    exit $returnCode
fi

# Delete .list file and run apt update again to clear the apt cache
rm /etc/apt/sources.list.d/mq-install.list
apt-get update
returnCode=$?
if [ $returnCode -ne 0 ]
then
    echo "Could not delete .list file /etc/apt/sources.list.d/mq-install.list."
    echo " See return code: " $returnCode
else
    echo "Successfully removed .list file"
fi

exec sudo -u mqm /bin/bash - << eof
cd /opt/mqm/bin
. setmqenv -s
returnCode=$?
if [ $returnCode -eq 0 ]
then
    echo "MQ environment set"
else
    echo "MQ environment not set. See return code: " $returnCode
    exit $returnCode
fi

# Create and start a queue manager
crtmqm QM1
returnCode=$?
if [ $returnCode -eq 0 ]
then
    echo "Successfully created a queue manager" 
else
    echo "Problem when creating a queue manager. See return code: " $returnCode
    exit $returnCode
fi
strmqm QM1
returnCode=$?
if [ $returnCode -eq 0 ]
then
    echo "Successfully started a queue manager" 
else
    echo "Problem when starting a queue manager. See return code: " $returnCode
    exit $returnCode
fi

eof
exit 0
