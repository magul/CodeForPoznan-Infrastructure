# Code for Poznań - Infrastructure

Repository contains description of Code for Poznań infrastructure.
You'll need AWS credentials into our organization and a tunnel to our bastion server 
in order to work with this code. This can't be done unless you've been added by one of admins (see ./admins.tf file).

#### Initialize project

```
terraform init
```


#### Check what terraform intend to change

```
terraform plan
```


#### Run the change

```
terraform apply
```


#### More commands

```
make help
```

## License

Code is licensed under [MIT LIcense](./LICENSE).
Documents are licensed under [CC-BY-SA-4.0-PL](https://creativecommons.org/licenses/by-sa/4.0/deed.pl) (with the exception of Code for Poznań logo).
