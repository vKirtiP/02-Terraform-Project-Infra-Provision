
# Infrastructure Provisioning with Terraform

- The aim of this project is to provision an infrastructure environment in AWS using Terraform to host a web and a database server.

- The infrastructure will include a Virtual Private Cloud (VPC), subnets (private and public), security group, internet gateway (IGW), route table for the public subnet, instance for web-server and database server, elastic IP, and NAT gateway with a route table.

- Terraform will be used to define the infrastructure as code and automate the provisioning process.






## Architecture

![App Screenshot](https://github.com/vKirtiP/Terraform-Projects/blob/main/Infra-Prov/Infra_prov.png)

## Deployment

To deploy this Provision 

```
  terraform init
```
```
  terraform plan
```
```
  terraform apply
```

  
