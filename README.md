# devops-netology
new line
terraform\.gitignore
**/.terraform/*
Будут проигнорированы все вложенные файлы и папки в каталоге .terraform

*.tfstate
*.tfstate.*
Будут проигнорированы все файлы с раширением *.tfstate и где в названии присутствует .tfstate.

crash.log
Игнорировать данный лог

*.tfvars
Игнорировать .tfvars расширение

override.tf
override.tf.json
*_override.tf
*_override.tf.json
Игнорировать данные файлы и файлы с именем, заканчивающиеся на _override.tf или _override.tf.json

.terraformrc
terraform.rc
Игнорировать CLI конфиги



