# Prova pratica

## Descrizione
Deploy automatico di una infrastruttura in HA che scala orizzontalmente con installazione automatica di wordpress su istanze EC2.

Di default il sito punterà all'url www.provapratica.com definito in terraform.tfvars.

## File
```
├── README.md
├── alb.tf
├── asg.tf
├── bastion.pem
├── bastion.pub
├── ec2-bastion.tf
├── ec2-wordpress.tf
├── efs.tf
├── provider.example
├── rds.tf
├── route53.tf
├── sg.tf
├── terraform.tfvars
├── variables.tf
├── vpc.tf
└── wp_script.sh
```

## Servizi AWS utilizzati

* VPC
* RDS
* EFS
* EC2
* Cloudwatch
* Route53

## Setup
1. Valorizzazione parametri

Nel file provider.example valorizzare le variabili access_key, secret_key e region di un utente che abbia policy Administrator su IAM 
```
access_key = "<ACCESS_KEY>"
secret_key = "<SECRET_KEY>"
region = "<REGION>"
```

Nel file terraform.example valorizzare la varibile owner.
```
owner = "<OWNER_ID>"
```

2. Rinominare i file:
* provider.example in provider.tf 
* terraform.example in terraform.tfvars

3. Accesso al bastion

L'accesso al bastion avviene in SSH precaricando la propria chiave pubblica che deve trovarsi in ~/.ssh/id_rsa.pub

4. Generare la chiave di accesso tramite bastion nella cartella del progetto
```
openssl genrsa -out bastion.pem 2048
chmod 0600 bastion.pem
ssh-keygen -y -f bastion.pem > bastion.pub 
```

## Comandi
```
$ terraform init
$ terraform plan 
$ terraform apply -auto-approve
$ terraform terraform destroy -target="aws_instance.web"
```

## Test raggiungibilità
Per effettuare un test di raggiungibilità del sito effettuare prima un ping al bilanciatore e modificare il proprio /etc/hosts
```
terraform state show "aws_alb.wp-elb" | grep dns_name | awk '{print $3}' | sed s/\"//g | xargs ping
```


```
<IP_BILANCIATORE> www.provapratica.com
```

## Test sul sito
collegarsi su http://www.provapratica.com/wp-admin/ ed utilizzare le credenziali definite in terraform.tfvars
