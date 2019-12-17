#!/bin/bash

#-------------------------------- Azure Build Agent ------------------------------------------

AzureAuthPatToken=$1
AzureAgentPool=$2
AzureBuildAgent=$3
AzureVSTSAccount=${4:-'telstradx'}

echo "Installing the Linux build agent pre-requisites for Ubuntu"
sudo apt-get install -y zlib1g-dev libkrb5-dev
sudo apt-get install -y libunwind8 libcurl3
sudo apt-add-repository ppa:git-core/ppa \n
sudo apt-get update
sudo apt-get install -y git
sudo apt-get install -y libcurl4-openssl-dev
echo "Installed the required packages for the linux build agent"

echo "Configure and start the Azure Linux build agent"
mkdir ~/myagent
sudo chown root:root -R ~/myagent
wget -P ~/myagent/ https://vstsagentpackage.azureedge.net/agent/2.160.1/vsts-agent-linux-x64-2.160.1.tar.gz
tar zxvf ~/myagent/vsts-agent-linux-x64-2.160.1.tar.gz -C ~/myagent/
bash ~/myagent/config.sh --unattended  --url https://dev.azure.com/$AzureVSTSAccount --auth pat --token $AzureAuthPatToken --pool $AzureAgentPool --agent $AzureBuildAgent --work usr/local/agent_work
nohup bash ~/myagent/run.sh > /dev/null 2>&1 &
echo "Linux Build Agent started running"

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
echo "Installed Azure CLI"

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
echo "Installed the Docker Engine CE"

#----------------------------------------- Kubectl -------------------------------------------------

echo "Installing and Setting up kubectl"
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
echo "Installed kubectl"

#-------------------------------------------- sbt ---------------------------------------------------

echo "Installing sbt"
sudo apt-get install -y openjdk-8-jdk
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
sudo apt-get update
sudo apt-get install -y sbt
echo "Installed sbt"

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
echo "Installed .NET Core SDK and Runtime"

#---------------------------------------- Nodejs and NPM -----------------------------------------------

echo "Installing nodejs and npm"
sudo apt-get install -y gcc g++ make
curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash -
sudo apt-get update
sudo apt install -y nodejs
echo "Installed nodejs and npm"

#------------------------------------------- Kubeseal ---------------------------------------------------

echo "Installing Kubeseal Client"
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.9.6/kubeseal-linux-amd64 -O kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
echo "Installed Kubeseal client"

#------------------------------------------- end of script -----------------------------------------------
