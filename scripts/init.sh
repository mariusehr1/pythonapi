

aws configure

echo "Please enter the URL of your ECR (e.g 021321542563.dkr.ecr.eu-west-3.amazonaws.com)"
read reg

echo "Building the docker image ..."

docker build -t $reg:latest ../api

echo "Logging into the registry ..."

docker login https://$reg -u AWS -p $(aws ecr get-login-password)

echo "Pushing the previously created image to the regitry ..."

docker push $reg

echo "Generating a fresh pair of ssh keys ..."

mkdir ../ssh-keys && ssh-keygen -t rsa -f ../ssh-keys/id_rsa_aws -q -N ""

echo "Creating the docker credential file for our future servers ..." 

cred=$(echo -n AWS:$(aws ecr get-login-password) | base64 | tr -d "[:space:]" ) 
json='{"auths": {"'$reg'": {"auth": "'$cred'"}},"HttpHeaders": {"User-Agent": "Docker-Client/19.03.8 (linux)"}}'
echo $json > ../ansible/.cred

#Replacing the line starting with an ExecStart with our registry 
servicedir="../ansible/.service"
replace="ExecStart=/usr/bin/docker run --name iktos -p 80:5000 $reg:latest"
sed -i '/ExecStart/d' $servicedir && sed -i "6i\\$replace" $servicedir


echo "All set, now go into the terraform directory and run \"terraform plan\" followed by \"terraform apply\" and it should return the loadbalancers's URL!"
echo "Wait for a minute or two and your instances should be reachable"
