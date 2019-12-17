#!/bin/bash

# BuildAgentUbuntuSwInstall.sh
# This script is used to install required software on a ubuntu Azure Build Agent.
# This script will be in a public accessable location like Azure Storage and
# its url will be used in the Azure ARM template VM Extension resource to deploy on the new VM.
# This script will be downloaded on to `/var/lib/waagent/custom-script/download/0/` path on the VM.
# The Azure script extenstion produces a log at `/var/log/azure/custom-script/handler.log`
# To troubleshoot, first check the Linux Agent Log, ensure the extension ran, at /var/log/waagent.log
# For more info on how this works, visit https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux

# The parameters that it takes is 
# Azure Build Agent username as $1 - required parameter
# Azure Auth PAT token as $2 - required parameter
# Azure Agent pool name as $3 - required parameter
# Azure Build Agent name as $4 - optional, defaulted to the hostname
# Azure VSTS Account name as $5 - optional, defaulted to 'telstradx'

#-------------------------------- Azure Build Agent ------------------------------------------

AzureAgentUserName=$1
AzureAuthPatToken=$2
AzureAgentPool=$3
AzureBuildAgent=${4:-$(hostname)}
AzureVSTSAccount=${5:-'telstradx'}

echo "Installing the Linux build agent pre-requisites for Ubuntu"
sudo apt-get install -y zlib1g-dev libkrb5-dev
sudo apt-get install -y libunwind8 libcurl3
sudo apt-add-repository ppa:git-core/ppa \n
sudo apt-get update
sudo apt-get install -y git
sudo apt-get install -y libcurl4-openssl-dev
echo "Installed the required packages for the linux build agent"

echo "Configure and start the Azure Linux build agent"
AzureBuildAgentHome=/home/$AzureAgentUserName/myagent
su - $AzureAgentUserName -c "mkdir $AzureBuildAgentHome"
su - $AzureAgentUserName -c "wget -P $AzureBuildAgentHome/ https://vstsagentpackage.azureedge.net/agent/2.160.1/vsts-agent-linux-x64-2.160.1.tar.gz"
su - $AzureAgentUserName -c "tar zxvf $AzureBuildAgentHome/vsts-agent-linux-x64-2.160.1.tar.gz -C $AzureBuildAgentHome/"
sudo chown $AzureAgentUserName:$AzureAgentUserName -R $AzureBuildAgentHome
su - $AzureAgentUserName -c "bash $AzureBuildAgentHome/config.sh --unattended --url https://dev.azure.com/$AzureVSTSAccount --auth pat --token $AzureAuthPatToken --pool $AzureAgentPool --agent $AzureBuildAgent --work usr/local/agent_work"
su - $AzureAgentUserName -c "nohup bash $AzureBuildAgentHome/run.sh > /dev/null 2>&1 &"
if [[ $? -eq 0 ]]; then
  echo "Successfully Installed Azure Linux Build Agent"
else
  echo "ERROR: Something went wrong while installing Azure Linux Build Agent"
fi 

#------------------------------------ Azure CLI -----------------------------------------------

echo "Installing Azure CLI"
sudo apt-get update
sudo apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg
curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-get update
sudo apt-get install -y azure-cli
if [[ $? -eq 0 ]]; then
  echo "Successfully Installed Azure CLI"
else
  echo "ERROR: Something went wrong while installing Azure CLI"
fi 

#-------------------------------- Docker Engine CE ----------------------------------------------

echo "Installing Docker Engine CE"
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce=5:19.03.5~3-0~ubuntu-xenial docker-ce-cli=5:19.03.5~3-0~ubuntu-xenial containerd.io
if [[ $? -eq 0 ]]; then
  echo "Successfully Installed Docker Engine CE"
else
  echo "ERROR: Something went wrong while installing Docker Engine CE"
fi 

#----------------------------------------- Kubectl -------------------------------------------------

echo "Installing and Setting up kubectl"
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
if [[ $? -eq 0 ]]; then
  echo "Successfully Installed kubectl"
else
  echo "ERROR: Something went wrong while installing kubectl"
fi 

#-------------------------------------------- sbt ---------------------------------------------------

echo "Installing sbt"
sudo apt-get install -y openjdk-8-jdk
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
sudo apt-get update
sudo apt-get install -y sbt
if [[ $? -eq 0 ]]; then
  echo "Successfully Installed sbt"
else
  echo "ERROR: Something went wrong while installing sbt"
fi 

#-------------------------------- .NET Core Runtime and SDK ------------------------------------------

echo "Installing .NET Core SDK and Runtime"
echo "Install .NET dependencies"
sudo apt-get install -y liblttng-ust0 libcurl3 libssl1.0.0 libkrb5-3 zlib1g libicu55
wget -q https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y apt-transport-https
sudo apt-get update
sudo apt-get install -y dotnet-runtime-2.2
sudo apt-get update
sudo apt-get install -y dotnet-sdk-2.2
if [[ $? -eq 0 ]]; then
  echo "Successfully Installed .NET core SDK and Runtime"
else
  echo "ERROR: Something went wrong while installing .NET core SDK and Runtime"
fi 

#---------------------------------------- Nodejs and NPM -----------------------------------------------

echo "Installing nodejs and npm"
sudo apt-get install -y gcc g++ make
curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash -
sudo apt-get update
sudo apt install -y nodejs
if [[ $? -eq 0 ]]; then
  echo "Successfully Installed nodejs and npm"
else
  echo "ERROR: Something went wrong while installing nodejs and npm"
fi 

#------------------------------------------- Kubeseal ---------------------------------------------------

echo "Installing Kubeseal Client"
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.9.6/kubeseal-linux-amd64 -O kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
if [[ $? -eq 0 ]]; then
  echo "Successfully Installed Kubeseal client"
else
  echo "ERROR: Something went wrong while installing Kubeseal client"
fi 

#------------------------------------------- end of script -----------------------------------------------
