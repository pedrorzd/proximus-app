# Proximus - Avaliador de Localidade 📍

Proximus é um aplicativo MVP (Produto Mínimo Viável) desenvolvido em Flutter, projetado para avaliar a qualidade de uma localidade com base na sua proximidade a serviços essenciais.

O usuário insere um endereço, e o app calcula uma "Nota de Localidade" de 0 a 10, mostrando em um mapa e em uma lista quais serviços (como supermercados, farmácias, escolas, etc.) estão por perto e a que distância se encontram.

## 🚀 Funcionalidades Principais

* 🗺️ **Busca de Endereço:** Converte qualquer endereço em coordenadas (Geocoding) e centraliza o mapa no local.
* ⭐ **Nota de Localidade:** Calcula uma pontuação de 0 a 10 com base na proximidade (até 1km) de serviços essenciais.
* ⚡ **Destaques da Localidade:** Mostra "selos" de destaque (ex: "✔️ Perto de Supermercado") que justificam a nota.
* 📍 **Pins no Mapa:** Mostra marcadores para o endereço buscado (vermelho) e para os serviços encontrados (laranja).
* 🔍 **Filtros Interativos:** Permite ao usuário selecionar/desselecionar categorias (supermercado, farmácia, etc.) e refaz a busca automaticamente, atualizando o mapa e a nota.
* 📊 **Resultados Detalhados:** Apresenta os resultados em uma gaveta interativa (arrastável) com cards estilizados, mostrando o nome, tipo, ícone e distância de cada serviço.
* 🚀 **Busca Otimizada:** Utiliza chamadas de API paralelas (`Future.wait`) para buscar todos os serviços simultaneamente, tornando a resposta quase instantânea.

## 🛠️ Tecnologias Utilizadas

* **Flutter (Dart)** - Framework principal para o desenvolvimento
* **Google Maps Platform**
   * **Geocoding API:** Para converter endereços em coordenadas.
   * **Places API:** Para encontrar locais próximos (Nearby Search).
   * **Maps SDK:** Para exibir o mapa.
* **Pacotes Flutter:**
   * `Maps_flutter`: O widget do Google Maps.
   * `http`: Para fazer as chamadas de API.
   * `geolocator`: Para calcular a distância em linha reta entre dois pontos.

## ⚙️ Configuração e Instalação

Para rodar este projeto localmente, você precisará de uma chave de API do Google Cloud. O projeto está configurado para usar a mesma chave em três locais diferentes.

### 1. Pré-requisitos

* Ter o [SDK do Flutter](https://flutter.dev/docs/get-started/install) instalado.
* Um celular ou emulador Android configurado.
* Um projeto no [Google Cloud Console](https://console.cloud.google.com/).

### 2. Configuração das APIs do Google

1.  No seu projeto do Google Cloud, vá até a **Biblioteca** de APIs.
2.  Ative as seguintes APIs:
   * **Geocoding API**
   * **Places API**
   * **Maps SDK for Android**
   * **(Opcional para Web)** Maps JavaScript API
3.  Vá em **"Credenciais"**, crie uma **"Chave de API"** e copie-a.
4.  (Recomendado) Restrinja sua chave para permitir apenas as APIs que você ativou.

### 3. Configuração do Projeto

1.  **Clone o repositório:**
    ```bash
    git clone [https://github.com/pedrorzd/proximus-app.git](https://github.com/pedrorzd/proximus-app.git)
    cd proximus-app
    ```

2.  **Crie o arquivo de Chave (Dart):**
   * Na pasta `lib/`, crie um arquivo chamado `api_keys.dart`.
   * Adicione o seguinte conteúdo a ele, substituindo pela sua chave:
       ```dart
       // lib/api_keys.dart
       const String googleApiKey = 'SUA_CHAVE_DE_API_AQUI';
       ```

3.  **Configure o Android:**
   * Abra o arquivo `android/app/src/main/AndroidManifest.xml`.
   * Encontre a seção `<application>` e cole sua chave onde indicado:
       ```xml
       <application ...>
           ...
           <meta-data android:name="com.google.android.geo.API_KEY"
                      android:value="SUA_CHAVE_DE_API_AQUI"/>
       </application>
       ```
   * Certifique-se de que as permissões de localização (que já estão no arquivo) permaneçam lá.

4.  **(Opcional) Configure a Web:**
   * Abra o arquivo `web/index.html`.
   * Adicione sua chave no script do Google Maps, dentro da tag `<head>`:
       ```html
       <script src="[https://maps.googleapis.com/maps/api/js?key=SUA_CHAVE_DE_API_AQUI&callback=initMap](https://maps.googleapis.com/maps/api/js?key=SUA_CHAVE_DE_API_AQUI&callback=initMap)" async></script>
       ```

### 4. Instale as Dependências e Rode

1.  **Instale os pacotes:**
    ```bash
    flutter pub get
    ```

2.  **Execute o aplicativo:**
    ```bash
    flutter run
    ```

---