# ToDo Bem

Aplicativo de lista de tarefas (To-Do List) integrado a uma API Web, desenvolvido para a disciplina de Desenvolvimento para Dispositivos Móveis (BRADEMO) do IFSP Bragança Paulista.

## Sumário
- [Tema do Aplicativo](#tema-do-aplicativo)
- [Detalhamento do Tema](#detalhamento-do-tema)
- [Funcionalidades e Casos de Uso](#funcionalidades-e-casos-de-uso)
- [Estrutura Visual e Navegação](#estrutura-visual-e-navegação)
- [Back-End e Integração](#back-end-e-integração)
- [Recursos Nativos](#recursos-nativos)
- [Repositórios](#repositórios)
- [Execução do Projeto](#execução-do-projeto)
- [Credenciais de Teste](#credenciais-de-teste)
- [Autores](#autores)

---

## Tema do Aplicativo
**Nome:** ToDo Bem  
**Tipo de escolha:** Tema livre  
**Descrição:**  
"ToDo Bem" é um aplicativo de lista de tarefas simples e intuitivo, projetado para ajudar usuários a organizar suas atividades diárias, semanais e projetos pessoais ou profissionais, melhorando a produtividade e o gerenciamento do tempo.

---

## Detalhamento do Tema
- **Motivação:** Ajudar pessoas a se organizarem de forma simples e eficiente, sem excesso de funcionalidades complexas.
- **Público-alvo:** Estudantes, profissionais e qualquer pessoa que deseje organizar suas atividades.
- **Utilidade:** Cadastro rápido de tarefas, organização por categorias, visualização de status (pendente/concluída), acompanhamento de progresso e priorização de atividades.

**Entidades principais:**
- **Usuário:** Representa a pessoa que utiliza o sistema.
- **Tarefa:** Atividade ou pendência a ser realizada.
- **Categoria:** Agrupador temático para tarefas.

---

## Funcionalidades e Casos de Uso

### Requisitos Funcionais
- **RF01:** Cadastro de usuários (nome, e-mail, senha)
- **RF02:** Autenticação de usuários (login)
- **RF03:** CRUD de tarefas (título, descrição, data, categoria)
- **RF04:** CRUD de categorias (nome)
- **RF05:** Alteração de status da tarefa (concluída/pendente)
- **RF06:** Filtragem de tarefas por nome
- **RF07:** Filtragem de categorias por nome

### Casos de Uso
- **Login de Usuário**
- **Cadastro de Usuário**
- **Gerenciar Tarefas (CRUD)**
- **Gerenciar Categorias (CRUD)**
- **Marcar Tarefa como Concluída/Pendente**
- **Filtrar Tarefas por Nome**
- **Filtrar Categorias por Nome**

---

## Estrutura Visual e Navegação

### Telas do Aplicativo
- **Tela de Login:** E-mail, senha, botão "Entrar", link para cadastro.
- **Tela de Cadastro:** Nome, e-mail, senha, botão "Cadastrar".
- **Tela Principal:** Lista de tarefas, criar/editar/excluir tarefa, marcar como concluída, buscar por nome, filtrar por categoria.
- **Tela de Criar/Editar Tarefa:** Título, descrição, data, categoria.
- **Tela de Categorias:** Lista, criar/editar/excluir categoria, buscar por nome.

### Fluxo de Navegação
1. Tela de Login → Tela Principal
2. Tela de Login → Tela de Cadastro → Tela Principal
3. Tela Principal → Criar/Editar Tarefa
4. Tela Principal → Tela de Categorias

---

## Back-End e Integração
- **Linguagem:** Java 17
- **Framework:** Spring Boot 3.5
- **Banco de Dados:** PostgreSQL (Neon.tech)
- **ORM:** JPA/Hibernate
- **API REST:** Endpoints para usuários, tarefas, categorias e autenticação
- **Hospedagem:** Neon.tech

### Endpoints principais
| Entidade   | Método | Endpoint                       | Descrição                  |
|------------|--------|-------------------------------|----------------------------|
| Usuário    | POST   | /api/auth/register            | Cadastrar novo usuário     |
| Usuário    | POST   | /api/auth/login               | Login do usuário           |
| Tarefas    | GET    | /api/tasks?userId=            | Listar tarefas do usuário  |
| Tarefas    | POST   | /api/tasks                    | Criar nova tarefa          |
| Tarefas    | PUT    | /api/tasks/{id}               | Atualizar tarefa           |
| Tarefas    | DELETE | /api/tasks/{id}               | Deletar tarefa             |
| Tarefas    | PATCH  | /api/tasks/{id}/toggle        | Alterar status da tarefa   |
| Categorias | GET    | /api/categories?userId=       | Listar categorias do usuário|
| Categorias | POST   | /api/categories               | Criar categoria            |
| Categorias | PUT    | /api/categories/{id}          | Atualizar categoria        |
| Categorias | DELETE | /api/categories/{id}          | Deletar categoria          |

---

## Recursos Nativos
- **Câmera e Galeria:** Para foto de perfil do usuário.
- **Geolocalização (GPS):** Para associar localização à tarefa.
- **Notificações locais:** Lembretes de tarefas com agendamento no sistema operacional.

---

## Repositórios
- **Front-End (Flutter):**  
  [https://github.com/lybiomoraesjr/ifsp_bra_tads_brademo_bimonthly_project_02](https://github.com/lybiomoraesjr/ifsp_bra_tads_brademo_bimonthly_project_02)
- **Back-End (Spring Boot):**  
  [https://github.com/lybiomoraesjr/ifsp_bra_tads_bradwbk_bimonthly_project_02](https://github.com/lybiomoraesjr/ifsp_bra_tads_bradwbk_bimonthly_project_02)

---

## Execução do Projeto

### Pré-requisitos
- Flutter 3.x
- Java 17
- PostgreSQL
- Android Studio ou Xcode (para rodar emulador/simulador)

### Como rodar o app
1. Clone o repositório do front-end:
   ```sh
   git clone https://github.com/lybiomoraesjr/ifsp_bra_tads_brademo_bimonthly_project_02.git
   cd ifsp_bra_tads_brademo_bimonthly_project_02
   ```
2. Instale as dependências:
   ```sh
   flutter pub get
   ```
3. Configure o arquivo `.env` com a URL da API, se necessário.
4. Rode o app:
   ```sh
   flutter run
   ```

### Como rodar o back-end
1. Clone o repositório do back-end:
   ```sh
   git clone https://github.com/ArthurDeFaria/ifsp_bra_tads_bradwbk_bimonthly_project_02.git
   cd ifsp_bra_tads_bradwbk_bimonthly_project_02
   ```
2. Configure o arquivo `.env` ou `application.properties` com as credenciais do banco (solicite ao grupo ou professor).
3. Rode o projeto:
   ```sh
   ./mvnw spring-boot:run
   ```

---

## Credenciais de Teste

> **As credenciais do banco de dados e da API não são expostas publicamente neste repositório. Solicite ao grupo ou ao professor para obter os dados de acesso para testes acadêmicos.**

---

## Autores
- Arthur de Faria BP3038289
- Inácio Fernandes Santana BP3039307
- João Paulo Pereira Costa BP3039331
- Lybio Croton de Moraes Junior BP303934X
- Thales Miranda dos Santos BP3039668

---

**Instituto Federal de Educação, Ciência e Tecnologia de São Paulo - Campus Bragança Paulista**  
Disciplina: Desenvolvimento para Dispositivos Móveis (BRADEMO)  
Prof. Luiz Gustavo Diniz de Oliveira Véras
