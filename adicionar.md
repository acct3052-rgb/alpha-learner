API de Cotações
API de Cotações em tempo real com mais de 150 moedas!

Para evitar o cache e ter acesso aos dados em tempo real, cadastre-se no awesomeapi.com.br e tenha até 100.000 requisições gratuitas!

Para garantir acesso aos dados em tempo real sem interferência de cache, utilize sua API Key. Para mais informações sobre como obter e configurar sua API Key, visite as instruções de API Key.

Códigos das moedas:
Veja a lista completa de combinações em https://economia.awesomeapi.com.br/xml/available

Veja a lista de nomes das moedas https://economia.awesomeapi.com.br/xml/available/uniq

Outras conversões
Cotação Turismo
USD-BRLT (Dólar Americano para Real Brasileiro Turismo)

EUR-BRLT (Euro para Real Brasileiro Turismo)

Cotação PTAX (Dados do Banco Central)
A cotação PTAX é uma taxa de câmbio calculada pelo Banco Central do Brasil, que representa a média das taxas de compra e venda do dólar, apuradas ao longo do dia em que há operações de câmbio, ajustadas ao final desse período. Ela é comumente utilizada como referência para contratos financeiros e serve como base para a conversão de valores entre moedas, oferecendo um benchmark confiável para transações cambiais.

USD-BRLPTAX (Dólar Americano para Real Brasileiro)

EUR-BRLPTAX (Euro para Real Brasileiro)

Retorna moedas selecionadas (atualizado em tempo real*)
GET https://economia.awesomeapi.com.br/json/last/:moedas

Retorna a ultima ocorrência das moedas selecionadas.
Ex.: https://economia.awesomeapi.com.br/last/USD-BRL,EUR-BRL,BTC-BRL

*Solicitações não autenticadas com chave de API serão armazenadas em cache por 1 minuto.

Path Parameters
Name
Type
Description
moedas

string

Moedas selecionadas separado por vírgula (,) Ex.: USD-BRL,EUR-BRL,BTC-BRL

200
404 Moeda especificada não existe
Copy
{
    "USDBRL": {
        "code": "USD",
        "codein": "BRL",
        "name": "Dólar Americano/Real Brasileiro",
        "high": "5.734",
        "low": "5.7279",
        "varBid": "-0.0054",
        "pctChange": "-0.09",
        "bid": "5.7276",
        "ask": "5.7282",
        "timestamp": "1618315045",
        "create_date": "2021-04-13 08:57:27"
    },
    "EURBRL": {
        "code": "EUR",
        "codein": "BRL",
        "name": "Euro/Real Brasileiro",
        "high": "6.8327",
        "low": "6.8129",
        "varBid": "-0.0069",
        "pctChange": "-0.1",
        "bid": "6.8195",
        "ask": "6.822",
        "timestamp": "1618315093",
        "create_date": "2021-04-13 08:58:15"
    },
    "BTCBRL": {
        "code": "BTC",
        "codein": "BRL",
        "name": "Bitcoin/Real Brasileiro",
        "high": "360000",
        "low": "340500",
        "varBid": "17072.9",
        "pctChange": "4.98",
        "bid": "359973.9",
        "ask": "359974",
        "timestamp": "1618315092",
        "create_date": "2021-04-13 08:58:12"
    }
}
Retorna o fechamento dos últimos dias
GET https://economia.awesomeapi.com.br/json/daily/:moeda/:numero_dias

https://economia.awesomeapi.com.br/json/daily/USD-BRL/15

Path Parameters
Name
Type
Description
moeda

string

Código da moeda Ex: USD-BRL

numero_dias

number

Numero de dias a retornar. (Padrão 1. Máximo 360)

200
Copy
[
    {
        varBid: "-0.0143",
        code: "USD",
        codein: "BRL",
        name: "Dólar Americano/Real Brasileiro",
        high: "3.8906",
        low: "3.8596",
        pctChange: "-0.37",
        bid: "3.8659",
        ask: "3.8671",
        timestamp: "1555360543",
        create_date: "2019-04-15 17:35:43"
    },
    {
        varBid: "0.0006",
        high: "3.9076",
        low: "3.8571",
        pctChange: "0.02",
        bid: "3.8808",
        ask: "3.8829",
        timestamp: "1555275600"
    },
    {
        varBid: "0.0248",
        high: "3.9076",
        low: "3.8571",
        pctChange: "0.64",
        bid: "3.8813",
        ask: "3.8823",
        timestamp: "1555102794"
    },
    {
        varBid: "0.0237",
        high: "3.9076",
        low: "3.8571",
        pctChange: "0.62",
        bid: "3.8805",
        ask: "3.881",
        timestamp: "1555102774"
    },
    ...
]
Retorna o fechamento de um período específico
GET https://economia.awesomeapi.com.br/json/daily/:moeda/:numero_dias?start_date=20180901&end_date=20180930

https://economia.awesomeapi.com.br/json/daily/USD-BRL/?start_date=20180901&end_date=20180930

Path Parameters
Name
Type
Description
:moeda

string

Código da moeda Ex: USD-BRL

:numero_dias

number

Numero de dias a retornar. (Padrão 1. Máximo 360)

Query Parameters
Name
Type
Description
start_date

string

Data de inicio dos resultados no formato YYYYMMDD Ex: 20180901

end_date

string

Data limite dos resultados no formato YYYYMMDD Ex: 20180930

200
Copy
[
    {
        code: "USD",
        codein: "BRL",
        name: "Dólar Americano/Real Brasileiro",
        high: "4.0256",
        low: "4.0256",
        pctChange: "0.834",
        bid: "4.0256",
        ask: "4.0276",
        varBid: "0.0333",
        timestamp: "1538136540000",
        create_date: "2018-09-28 06:20:02"
    },
    {
        high: "4.0376",
        low: "4.0376",
        pctChange: "0.313",
        bid: "4.0376",
        ask: "4.0388",
        varBid: "0.0126",
        timestamp: "1538050140000"
    },
    {
        high: "4.0912",
        low: "4.0912",
        pctChange: "0.262",
        bid: "4.0912",
        ask: "4.0937",
        varBid: "0.0107",
        timestamp: "1537963800000"
    },
    {
        high: "4.1094",
        low: "4.1094",
        pctChange: "0.553",
        bid: "4.1094",
        ask: "4.1106",
        varBid: "0.0226",
        timestamp: "1537877400000"
    },
    {
        high: "4.0539",
        low: "4.0539",
        pctChange: "0.183",
        bid: "4.0539",
        ask: "4.0551",
        varBid: "0.0074",
        timestamp: "1537791000000"
    },
    ...
]
Retorna cotações sequenciais de uma única moeda (intervalo de 1 minuto)
GET https://economia.awesomeapi.com.br/:moeda/:quantidade

Retorna valores de uma moeda

*Limite para requisições não autenticadas 100.  Autenticadas 1500.

Path Parameters
Name
Type
Description
moeda

string

Código da moeda Ex.: USD-BRL

quantidade

number

Número de resultados para retornar. (Padrão 1. *Máximo 100/1500)

200
404
Copy
[
  {
    "code": "USD",
    "codein": "BRL",
    "name": "Dólar Americano/Real Brasileiro",
    "high": "3.6713",
    "low": "3.62",
    "pctChange": "-0.455",
    "bid": "3.6269",
    "ask": "3.6281",
    "varBid": "-0.0166",
    "timestamp": "1527103140000",
    "create_date": "2018-05-23 16:30:02"
  }
]
Retorna cotações sequenciais de um período específico (intervalo de 1 minuto)
GET https://economia.awesomeapi.com.br/:moeda/:quantidade?start_date=20200301&end_date=20200330

https://economia.awesomeapi.com.br/USD-BRL/10?start_date=20200201&end_date=20200229

*Limite para requisições não autenticadas 100.  Autenticadas 1500.

Path Parameters
Name
Type
Description
:moeda

string

Código da moeda ex.: USD-BRL

:quantidade

string

Número de resultados para retornar. (Padrão 1. *Máximo 100/1500)

Query Parameters
Name
Type
Description
start_date

string

Data de inicio dos resultados no formato YYYYMMDD ex.: 20200201

end_date

string

Data limite dos resultados no formato YYYYMMDD ex.: 20200229

200
Copy
[
    {
        code: "USD",
        codein: "BRL",
        name: "Dólar Americano/Real Brasileiro",
        high: "5.1945",
        low: "5.101",
        varBid: "0.0941",
        pctChange: "1.85",
        bid: "5.1931",
        ask: "5.1945",
        timestamp: "1585601928",
        create_date: "2020-03-30 17:58:48"
    },
    {
        high: "5.1945",
        low: "5.101",
        varBid: "0.0936",
        pctChange: "1.84",
        bid: "5.1926",
        ask: "5.194",
        timestamp: "1585601749"
    },
    {
        high: "5.1945",
        low: "5.101",
        varBid: "0.0933",
        pctChange: "1.83",
        bid: "5.1921",
        ask: "5.194",
        timestamp: "1585601560"
    },
    {
        high: "5.1945",
        low: "5.101",
        varBid: "0.0923",
        pctChange: "1.81",
        bid: "5.1905",
        ask: "5.1936",
        timestamp: "1585601379"
    },
    {
        high: "5.1945",
        low: "5.101",
        varBid: "0.0916",
        pctChange: "1.8",
        bid: "5.1906",
        ask: "5.192",
        timestamp: "1585601199"
    },
    ...
]
Formato de resposta
GET https://economia.awesomeapi.com.br/:format/:moeda

https://economia.awesomeapi.com.br/json/USD-BRL

Path Parameters
Name
Type
Description
format

string

JSON (default) e XML

moeda

string

Código da moeda a ser retornada

200 XML Response
Copy
<xml>
    <item>
        <varBid>-0.0119</varBid>
        <code>USD</code>
        <codein>BRL</codein>
        <name>Dólar Americano/Real Brasileiro</name>
        <high>3.8906</high>
        <low>3.8596</low>
        <pctChange>-0.31</pctChange>
        <bid>3.8685</bid>
        <ask>3.8692</ask>
        <timestamp>1555361148</timestamp>
        <create_date>2019-04-15 17:45:49</create_date>
    </item>
</xml>
Exemplos
Copy
http://economia.awesomeapi.com.br/json/last/USD-BRL
http://economia.awesomeapi.com.br/json/last/USD-BRL,EUR-BRL,BTC-BRL

http://economia.awesomeapi.com.br/xml/USD-BRL/1
http://economia.awesomeapi.com.br/USD-BRL/1?format=xml
Legendas
key

Label

bid

Compra

ask

Venda

varBid

Variação

pctChange

Porcentagem de Variação

high

Máximo

low

Mínimo

timestamp

Hora da negociação (UTC)

create_date

Hora da negociação (UTC-3)
