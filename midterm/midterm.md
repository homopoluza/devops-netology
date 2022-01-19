## 1. Создайте виртуальную машину Linux.
```
vagrant up  
vagrant ssh
```

## 2. Установите ufw и разрешите к этой машине сессии на порты 22 и 443, при этом трафик на интерфейсе localhost (lo) должен ходить свободно на все порты.
```
sudo ufw allow 22  
sudo ufw allow 443  
sudo ufw allow from 127.0.0.1
sudo ufw enable
```

## 3. Установите hashicorp vault
```
 curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -  
  sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"  
 sudo apt-get update && sudo apt-get install vault
 ```

## 4. Cоздайте центр сертификации по инструкции и выпустите сертификат для использования его в настройке веб-сервера nginx (срок жизни сертификата - месяц).

Согласно инструкции в отдельном терминале открываем Vault dev server  
```
vault server -dev -dev-root-token-id root  
```
 Экспортируем переменные окружения  
```
export VAULT_ADDR=http://127.0.0.1:8200  
export VAULT_TOKEN=root  
```
 Генерируем самоподписанный корневой сертификат
```
vault secrets enable pki  
vault secrets tune -max-lease-ttl=87600h pki    

vault write -field=certificate pki/root/generate/internal \
     common_name="example.com" \
     ttl=87600h > CA_cert.crt  
     
vault write pki/config/urls \
     issuing_certificates="$VAULT_ADDR/v1/pki/ca" \
     crl_distribution_points="$VAULT_ADDR/v1/pki/crl"

```
 Генерируем промежуточный сертификат
```
vault secrets enable -path=pki_int pki  
vault secrets tune -max-lease-ttl=43800h pki_int    

vault write -format=json pki_int/intermediate/generate/internal \
     common_name="example.com Intermediate Authority" \
     | jq -r '.data.csr' > pki_intermediate.csr  
     
vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr \
     format=pem_bundle ttl="43800h" \
     | jq -r '.data.certificate' > intermediate.cert.pem  
     
vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
```
 Запрос конечного сертификата в формате json и его запись
```
vault write  pki_int/roles/example-dot-com \
     allowed_domains="example.com" \
     allow_subdomains=true \
     max_ttl="720h"

 vault write -format=json pki_int/issue/example-dot-com common_name="netology.example.com" ttl="24h" > netology.example.com.crt

  vagrant@vagrant:~$  cat netology.example.com.crt | jq -r .data.certificate > netology.example.com.crt.pem
vagrant@vagrant:~$ cat netology.example.com.crt | jq -r .data.issuing_ca >> netology.example.com.crt.pem
vagrant@vagrant:~$ cat netology.example.com.crt | jq -r .data.private_key > netology.example.com.crt.key
```
## 5. Установите корневой сертификат созданного центра сертификации в доверенные в хостовой системе.

![alt text](https://github.com/homopoluza/devops-netology/blob/main/midterm/cert1.png)  
![alt text](https://github.com/homopoluza/devops-netology/blob/main/midterm/cert.png)

## 6. Установите nginx
```
sudo apt install nginx
```

## 7. По инструкции настройте nginx на https, используя ранее подготовленный сертификат

Создадим отдельную директорию для нашего домена, в которой будут содержаться настройки. Переназначим директорию для текущего пользователя и разрешения. 
```
vagrant@vagrant:~$ sudo mkdir -p /var/www/netology.example.com/html  
vagrant@vagrant:~$ sudo chown -R $USER:$USER /var/www/netology.example.com/html  
vagrant@vagrant:~$ sudo chmod -R 755 /var/www  
```
Создадим тестовую страничку

```
nano /var/www/netology.example.com/html/index.html  

<html>
    <head>
        <title>Welcome to your_domain!</title>
    </head>
    <body>
  <h1>netology.example.com is working</h1>
    </body>
</html>
```

Настроим блок сервера согласно инструкции

```
sudo nano /etc/nginx/sites-available/netology.example.com  

server {
       listen 443 ssl;


       server_name netology.example.com;

       ssl on;
       ssl_certificate /var/www/netology.example.com/ssl/netology.example.com.crt.pem;
       ssl_certificate_key /var/www/netology.example.com/ssl/netology.example.com.crt.key;

       root /var/www/netology.example.com/html;
       index index.html;

       location / {
               try_files $uri $uri/ =404;
       }
}

server {
       listen 81;

       server_name netology.example.com;

       root /var/www/netology.example.com/html;
       index index.html;

       location / {
               try_files $uri $uri/ =404;
       }
}
```
```
sudo ln -s /etc/nginx/sites-available/netology.example.com /etc/nginx/sites-enabled/
vagrant@vagrant://var/www/netology.example.com/ssl$ sudo nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
sudo service nginx restart
```
## 8. Откройте в браузере на хосте https адрес страницы, которую обслуживает сервер nginx.


