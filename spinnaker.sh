i#!/bin/bash
set -e env
read -p "Do you want to setup Spinnaker y or n? " sp
if [[ $sp == "y" ]]; then
	echo "**********Installing Prerequisites jenkins, openjdk-8-jdk, ansible*************"
	#sudo killall apt-get
	sudo apt clean
 	sudo apt update
	sudo apt upgrade -y
	sudo apt install openjdk-8-jdk -y
	sudo apt install git -y
	wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
	sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
	sudo apt update
	sudo apt install jenkins -y
	sudo sed -ie 's/HTTP_PORT=8080/HTTP_PORT=5656/g' /etc/default/jenkins
	sudo service jenkins restart
	echo
	echo "##############################"
	sudo cat /var/lib/jenkins/secrets/initialAdminPassword
	echo "##############################"
	echo
	echo "*********Installing halyard**************"
	curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
 	sudo bash InstallHalyard.sh
 	echo "*********Installing kubernetes***********"
 	git clone https://github.com/angudadevops/singlenode_kubernetes.git
 	cd singlenode_kubernetes/ && sudo bash install.sh
 	sleep 10
 	sudo usermod -a -G docker jenkins
	sudo service jenkins restart
 	echo "*********Configuring Halyard***********"
 	hal version list
	read -p "Enter Halyard Version from above list? " ver
	echo $ver
	hal config version edit --version $ver
 	hal config provider kubernetes enable
	CONTEXT=$(kubectl config current-context)
	echo $CONTEXT
	hal config provider kubernetes account add my-k8s-account     --context $CONTEXT
	hal config deploy edit --type distributed --account-name my-k8s-account
	hal shutdown
	sleep 5
	hal
	sleep 5
	echo "*********Configuring Storage for Halyard*********"
	read -p "Enter AWS account access key: " access
	read -p "Enter AWS account secret key: " secret
	read -p "Enter AWS S3 region: " reg
	read -p "Enter AWS S3 bucket name: " buck
	hal config storage s3 edit --access-key-id $access  --secret-access-key $secret --region $reg --bucket $buck
	hal config storage edit --type s3
	ip=$(hostname -I | awk '{print $1}')
	echo
	echo "Jenkins URL $ip:5656"
	echo
	echo "Checkout 'https://stackoverflow.com/questions/45466090/how-to-get-the-api-token-for-jenkins' to Enable Jenkins API Token"
	read -p "Did you setup jenkins y or n? " set
	if [[ $set == "y" ]]; then
		hal config ci jenkins enable
		read -p "Enter Jenkins Username? " user
		read -p "Enter Jenkins APIKEY? " api
		read -p "Enter Jenkins URL? " jurl
		export USERNAME=$user
    		export BASEURL=$jurl
    		export APIKEY=$api
	else
		echo "Please setup Jenkins Server, we will wait for you"
		secs=$((7 * 60))
		while [ $secs -gt 0 ]; do
   			echo -ne "$secs\033[0K\r"
   			sleep 1
   			: $((secs--))
		done
		read -p "Are you ready with Jenkins Server y or n: " ready
		if [[ $ready == "y" ]]; then
			hal config ci jenkins enable
			read -p "Enter Jenkins Username? " user
			read -p "Enter Jenkins APIKEY/Password? " api
			read -p "Enter Jenkins URL? " jurl
			export USERNAME=$user
    		export BASEURL=$jurl
    		export APIKEY=$api
    echo $APIKEY | hal config ci jenkins master add my-jenkins-master     --address $BASEURL     --username $USERNAME     --password

	echo "************** Deploying Halyard for Spinnaker***************"
 	hal deploy apply
 	secs=$((5 * 60))
	while [ $secs -gt 0 ]; do
   		echo -ne "$secs\033[0K\r"
   		sleep 1
   		: $((secs--))
	done
	kubectl get pods -n spinnaker
		fi
	else
		echo "Please setup Jenkins server ready"
	fi
fi

echo "*********** Your Spinnaker server is ready***********"
echo
echo "For ssh tunneling from your localhost run below command"
echo
echo "ssh -A –L 9000:localhost:9000 -L 8084:localhost:8084 -L 8087:localhost:8087 username@hostname"
echo
echo "After ssh tunneling run this command 'hal deploy connect'"
echo
echo "Please open your browser and access with localhost:9000"

