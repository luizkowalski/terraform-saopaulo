# Terraform - Sao Paulo

Creates a machine to be used for tunnel


### Installation

Go to your AWS console and create a key pair file, download it and put it on the same folder as this project

Next, create a file called `terraform.tfvars` with the following content

```
aws_access_key = "YOUR_KEY"
aws_access_secret = "YOUR_SECRET"
key_pair = "YOUR_KEY_PAIR_FILE"
```

Note that the `key_pair` variabe does not include the `.pem` extension


### Running

```
$ terraform plan
$ terraform apply
```

### Usage

After terraform apply all the changes, it will output the command you need to run in order to start tunneling. It will look like this

```
sshuttle --dns -r ec2-user@x.x.x.x 0/0 -e "ssh -A -i key_pair.pem"
```

Remember to install [sshuttle](https://github.com/sshuttle).

### Tear down

When you finish using the tunnel, just run `terraform destroy` to tear the infrastructure down so you don't pay for it