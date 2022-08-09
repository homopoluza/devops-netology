# Домашнее задание к занятию "08.03 Работа с Roles"

## Подготовка к выполнению
1. Создайте два пустых публичных репозитория в любом своём проекте: elastic-role и kibana-role.
2. Скачайте [role](./roles/) из репозитория с домашним заданием и перенесите его в свой репозиторий elastic-role.
3. Скачайте дистрибутив [java](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html) и положите его в директорию `playbook/files/`. 
4. Установите molecule: `pip3 install molecule`
5. Добавьте публичную часть своего ключа к своему профилю в github.

## Основная часть

Наша основная цель - разбить наш playbook на отдельные roles. Задача: сделать roles для elastic, kibana и написать playbook для использования этих ролей. Ожидаемый результат: существуют два ваших репозитория с roles и один репозиторий с playbook.

1. Создать в старой версии playbook файл `requirements.yml` и заполнить его следующим содержимым:
   ```yaml
   ---
     - src: git@github.com:netology-code/mnt-homeworks-ansible.git
       scm: git
       version: "1.0.1"
       name: java 
   ```
2. При помощи `ansible-galaxy` скачать себе эту роль. Запустите  `molecule test`, посмотрите на вывод команды.

```
vagrant@vagrant:/vagrant/8.3$ ansible-galaxy install -r requirements.yml --roles-path ./

Starting galaxy role install process
- extracting java to /vagrant/8.3/java
- java (1.0.1) was installed successfully
```

```
vagrant@vagrant:/vagrant/8.3/java$ molecule test
INFO     default scenario test matrix: dependency, lint, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy
INFO     Performing prerun with role_name_check=0...
INFO     Set ANSIBLE_LIBRARY=/home/vagrant/.cache/ansible-compat/38a096/modules:/home/vagrant/.ansible/plugins/modules:/usr/share/ansible/plugins/modules
INFO     Set ANSIBLE_COLLECTIONS_PATH=/home/vagrant/.cache/ansible-compat/38a096/collections:/home/vagrant/.ansible/collections:/usr/share/ansible/collections
INFO     Set ANSIBLE_ROLES_PATH=/home/vagrant/.cache/ansible-compat/38a096/roles:/home/vagrant/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles
ERROR    Computed fully qualified role name of java does not follow current galaxy requirements.
Please edit meta/main.yml and assure we can correctly determine full role name:

galaxy_info:
role_name: my_name  # if absent directory name hosting role is used instead
namespace: my_galaxy_namespace  # if absent, author is used instead

Namespace: https://galaxy.ansible.com/docs/contributing/namespaces.html#galaxy-namespace-limitations
Role: https://galaxy.ansible.com/docs/contributing/creating_role.html#role-names

As an alternative, you can add 'role-name' to either skip_list or warn_list.

Traceback (most recent call last):
  File "/home/vagrant/.local/bin/molecule", line 8, in <module>
    sys.exit(main())
  File "/home/vagrant/.local/lib/python3.8/site-packages/click/core.py", line 1130, in __call__
    return self.main(*args, **kwargs)
  File "/home/vagrant/.local/lib/python3.8/site-packages/click/core.py", line 1055, in main
    rv = self.invoke(ctx)
  File "/home/vagrant/.local/lib/python3.8/site-packages/click/core.py", line 1657, in invoke
    return _process_result(sub_ctx.command.invoke(sub_ctx))
  File "/home/vagrant/.local/lib/python3.8/site-packages/click/core.py", line 1404, in invoke
    return ctx.invoke(self.callback, **ctx.params)
  File "/home/vagrant/.local/lib/python3.8/site-packages/click/core.py", line 760, in invoke
    return __callback(*args, **kwargs)
  File "/home/vagrant/.local/lib/python3.8/site-packages/click/decorators.py", line 26, in new_func
    return f(get_current_context(), *args, **kwargs)
  File "/home/vagrant/.local/lib/python3.8/site-packages/molecule/command/test.py", line 176, in test
    base.execute_cmdline_scenarios(scenario_name, args, command_args, ansible_args)
  File "/home/vagrant/.local/lib/python3.8/site-packages/molecule/command/base.py", line 112, in execute_cmdline_scenarios
    scenario.config.runtime.prepare_environment(
  File "/home/vagrant/.local/lib/python3.8/site-packages/ansible_compat/runtime.py", line 346, in prepare_environment
    self._install_galaxy_role(
  File "/home/vagrant/.local/lib/python3.8/site-packages/ansible_compat/runtime.py", line 506, in _install_galaxy_role
    raise InvalidPrerequisiteError(msg)
ansible_compat.errors.InvalidPrerequisiteError: Computed fully qualified role name of java does not follow current galaxy requirements.
Please edit meta/main.yml and assure we can correctly determine full role name:

galaxy_info:
role_name: my_name  # if absent directory name hosting role is used instead
namespace: my_galaxy_namespace  # if absent, author is used instead

Namespace: https://galaxy.ansible.com/docs/contributing/namespaces.html#galaxy-namespace-limitations
Role: https://galaxy.ansible.com/docs/contributing/creating_role.html#role-names

As an alternative, you can add 'role-name' to either skip_list or warn_list.
```

3. Перейдите в каталог с ролью elastic-role и создайте сценарий тестирования по умолчаню при помощи `molecule init scenario --driver-name docker`.

```
vagrant@vagrant:/vagrant/elastic-role$ molecule init scenario --driver-name docker
INFO     Initializing new scenario default...
CRITICAL The directory molecule/default exists. Cannot create new scenario.
```

4. Добавьте несколько разных дистрибутивов (centos:8, ubuntu:latest) для инстансов и протестируйте роль, исправьте найденные ошибки, если они есть.

```
---
dependency:
  name: galaxy
driver:
  name: docker
platforms:
  - name: instance
    image: docker.io/pycontribs/centos:7
    pre_build_image: true
  - name: centos8
    image: docker.io/pycontribs/centos:8
    pre_build_image: true
  - name: ubuntu
    image: docker.io/pycontribs/ubuntu:latest
    pre_build_image: true
provisioner:
  name: ansible
verifier:
  name: ansible
```

5. Создайте новый каталог с ролью при помощи `molecule init role --driver-name docker kibana-role`. Можете использовать другой драйвер, который более удобен вам.

```
vagrant@vagrant:/vagrant$ molecule init role --driver-name docker kibana-role
CRITICAL Outside collections you must mention role namespace like: molecule init role 'acme.myrole'. Be sure you use only lowercase characters and underlines. See https://galaxy.ansible.com/docs/contributing/creating_role.html
vagrant@vagrant:/vagrant$ molecule init role --driver-name docker kibana.role
INFO     Initializing new role role...
usage: ansible-galaxy [-h] [--version] [-v] TYPE ...
ansible-galaxy: error: argument TYPE: invalid choice: 'init' (choose from 'collection', 'role')

usage: ansible-galaxy [-h] [--version] [-v] TYPE ...

Perform various Role and Collection related operations.

positional arguments:
  TYPE
    collection   Manage an Ansible Galaxy collection.
    role         Manage an Ansible Galaxy role.

optional arguments:
  --version      show program's version number, config file location,
                 configured module search path, module location, executable
                 location and exit
  -h, --help     show this help message and exit
  -v, --verbose  verbose mode (-vvv for more, -vvvv to enable connection
                 debugging)
WARNING  Retrying execution failure 2 of: ansible-galaxy init -v --offline role
CRITICAL Galaxy failed to create role, returned 2
```

6. На основе tasks из старого playbook заполните новую role. Разнесите переменные между `vars` и `default`. Проведите тестирование на разных дистрибитивах (centos:7, centos:8, ubuntu).

```
переменные в default/main.yml
```

7. Выложите все roles в репозитории. Проставьте тэги, используя семантическую нумерацию.

```
git tag 1.0.0
```
- 
8. Добавьте roles в `requirements.yml` в playbook.

```
---
  - src: git@github.com:homopoluza/elastic-role.git
    scm: git
    version: "1.0.0"
    name: elastic-role
  - src: git@github.com:homopoluza/kibana-role.git
    scm: git
    version: "1.0.0"
    name: kibana-role 
```

9. Переработайте playbook на использование roles.

```
---
- hosts: elasticsearch
  roles:
  - elastic-role
- hosts: kibana
  roles:
  - kibana-role
```
10. Выложите playbook в репозиторий.
11. В ответ приведите ссылки на оба репозитория с roles и одну ссылку на репозиторий с playbook.

- https://github.com/homopoluza/elastic-role
- https://github.com/homopoluza/kibana-role
- https://github.com/homopoluza/playbook