# 🛒 Lojinha (Flutter + Django)

> **Projeto de estudo:** Exploração da integração entre um frontend mobile moderno e um backend robusto via API REST.

Este projeto foi desenvolvido com fins exclusivamente didáticos. O objetivo principal foi implementar a comunicação entre **Flutter** e **Django (Python)**, utilizando o **Django Rest Framework (DRF)** para a criação e consumo de APIs.

---

## 🚀 Tecnologias Utilizadas

### **Backend**
* **Django:** Framework web de alto nível em Python.
* **Django Rest Framework (DRF):** Toolkit para construção de Web APIs.
* **SQLite:** Banco de dados relacional leve para desenvolvimento.
* **CORS Headers:** Permite a comunicação entre o app Flutter e o backend.

### **Frontend**
* **Flutter:** Framework da Google para criação de apps nativos.
* **Dart:** Linguagem de programação do ecossistema Flutter.

---

## 🏗️ Modelagem do Sistema
O backend foi estruturado com as seguintes entidades principais:
* **Fabricante:** Cadastro de fornecedores.
* **Produto:** Itens com valor de custo, venda e validade.
* **Venda & ItemVenda:** Registro de transações vinculadas ao perfil do usuário.

---

## 🛠️ Como Executar o Projeto

### **Pré-requisitos**
* Python 3.x
* Flutter SDK configurado
* Git

### **1. Configuração do Backend (Django)**

Entre na pasta do servidor:
```bash
cd apiflutterlojinha
```
Instale as dependências necessárias:
```bash
pip install django djangorestframework django-cors-headers python-dotenv
```

Configuração do Ambiente (.env):
Crie um arquivo .env na raiz de apiflutterlojinha/ com o seguinte conteúdo:
```bash
SECRET_KEY=sua_chave_secreta_aqui
DEBUG=True
```

Prepare o banco de dados e inicie o serviço:
```bash
python manage.py migrate
```
Criar um Superusuário (Obrigatório para o primeiro login):

```bash
python manage.py createsuperuser
```
Siga as instruções no terminal para definir o nome de utilizador, e-mail e palavra-passe. Este utilizador será usado para realizar o primeiro acesso ao aplicativo Flutter.

Inicie o servidor:
```bash
python manage.py runserver
```
O servidor rodará em: http://127.0.0.1:8000

### **2. Configuração do Frontend (Flutter)**
Em um novo terminal, acesse a pasta do app:
```bash
cd lojinha
```

Instale as dependências do Flutter:
```bash
flutter pub get
```
💡 Dica para Emulador Android: > Se for testar em um emulador Android, a URL 127.0.0.1 não funcionará. Altere a baseUrl no arquivo lib/services/api_service.dart para http://10.0.2.2:8000/api.

Rode o aplicativo:
```bash
flutter run
```
