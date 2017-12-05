# Terraform - Sao Paulo

Creates a machine to be used for tunnel
```
export TF_VAR_aws_access_key=xxxx
export TF_VAR_aws_access_secret=xxx

terraform plan
terraform apply
```

### sshuttle

```
sshuttle --dns -r ec2-user@x.x.x.x 0/0 -e "ssh -A -i spkeypar.pem"
```
