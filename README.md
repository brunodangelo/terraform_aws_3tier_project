# Terraform AWS 3-Tier Project

Explicación paso a paso: https://todotelco.com/aws-aplicacion-3-tier-arquitectura-de-3-capas-utilizando-terraform/

### Architecture / Arquitectura
![arquitectura 3tier](https://github.com/user-attachments/assets/be32dd0d-47f3-4731-94c6-1b9b5d01e702)

### Resources / Recursos
* 2 Auto Scaling groups
* 1 External Load Balancer
* 1 Internal Load Balancer
* 2 Targets groups
* 2 LB Listeners
* 4 Auto Scaling Group policies
* 4 CloudWatch Alarm
* 1 DynamoDB table
* 1 VPC
* 2 Public Subnets
* 2 Private Subnets
* 2 NAT Gateways
* 1 Internet Gateway

### Notes / Notas

* (English) Add the AWS credentials in "userdataback.sh" to allow connection with DynamoDB in NodeJS
* (Español) Agregar las credenciales de la cuenta en AWS en el archivo "userdataback.sh" para permitir la conexión con DynamoDB desde NodeJS

### Commands / Comandos

```
terraform init
```

```
terraform plan
```

```
terraform apply
```
