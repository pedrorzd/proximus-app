# 🗺️ Proximus: Avaliação Inteligente de Localidade (MVP Acadêmico)

O **Proximus** é um projeto de **MVP (Produto Mínimo Viável)** com foco acadêmico e desenvolvimento de **baixo custo**.
O objetivo principal é fornecer aos usuários uma ferramenta que permita analisar e pontuar a qualidade de uma determinada localidade com base na proximidade de serviços essenciais como supermercados, escolas e hospitais.

A arquitetura do projeto é baseada em **Flutter** para o desenvolvimento móvel e utiliza a **Google Maps Platform** para dados geográficos e de locais.

---

## ✨ Funcionalidades do MVP

O **Proximus** visa entregar as seguintes funcionalidades básicas:

* **Busca de Endereço**: Recebe um endereço textual do usuário.
* **Geocodificação**: Converte o endereço em coordenadas geográficas (lat/lng) usando a Google Geocoding API.
* **Visualização de Mapa**: Exibe um mapa interativo com a localização central marcada.
* **Busca de Locais Próximos**: Utiliza a Google Places API para encontrar estabelecimentos em categorias essenciais (Supermercados, Padarias, Escolas, Hospitais/Farmácias).
* **Cálculo de Distância**: Determina a distância e tempo de percurso entre o endereço central e os estabelecimentos encontrados (Distance Matrix API).
* **Filtros e Visualização**: Permite filtrar os locais por categoria e exibe-os com ícones e cores distintas no mapa e em uma lista.
* **Nota de Localidade**: Define e exibe uma pontuação (0–10) baseada na proximidade e diversidade dos serviços essenciais.

---

## 🛠️ Stack Tecnológico

| Categoria           | Tecnologia            | Uso no Projeto                                                          |
| ------------------- | --------------------- | ----------------------------------------------------------------------- |
| **Desenvolvimento** | Flutter (Dart)        | Framework para o desenvolvimento do aplicativo móvel.                   |
| **Design**          | Figma (Free)          | Criação de mockups e prototipagem das telas.                            |
| **Backend/Cloud**   | Firebase (Spark Plan) | Autenticação (inicial/opcional) e potencial para banco de dados futuro. |
| **Geolocalização**  | Google Maps Platform  | Maps SDK, Geocoding API, Places API, Distance Matrix API.               |
| **Versionamento**   | GitHub                | Controle de versão e hospedagem do código.                              |

---

## ⚙️ Setup e Pré-requisitos

Para rodar o projeto localmente, você precisará configurar:

1. **Ambiente Flutter**:

   * Instalar e configurar o Flutter SDK.
   * Instalar o Android Studio ou outra IDE compatível.

2. **Repositório**:

   * Clonar este repositório do GitHub.

3. **Google Cloud Project**:

   * Criar um novo projeto.

   * Ativar as APIs: *Maps SDK for Android/iOS*, *Geocoding API*, *Places API* e *Distance Matrix API*.

   * Obter a **API Key** (chave essencial para o Flutter).

   > 💡 Nota: utilizar os **créditos gratuitos ($200 USD)** para cobrir o uso das APIs.

4. **Firebase Project**:

   * Configuração básica de um projeto no plano gratuito *Spark*.

5. **Configuração da API Key no Flutter**:

   * A **Google API Key** deve ser armazenada com segurança no projeto.
   * Geralmente em arquivos de configuração específicos da plataforma (ex.: `AndroidManifest.xml` no Android).

---

## 🎓 Observação Acadêmica

Este projeto é desenvolvido com a premissa de **Custo Zero**, utilizando exclusivamente os **free tiers** de todos os serviços:

* Firebase Spark
* Créditos iniciais do Google Cloud
* Ferramentas gratuitas como Figma e GitHub

📌 A entrega final será o **APK funcionando em um dispositivo**, não sendo necessária a publicação nas lojas de aplicativos (*Play Store* / *App Store*).
