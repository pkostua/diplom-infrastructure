# GitHub Workflow для Terraform

Этот workflow автоматически применяет Terraform конфигурацию при коммите в ветки `main` или `master`.

## Настройка секретов

Перед использованием workflow необходимо настроить следующие секреты в репозитории:

### 1. Перейдите в настройки репозитория
- Откройте репозиторий на GitHub
- Перейдите в `Settings` → `Secrets and variables` → `Actions`

### 2. Добавьте следующие секреты:

| Секрет | Описание | Значение из personal.auto.tfvars |
|--------|----------|----------------------------------|
| `YC_CLOUD_ID` | ID облака Yandex Cloud | `b1gmfhaiiuot74gqhebq` |
| `YC_FOLDER_ID` | ID папки в облаке | `b1gikdb72g92f87k94t9` |
| `YC_SA_KEY` | JSON ключ сервисного аккаунта | Содержимое файла `sa-key.json` |
| `SSH_PUBLIC_KEY` | Содержимое публичного SSH ключа | Содержимое файла `id_rsa.pub` (например: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC...) |

### 3. Как добавить секрет:

1. Нажмите `New repository secret`
2. В поле `Name` введите название секрета (например, `YC_CLOUD_ID`)
3. В поле `Value` введите значение
4. Нажмите `Add secret`

## Как это работает

### При Pull Request:
- Выполняется `terraform plan`
- Результат добавляется как комментарий к PR
- **Инфраструктура НЕ применяется**

### При коммите в main/master:
- Выполняется `terraform plan`
- Выполняется `terraform apply` с флагом `-auto-approve`
- Инфраструктура применяется автоматически

## Безопасность

- Все чувствительные данные хранятся в секретах GitHub
- Workflow выполняется только при коммите в защищенные ветки
- Terraform apply выполняется только после успешного plan

## Требования

- Terraform 1.5.0+
- Python 3.11+
- Yandex Cloud CLI
- Доступ к Yandex Cloud через сервисный аккаунт
