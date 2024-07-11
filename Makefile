###################### Terraform  ########################################
tf-init :
	terraform -chdir=./terraform init 
tf-plan: 
	terraform -chdir=./terraform plan 
tf-apply: 
	terraform -chdir=./terraform apply
ec2-private-key: 
	terraform -chdir=./terraform output -raw private_key
ec2-dns: 
	terraform -chdir=./terraform output -raw ec2_public_dns
airflow-ec2-dns: 
	terraform -chdir=./terraform output -raw airflow_ec2_public_dns
rds-host: 
	terraform -chdir=./terraform output -raw rds_host
rds-db: 
	terraform -chdir=./terraform output -raw rds_db_name
tf-destroy: 
	terraform -chdir=./terraform destroy

dbt-up: 
	cd dbt && docker compose up --build -d

dbt-debug: 
	cd dbt && docker exec -it dbt bash -c "cd dbt && dbt debug --profiles-dir=."


dbt-test: 
	cd dbt_airflow_snowflake/dbt &&  docker exec -it dbt bash -c "cd dbt && dbt test --profiles-dir=."


dbt-run: 
	cd dbt_airflow_snowflake/dbt &&  docker exec -it dbt bash -c "cd dbt && dbt run --profiles-dir=."


dbt-deps: 
	cd dbt_airflow_snowflake/dbt &&  docker exec -it dbt bash -c "cd dbt && dbt deps --profiles-dir=."


dbt-deploy: 
	cd dbt_airflow_snowflake/dbt && winpty docker exec -it dbt bash -c "cd dbt && dbt run --profiles-dir=. --target prod"



dbt-down: 
	cd dbt_airflow_snowflake && docker compose down