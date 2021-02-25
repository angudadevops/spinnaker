/opt/halyard/bin/halyard > /dev/null 2>&1 &
sleep 15
kubectl config set-cluster default --server=https://kubernetes.default --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
kubectl config set-context default --cluster=default
token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
kubectl config set-credentials user --token=$token
kubectl config set-context default --user=user
kubectl config use-context default
echo " "
echo -e "using Haylard Version as $halver"
echo
hal config version edit --version $halver
echo
hal config provider kubernetes enable
hal config provider kubernetes account add my-k8s-account
hal config deploy edit --type distributed --account-name my-k8s-account
echo
echo "config Securuty"
echo
#hal config security ui edit --override-base-url http://$HOST_IP:31000
hal config security ui edit --override-base-url $ui
#hal config security api edit --override-base-url http://$HOST_IP:32000
hal config security api edit --override-base-url $api
echo
echo "Config S3 Storage"
echo
hal config storage s3 edit --access-key-id $access  --secret-access-key $secret --region $reg --bucket $buck
hal config storage edit --type s3
echo
echo "Config Jenkins as CI"
echo
jenkins_apikey=$(curl -s -XPOST  -H "Jenkins-Crumb:$(curl -s --cookie-jar /tmp/cookies -u admin:admin "$jenkins_url/crumbIssuer/api/json" | jq -r '.crumb')" --cookie /tmp/cookies "$jenkins_url/me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken" --data 'newTokenName=default' --user admin:admin | jq -r '.data.tokenValue')
echo "Jenkins API Key"
echo "***********************"
echo $jenkins_apikey
echo "***********************"
echo
echo "Creating Jenkins Test Job"
echo
curl -s -XPOST "$jenkins_url/createItem?name=HelloBuild" -u $jenkins_user:$jenkins_apikey --data-binary @jenkins-job.xml -H "Content-Type:text/xml"
echo
hal config ci jenkins enable
echo $jenkins_apikey | hal config ci jenkins master add my-jenkins-master     --address $jenkins_url     --username $jenkins_user     --password
echo
hal deploy apply
sleep infinity
