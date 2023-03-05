# Terraform

## Working Directory
For the prod environment, the working directory is `environment/prod`

```sh
cd environment/prod
```

## Test your changes

```
infisical run -- terraform plan
```


## Apply your changes
```
infisical run -- terraform apply
```

## Module not found error?
```
terraform init -upgrade
```