# Дипломное задание по курсу «DevOps-инженер»

### Преподаватель: Булат Замилов, Олег Букатчук, Руслан Жданов
### Дипломный практикум в YandexCloud

## Цели:

- Зарегистрировать доменное имя (любое на ваш выбор в любой доменной зоне).
- Подготовить инфраструктуру с помощью Terraform на базе облачного провайдера YandexCloud.
- Настроить внешний Reverse Proxy на основе Nginx и LetsEncrypt.
- Настроить кластер MySQL.
- Установить WordPress.
- Развернуть Gitlab CE и Gitlab Runner.
- Настроить CI/CD для автоматического развёртывания приложения.
- Настроить мониторинг инфраструктуры с помощью стека: Prometheus, Alert Manager и Grafana.

## Этапы выполнения:

 ## 1. Регистрация доменного имени  

Подойдет любое доменное имя на ваш выбор в любой доменной зоне.
ПРИМЕЧАНИЕ: Далее в качестве примера используется домен you.domain замените его вашим доменом.
Рекомендуемые регистраторы:

• nic.ru  
• reg.ru

### Цель:

Получить возможность выписывать TLS сертификаты для веб-сервера.  

### Ожидаемые результаты:

У вас есть доступ к личному кабинету на сайте регистратора.
Вы зарезистрировали домен и можете им управлять (редактировать dns записи в рамках этого домена).

![domen](https://github.com/homopoluza/devops-netology/blob/main/final/screenshots/1.png)

## 2. Создание инфраструктуры

Для начала необходимо подготовить инфраструктуру в YC при помощи Terraform.

Особенности выполнения:

Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Следует использовать последнюю стабильную версию Terraform.
Предварительная подготовка:

Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя.  

Подготовьте backend для Terraform:

- Рекомендуемый вариант: Terraform Cloud
- Альтернативный вариант: S3 bucket в созданном YC аккаунте.

```
  required_version = ">= 0.13"
    backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "final-bucket"
    region     = "ru-central1"
    key        = ".terraform/terraform.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    }

```
![bucket](https://github.com/homopoluza/devops-netology/blob/main/final/screenshots/2.png)

### Настройте workspaces

- Рекомендуемый вариант: создайте два workspace: stage и prod. В случае выбора этого варианта все последующие шаги должны учитывать факт существования нескольких workspace.

```
vagrant@vagrant:~/final/terraform$ terraform workspace list
  default
  prod
* stage
```

- Альтернативный вариант: используйте один workspace, назвав его stage. Пожалуйста, не используйте workspace, создаваемый Terraform-ом по-умолчанию (default).

### Создайте VPC с подсетями в разных зонах доступности.  

Убедитесь, что теперь вы можете выполнить команды terraform destroy и terraform apply без дополнительных ручных действий.
В случае использования Terraform Cloud в качестве backend убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

### Цель:

Повсеместно применять IaaC подход при организации (эксплуатации) инфраструктуры.
Иметь возможность быстро создавать (а также удалять) виртуальные машины и сети. С целью экономии денег на вашем аккаунте в YandexCloud.

### Ожидаемые результаты:

Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

![vpc-network](https://github.com/homopoluza/devops-netology/blob/main/final/screenshots/3.png)
![vpc-network](https://github.com/homopoluza/devops-netology/blob/main/final/screenshots/4.png)

## 3. Установка Nginx и LetsEncrypt

Необходимо разработать [Ansible роль](https://github.com/homopoluza/devops-netology/tree/main/final/ansible/roles/rev_proxy) для установки Nginx и LetsEncrypt.
Для получения LetsEncrypt сертификатов во время тестов своего кода пользуйтесь тестовыми сертификатами, так как количество запросов к боевым серверам LetsEncrypt лимитировано.

### Рекомендации:

• Имя сервера: you.domain
• Характеристики: 2vCPU, 2 RAM, External address (Public) и Internal address.

### Цель:

Создать reverse proxy с поддержкой TLS для обеспечения безопасного доступа к веб-сервисам по HTTPS.
Ожидаемые результаты:

В вашей доменной зоне настроены все A-записи на внешний адрес этого сервера:

https://www.you.domain (WordPress)  
https://gitlab.you.domain (Gitlab)  
https://grafana.you.domain (Grafana)  
https://prometheus.you.domain (Prometheus)  
https://alertmanager.you.domain (Alert Manager)  

Настроены все upstream для выше указанных URL, куда они сейчас ведут на этом шаге не важно, позже вы их отредактируете и укажите верные значения.
В браузере можно открыть любой из этих URL и увидеть ответ сервера (502 Bad Gateway). На текущем этапе выполнение задания это нормально!

![certs](https://github.com/homopoluza/devops-netology/blob/main/final/screenshots/5.png)


## 4. Установка кластера MySQL

Необходимо разработать [Ansible](https://github.com/homopoluza/devops-netology/tree/main/final/ansible/roles/mysql) роль для установки кластера MySQL.

### Рекомендации:

• Имена серверов: db01.you.domain и db02.you.domain
• Характеристики: 4vCPU, 4 RAM, Internal address.

### Цель:

Получить отказоустойчивый кластер баз данных MySQL.


### Ожидаемые результаты:

MySQL работает в режиме репликации Master/Slave.

```
mysql> show slave status\G;
*************************** 1. row ***************************
               Slave_IO_State: Waiting for source to send event
                  Master_Host: db01.homopoluza.ru
                  Master_User: replicator_user
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000001
          Read_Master_Log_Pos: 15312
               Relay_Log_File: relay-bin.000004
                Relay_Log_Pos: 4247
        Relay_Master_Log_File: mysql-bin.000001
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
```            

В кластере автоматически создаётся база данных c именем wordpress.

```
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| wordpress          |
+--------------------+
```

В кластере автоматически создаётся пользователь wordpress с полными правами на базу wordpress и паролем wordpress.  

```
mysql> SHOW GRANTS FOR wordpress;
+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Grants for wordpress@%                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, SHUTDOWN, PROCESS, FILE, REFERENCES, INDEX, ALTER, SHOW DATABASES, SUPER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, REPLICATION SLAVE, REPLICATION CLIENT, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EVENT, TRIGGER, CREATE TABLESPACE, CREATE ROLE, DROP ROLE ON *.* TO `wordpress`@`%`                                                                                                                                                                                                                                                                                                                                                                 |
| GRANT APPLICATION_PASSWORD_ADMIN,AUDIT_ABORT_EXEMPT,AUDIT_ADMIN,AUTHENTICATION_POLICY_ADMIN,BACKUP_ADMIN,BINLOG_ADMIN,BINLOG_ENCRYPTION_ADMIN,CLONE_ADMIN,CONNECTION_ADMIN,ENCRYPTION_KEY_ADMIN,FIREWALL_EXEMPT,FLUSH_OPTIMIZER_COSTS,FLUSH_STATUS,FLUSH_TABLES,FLUSH_USER_RESOURCES,GROUP_REPLICATION_ADMIN,GROUP_REPLICATION_STREAM,INNODB_REDO_LOG_ARCHIVE,INNODB_REDO_LOG_ENABLE,PASSWORDLESS_USER_ADMIN,PERSIST_RO_VARIABLES_ADMIN,REPLICATION_APPLIER,REPLICATION_SLAVE_ADMIN,RESOURCE_GROUP_ADMIN,RESOURCE_GROUP_USER,ROLE_ADMIN,SENSITIVE_VARIABLES_OBSERVER,SERVICE_CONNECTION_ADMIN,SESSION_VARIABLES_ADMIN,SET_USER_ID,SHOW_ROUTINE,SYSTEM_USER,SYSTEM_VARIABLES_ADMIN,TABLE_ENCRYPTION_ADMIN,XA_RECOVER_ADMIN ON *.* TO `wordpress`@`%` |
+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
2 rows in set (0.00 sec)
```

Вы должны понимать, что в рамках обучения это допустимые значения, но в боевой среде использование подобных значений не приемлимо! Считается хорошей практикой использовать логины и пароли повышенного уровня сложности. В которых будут содержаться буквы верхнего и нижнего регистров, цифры, а также специальные символы!

## 5. Установка WordPress

Необходимо разработать [Ansible роль](https://github.com/homopoluza/devops-netology/tree/main/final/ansible/roles/wordpress) для установки WordPress.

### Рекомендации:

• Имя сервера: app.you.domain  
• Характеристики: 4vCPU, 4 RAM, Internal address.

### Цель:

Установить WordPress. Это система управления содержимым сайта (CMS) с открытым исходным кодом.
По данным W3techs, WordPress используют 64,7% всех веб-сайтов, которые сделаны на CMS. Это 41,1% всех существующих в мире сайтов. Эту платформу для своих блогов используют The New York Times и Forbes. Такую популярность WordPress получил за удобство интерфейса и большие возможности.

### Ожидаемые результаты:

Виртуальная машина на которой установлен WordPress и Nginx/Apache (на ваше усмотрение).
В вашей доменной зоне настроена A-запись на внешний адрес reverse proxy:
https://www.you.domain (WordPress)
На сервере you.domain отредактирован upstream для выше указанного URL и он смотрит на виртуальную машину на которой установлен WordPress.
В браузере можно открыть URL https://www.you.domain и увидеть главную страницу WordPress.

![wordpress](https://github.com/homopoluza/devops-netology/blob/main/final/screenshots/8.png)

## 6. Установка Gitlab CE и Gitlab Runner

Необходимо настроить CI/CD систему для автоматического развертывания приложения при изменении кода.

[GitLab CE](https://github.com/homopoluza/devops-netology/tree/main/final/ansible/roles/gitlab-ce) и [GitLab Runner](https://github.com/homopoluza/devops-netology/tree/main/final/ansible/roles/gitlab-runner) роли


### Рекомендации:

• Имена серверов: gitlab.you.domain и runner.you.domain  
• Характеристики: 4vCPU, 4 RAM, Internal address.

### Цель:

Построить [pipeline](https://github.com/homopoluza/devops-netology/blob/main/final/.gitlab-ci.yml) доставки кода в среду эксплуатации, то есть настроить автоматический деплой на сервер app.you.domain при коммите в репозиторий с WordPress.
Подробнее о Gitlab CI

### Ожидаемый результат:

Интерфейс Gitlab доступен по https.
В вашей доменной зоне настроена A-запись на внешний адрес reverse proxy:
https://gitlab.you.domain (Gitlab)
На сервере you.domain отредактирован upstream для выше указанного URL и он смотрит на виртуальную машину на которой установлен Gitlab.
При любом коммите в репозиторий с WordPress и создании тега (например, v1.0.0) происходит деплой на виртуальную машину.

![gitlab](https://github.com/homopoluza/devops-netology/blob/main/final/screenshots/9.png)
![gitlab](https://github.com/homopoluza/devops-netology/blob/main/final/screenshots/10.png)
![gitlab](https://github.com/homopoluza/devops-netology/blob/main/final/screenshots/11.png)
![gitlab](https://github.com/homopoluza/devops-netology/blob/main/final/screenshots/12.png)

## 7. Установка Prometheus, Alert Manager, Node Exporter и Grafana

Необходимо разработать Ansible роль для установки [Prometheus](https://github.com/homopoluza/devops-netology/tree/main/final/ansible/roles/prometheus), [Alert Manager](https://github.com/homopoluza/devops-netology/tree/main/final/ansible/roles/alertmanager) и [Grafana](https://github.com/homopoluza/devops-netology/tree/main/final/ansible/roles/grafana).

### Рекомендации:

• Имя сервера: monitoring.you.domain  
• Характеристики: 4vCPU, 4 RAM, Internal address.

### Цель:

Получение метрик со всей инфраструктуры.

### Ожидаемые результаты:

Интерфейсы Prometheus, Alert Manager и Grafana доступены по https.
В вашей доменной зоне настроены A-записи на внешний адрес reverse proxy:

• https://grafana.you.domain (Grafana)  
• https://prometheus.you.domain (Prometheus)  
• https://alertmanager.you.domain (Alert Manager)  

На сервере you.domain отредактированы upstreams для выше указанных URL и они смотрят на виртуальную машину на которой установлены Prometheus, Alert Manager и Grafana.
На всех серверах установлен Node Exporter и его метрики доступны Prometheus.
![Prometheus](https://github.com/homopoluza/devops-netology/blob/main/final/screenshots/Screenshot%202022-07-30%20020230.png)
У Alert Manager есть необходимый набор правил для создания алертов.
![Alert Manager](https://github.com/homopoluza/devops-netology/blob/main/final/screenshots/Screenshot%202022-07-30%20025503.png)
В Grafana есть дашборд отображающий метрики из Node Exporter по всем серверам.
![Grafana](https://github.com/homopoluza/devops-netology/blob/main/final/screenshots/Screenshot%202022-07-30%20025124.png)
В Grafana есть дашборд отображающий метрики из MySQL (*).
В Grafana есть дашборд отображающий метрики из WordPress (*).
Примечание: дашборды со звёздочкой являются опциональными заданиями повышенной сложности их выполнение желательно, но не обязательно.

## Что необходимо для сдачи задания?

Репозиторий со всеми Terraform манифестами и готовность продемонстрировать создание всех ресурсов с нуля.
Репозиторий со всеми Ansible ролями и готовность продемонстрировать установку всех сервисов с нуля.
Скриншоты веб-интерфейсов всех сервисов работающих по HTTPS на вашем доменном имени.

https://www.you.domain (WordPress)  
https://gitlab.you.domain (Gitlab)  
https://grafana.you.domain (Grafana)  
https://prometheus.you.domain (Prometheus)  
https://alertmanager.you.domain (Alert Manager)  
Все репозитории рекомендуется хранить на одном из ресурсов (github.com или gitlab.com).

```
https://github.com/homopoluza/devops-netology/tree/main/final
```
