# Python API

The following projet will deploy a Flask API into a two EC2 instances with minimal setup: it contains the terraform description of our infrastructure as well as an an ansible playbook that will install all the necessary dependencies for our application to run. It will then run the API in a docker image (pulled from an ECR instance) wrapped in a systemd service: the application will be server on port 80 and be loadbalanced across two instances, we could easily add more instances if needed.



## Requirements

- An AWS account's credential with IAM (https://aws.amazon.com/fr/iam/)
- An ECR (Elastic Container Registry) setup with a reachable URL (https://aws.amazon.com/fr/ecr/)
- Docker 
- Terraform
- Ansible
- AWS-CLI 
- A bash prompt as well as basic crypto utilities in order to generate SSH keypairs 

## Usage

1 - Clone the repository

```
git clone https://github.com/mariusehr1/pythonapi.git
cd iktos
```

2 - Launch the setup script, you will be prompted for your AWS credentials as well as the container registry's URL
(Note that it is important to go inside the directory first)

```
cd scripts && ./init.sh
```
3 - You are now ready to run terraform

```
cd ../terraform && terraform plan && terraform apply
```
3 - If everything went as expected, wait a couple minutes and look at your application running.
```
curl [LOADBALANCER'S IP]/age/max
```
## API description

This API contains 4 routes :
 
 ```
 /${columnName}/mean
 ```
 returns the mean value for a given column name, cannot be done if the column type is a string

 ```
 /${columnName}/max
 ```
 returns the max value for a given column name

  ```
 /${columnName}/mostfrequentvalue
 ```
 returns the most frequent value for a given column name

  ```
 /line/${index}
 ```
 returns the jsonified row for a given index

## Troubleshooting

SSH directly to the web server
```
ssh -i ../ssh-keys/id_rsa_aws ubuntu@[IP we got before]
```
This should do the trick for a simple copy/paste
```
ssh -i ../ssh-keys/id_rsa_aws ubuntu@`terraform state show aws_instance.web[0] | grep "public_ip" | awk '{print $3}' | tail -n1 |  sed 's/"//g'`
```
Check that the container is running
```
sudo docker ps 
```
Check the systemd service logs on the webserver
```
journalctl -u itkos.service
```


## TODO

 #### - Having an nginx instance in front of our container for each servers: this would allow us to run https everywhere if we had the loadbalancer mapped to a DNS entry 

 #### - Having a shared database for our instances would allow for users to interact with the data (e.g. making POST requests for example)

 #### - Having the systemd service not run as root, same thing applies for the container

 #### - Deploy this application in Kubernetes or a Docker Swarm for maximum scaling