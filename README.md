# 🚀 Reusable Worflows — Quality, Auto Pull Request & Semantic Release

Conjunto de GitHub Reusable Workflows para padronizar CI, cobertura, promoção de código e releases automatizados, com suporte a múltiplas stacks.

> **Filosofia**: \
Automação sem disciplina cria caos. Disciplina sem automação não escala.

---

## Por que isso existe

A maioria dos repositórios começa simples e gradualmente acumula complexidade operacional:

- Pipelines de CI inconsistentes
- Releases manuais
- Versionamento não confiável
- Regras de promoção de branches pouco claras
- Verificações de qualidade aplicadas tardiamente

Grandes empresas resolvem isso com equipes de engenharia de plataforma.

Equipes pequenas e desenvolvedores individuais geralmente não conseguem.

Este projeto codifica um modelo mínimo de engenharia de plataforma em fluxos de trabalho reutilizáveis para que cada repositório possa começar com práticas de engenharia previsíveis desde o primeiro dia.

---

## O que este projeto é

Uma plataforma de fluxo de trabalho reutilizável que fornece:

- Releases determinísticos
- Controles de qualidade rigorosos
- Estratégia de promoção consistente
- Governança de commits convencional
- Execução agnóstica à stack de tecnologias

Você adiciona fluxos de trabalho.

Você herda a disciplina de engenharia.

---

## O que este projeto NÃO é

- um kit de ferramentas de CI genérico
- um repositório de modelos
- um framework DevOps completo
- pipelines infinitamente configuráveis

O projeto é intencionalmente opinativo.

Os valores padrão fazem parte do seu valor.

--- 

## 🎯 Objetivos

- Reduzir boilerplate em pipelines
- Padronizar versionamento com `semantic-release`
- Garantir qualidade mínima com **STRICT MODE**
- Permitir evolução por stack sem acoplamento
- Entregar informações claras nos sumários do Pipeline

---

## 📦 Workflows disponíveis

Todas os workflows reutilizáveis podem ser usadas em qualquer repositório, eles estão disponíveis no repositório [heliomarpm/reusable-workflows](https://github.com/heliomarpm/reusable-workflows).


> **Observação**: \
Este workflow utiliza o [GitHub Actions Reusable Workflow](https://docs.github.com/en/actions/using-reusable-workflows) para reutilizar o processo de CI/CD.


### 1️⃣ CI — Quality Assurance

Este workflow executa os testes e gera a cobertura de testes.

```yaml
name: 1. Quality Assurance
jobs:
  ci:
    uses: heliomarpm/reusable-workflows/.github/workflows/ci-quality.yml@v1
    secrets:
      GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Inputs principais**

| Input                       | Descrição
| ----                        | ----
| `stack`                     | `node` / `php`* / `dotnet`* / `python`* / `go`*
| `project_path`              | Caminho do código fonte (padrão: `.`) 
| `project_private`           | Para repo privado. `GH_TOKEN` será requerido 
| `coverage_base_branch`      | Base branch para cobertura comparativa (`decrease` mode) 
| `coverage_strategy`         | Não falha pipeline em erro de teste 
| `coverage_command`          | Comando para calcular cobertura 
| `coverage_mode`             | `info` / `block` / `decrease` (padrão: `info`)
| `coverage_min`              | Percentual mínimo de cobertura (padrão: `80`)
| `coverage_continue_on_failure` | Continua pipeline se os testes falharem

> `*` Em desenvolvimento

**Estratécias de Cobertura (`coverage_mode`)**

| Estratégia  | Comportamento            
| ----        | ----
| `info`      | Apenas informativo, continua mesmo se abaixo do percentual mínimo de cobertura
| `block`     | Falha pipeline se abaixo do percentual mínimo de cobertura
| `decrease`  | Falha pipeline se abaixo do percentual mínimo de cobertura em relação ao branch base (`coverage_base_branch`)

---

### 2️⃣ CD - Pull Request

Este workflow cria um Pull Request para a promoção automática de um branch para outra.

<!-- > **Padrão de promoção**: `trunk`.  -->

```yaml
name: Auto PR
jobs:
  auto-pr:
    uses: heliomarpm/reusable-workflows/.github/workflows/cd-pull-request.yml@v1
    secrets:
      GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

```

**Inputs principais**

| Input                         | Descrição
| ----                          | ----
| `main_branch`                 | Nome da branch principal
| `develop_branch`              | Nome da branch de desenvolvimento 

<!--
| `prefix_release_branch`       | Prefixo da branch de release (padrão: `release-`)
| `promotion_strategy`          | Estratégia de promoção (`trunk` / `develop` / `gitflow`)
| `strict_conventional_commits` | Ativa o modo strict (utilizado se promotion_strategy = release-branch)

**Estratégias de promoção (`promotion_strategy`)**

| Estratégia  | Comportamento            
| ---         | ---
| `trunk`     | `feature**` → `main`
| `develop`   | `feature**` → `develop` → `main`
| `gitflow`   | `feature**` → `develop` → `release-x.y.z` → `main`
-->

--- 
### 3️⃣ CD - Semantic Release

Este workflow executa o `semantic-release` para gerar novas versões, criando `tags` e `releases` do GitHub. Também cria/atualiza `changelog` e versionamento no `package.json`, `composer.json`.

```yaml
name: Release
jobs:
  release:
    uses: heliomarpm/reusable-workflows/.github/workflows/cd-semantic-release.yml@v1
    secrets:
      GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Inputs principais**

| Inputs                        | Descrição
| ----                          | ----
| `stack`                       | `node` / `php`* / `dotnet`* / `python`* / `go`*
| `project_path`                | Caminho do código fonte (padrão: `.`)
| `dry_run`                     | Ativa o modo dry-run para testes (padrão: false)
| `strict_conventional_commits` | Ativa o modo strict (utilizado se promotion_strategy = release-branch)   

<!--| `versioning_mode`             | Estrategia de versionamento (managed-version / self-versioned(padrão)) -->

> `*` Em desenvolvimento
<!--
**Estratégias de versionamento (`versioning_mode`)**

| Modo              | O que acontece           | Branch protegida funciona | Indicado para                                   |
| ----------------- | ------------------------------ | ------------------------- | ----------------------------------------------- |
| `managed-version` | cria tag e release  | ✅ Sim                     | aplicações, monorepos, repos com PR obrigatório |
| `self-versioned`  | cria tag/release, altera changelog, versiona package.json/composer.json   | ❌ Não                     | libs simples, repos pessoais                    |
-->
---

### 🔒 STRICT MODE — Commits Convencionais

Opção disponível para os fluxo `pull-request`* e `release`, e quando ativado, bloqueia o PR e/ou Release se existir commits que não obedecem as convencionais. 

```yaml
with:
  strict_conventional_commits: true
```

**O que acontece?**

- ❌ PR ou Release bloqueado
- 📌 Annotation visível no Job
- 📄 Instruções detalhadas no Summary

Isso evita:

- Releases silenciosos
- Versionamento incorreto
- Ambiguidade no histórico

---

## 🧱 Stacks suportadas

- ✅ Node.js
- 🚧 PHP
- 🚧 .NET
- 🚧 Python
- 🚧 Go

--- 

## 📈 Versionamento Semântico

Este modelo usa o [semantic-release](https://semantic-release.gitbook.io/) para gerenciamento automático de versões e publicação de pacotes. Os números de versão são determinados automaticamente com base nas mensagens de commit:

`<tipo>(<scope>): <mensagem curta>`

**Examplos**

| Mensagem de Commit | Tipo de Release | Exemplo de Versão |
| :--------------------------- | :----------- | --------------: |
| `perf(scope): message` | Patch | 1.0.1 |
| `revert(scope): message` | Patch | 1.0.1 |
| `fix(scope): message` | Patch | 1.0.1 |
| `feat(scope): message` | Minor | 1.1.0 |
| `feat!: remove login endpoint` | Major | 2.0.0 |
| `refactor!(scope): message` | Major | 2.0.0 |
| `BREAKING CHANGE: message` | Major | 2.0.0 |

### 📝 Formato da Mensagem de Commit

```text
<tipo>(<escopo>): <resumo curto>
│       │             │
│       │             └─⫸ Resumo no presente do indicativo. Sem maiúsculas. Sem ponto final.
│       │
│       └─⫸ Escopo do Commit: core|docs|config|cli|etc.
│
└─⫸ Tipo de Commit: fix|feat|build|chore|ci|docs|style|refactor|perf|test
```

Quando um commit é enviado para a branch `main`:

1. O semantic-release analisa as mensagens de commit
2. Determina o próximo número de versão
3. Gera o changelog
4. Cria uma tag git
5. Publica a versão no GitHub

> **Nota**: Para disparar uma versão, os commits devem seguir a especificação [Conventional Commits](https://www.conventionalcommits.org/).

---

## 🤝 Contribuições

Pull Requests são bem-vindos. \
Sugestões de stack, melhorias de DX e exemplos reais são prioridade.

Por favor, leia:

- [Código de Conduta](docs/CODE_OF_CONDUCT.md)
- [Guia de Contribuição](docs/CONTRIBUTING.md)

Agradecemos a todos que já contribuíram para o projeto!

<a href="https://github.com/heliomarpm/reusable-workflows/graphs/contributors" target="_blank">

<!-- <img src="https://contrib.rocks/image?repo=heliomarpm/tsapp-template" /> -->
<img src="https://contrib.nn.ci/api?repo=heliomarpm/reusable-workflows&no_bot=true" />
</a>

<!-- ###### Feito com [contrib.rocks](https://contrib.rocks). -->
###### Feito com [contrib.nn](https://contrib.nn.ci).

### ❤️ Apoie este projeto

Se este projeto lhe foi útil de alguma forma, existem várias maneiras de contribuir. \
Ajude-nos a manter e melhorar este modelo:

⭐ Adicione o repositório aos seus favoritos \
🐞 Reporte erros \
💡 Sugira funcionalidades \
🧾 Melhore a documentação \
📢 Compartilhe com outras pessoas

💵 Apoie através do GitHub Sponsors, Ko-fi, PayPal ou Liberapay, você decide. 😉

<div class="badges">

[![PayPal][url-paypal-badge]][url-paypal]
[![Ko-fi][url-kofi-badge]][url-kofi]
[![Liberapay][url-liberapay-badge]][url-liberapay]
[![GitHub Sponsors][url-github-sponsors-badge]][url-github-sponsors]

</div>

## 📝 Licença

[MIT © Heliomar P. Marques](LICENSE) <a href="#top">🔝</a>


----
<!-- Sponsor badges -->
[url-github-sponsors-badge]: https://img.shields.io/badge/GitHub%20-Sponsor-1C1E26?style=for-the-badge&labelColor=1C1E26&color=db61a2
[url-github-sponsors]: https://github.com/sponsors/heliomarpm
[url-paypal-badge]: https://img.shields.io/badge/donate%20on-paypal-1C1E26?style=for-the-badge&labelColor=1C1E26&color=0475fe
[url-paypal]: https://bit.ly/paypal-sponsor-heliomarpm
[url-kofi-badge]: https://img.shields.io/badge/kofi-1C1E26?style=for-the-badge&labelColor=1C1E26&color=ff5f5f
[url-kofi]: https://ko-fi.com/heliomarpm
[url-liberapay-badge]: https://img.shields.io/badge/liberapay-1C1E26?style=for-the-badge&labelColor=1C1E26&color=f6c915
[url-liberapay]: https://liberapay.com/heliomarpm
