## Create a Backup Role for Gitlab with permissions to copy backups to S3

### First Generate PGP Keys
```sh
## export is optional temporary GNUPGHOME directory is created, default is $HOME/.gnupg
## passphrase in template is for demo purposes, not to be used in production.
## Leave it blank, it will prompt
export GNUPGHOME=$(mktemp -d)
gpg --batch --generate-key gpg-gen-template
```

### List secret keys
```sh
gpg --list-secret-keys
gpg --list-keys
```
### Export Public and Private key in non-armored format
```sh
gpg --export backup@iono.cloud > /tmp/public_key.gpg
gpg --export-secret-keys backup@iono.cloud > /tmp/private_key.gpg
```

### After Terraform run output secret_id_key and secret_access_key to retrieve [export is mandatory][ref2]
```
export GPG_TTY=$(tty)
terraform output access_key_id
terraform output secret_access_key | tr -d '"' | base64 --decode | gpg --decrypt
```

### In Gitlab server, edit gitlab.rb
#### fill in values gitlab_rails['backup_upload_connection'] & gitlab_rails['backup_upload_remote_directory']
```sh
sudo vi /etc/gitlab/gitlab.rb
```
### Reconfigure Gitlab server
```sh
sudo gitlab-ctl reconfigure
```

### Backup Gitlab configuration to AWS S3 bucket
```sh
sudo gitlab-backup create STRATEGY=copy
```

### See Also
How-To [gpg-encrypt-terraform-secrets][ref1]


[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

[ref1]: <https://menendezjaume.com/post/gpg-encrypt-terraform-secrets/>
[ref2]: <https://www.gnupg.org/documentation/manuals/gnupg/Invoking-GPG_002dAGENT.html>
