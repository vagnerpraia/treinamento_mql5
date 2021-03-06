//+------------------------------------------------------------------+
//|                                               TreinamentoEA1.mq5 |
//|                                                     Vagner Praia |
//|                          https://www.linkedin.com/in/vagnerpraia |
//+------------------------------------------------------------------+
#property copyright "Vagner Praia"
#property link      "https://www.linkedin.com/in/vagnerpraia"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Constants                                                        |
//+------------------------------------------------------------------+
#define VALOR_APLICACAO 1000

//+------------------------------------------------------------------+
//| Enums                                                            |
//+------------------------------------------------------------------+
enum ENUM_TIPO_OPERACAO
  {
   swingTrade = 0, // Swing Trade
   dayTrade = 1, // Day Trade
   scalper = 2, // Scalper
  };
  
enum ENUM_BASE
  {
   compradora,
   vendedora,
  };
  
enum ENUM_TIPO_PRINT
  {
   PRINT   = 0, // Print
   COMMENT = 1, // Comment
   ALERT   = 2, // Alert
  };
  
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input ENUM_TIPO_OPERACAO tipoOperacao; // Tipo de operação que deseja ser executada
input ENUM_TIPO_PRINT tipoPrint; // Tipo de print do EA
input int numeroPeriodos = 1; // Número de períodos utilizados na análise técnica automatizada

//+------------------------------------------------------------------+
//| Variáveis de indicadores                                         |
//+------------------------------------------------------------------+
int mmHandle;
double mmBuffer[];

int rsiHandle;
double rsiBuffer[];

int haBinaryHandle;
double haBinaryBuffer[];

//+------------------------------------------------------------------+
//| Candles                                                          |
//+------------------------------------------------------------------+
MqlRates candles[];

//--- Últimos preços
MqlTick tick;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
//--- Executa quando o EA é iniciado
int OnInit()
  {
//--- create timer
   EventSetTimer(2);
   
   //--- Captura os candles
   CopyRates(_Symbol, _Period, 0, 3, candles);
   
   //--- Ordenando os candles para obter os mais recentes
   ArraySetAsSeries(candles, true);
   
   SymbolInfoTick(_Symbol, tick);
   
   //--- Váriaveis predefinidas
   Print("Ativo: ", _Symbol);
   Print("Período: ", _Period);
   Print("Pontos: ", _Point);
   Print("Dígitos: ", _Digits);
   
   PrintMessage(tipoPrint);
   
   //--- Carregamento de indicadores
   mmHandle = iMA(_Symbol, _Period, 21, 0, MODE_EMA, PRICE_CLOSE);
   if(mmHandle < 0){
      Alert("Ocorreu um erro no carregamento do indicdor de média móvel exponencial: ", GetLastError());
      return(-1);
   }
   
   rsiHandle = iRSI(_Symbol, PERIOD_M1, 8, PRICE_CLOSE);
   if(rsiHandle < 0){
      Alert("Ocorreu um erro no carregamento do indicdor de RSI: ", GetLastError());
      return(-1);
   }
   
   haBinaryHandle = iCustom(_Symbol, PERIOD_M1, "Downloads\\Heiken Ashi Smoothed - binary", 5, 1, 0, false);
   if(haBinaryHandle < 0){
      Alert("Ocorreu um erro no carregamento do indicdor de Heikin Ashi Binário: ", GetLastError());
      return(-1);
   }
   
   //--- Adicionando indicadores no gráfico.
   ChartIndicatorAdd(0, 0, mmHandle);
   ChartIndicatorAdd(0, 1, rsiHandle);
   ChartIndicatorAdd(0, 2, haBinaryHandle);

   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
//--- Executa quando o EA é removido
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
//--- Executa a cada transação
void OnTick()
  {
   //--- Carrega os buffers de indicadores
   CopyBuffer(mmHandle, 0, 0, 3, mmBuffer);
   ArraySetAsSeries(mmBuffer, true);
   
   CopyBuffer(rsiHandle, 0, 0, 3, rsiBuffer);
   ArraySetAsSeries(rsiBuffer, true);
   
   CopyBuffer(haBinaryHandle, 0, 0, 3, haBinaryBuffer);
   ArraySetAsSeries(haBinaryBuffer, true);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
//--- Executa de tempos em tempos de acordo com o definido na chamada da função EventSetTimer
void OnTimer()
  {
//   for(int i = 0; i < 5; i++)
//   {
//      Print("Teste: ", i);
//      Sum(i, 10);
//   }
//   
//   Print("Preço candles: ", candles[0].close);
//   Print("Preço tick: ", tick.last);
//   Print("Volume tick: ", tick.volume);
//   Print("Média móvel: ", mmBuffer[0]);

      Print("HA: ", (string) haBinaryBuffer[0]);
  }

//--- Função personalizada que soma e imprime dois double
void Sum(double a, double b)
  {
   double sum = a + b;
   Print("Soma: ", sum);
  }

void PrintMessage(int tipo) {
   string symb_symbol    = "";  // Symbol
   int    symb_digits    = 0;   // Number of decimal places
   int    symb_spread    = 0;   // Difference between the ask price and bid price (spread)
   int    symb_stoplevel = 0;   // Stop levels
   double symb_ask       = 0.0; // Ask price
   double symb_bid       = 0.0; // Bid price
   double symb_last       = 0.0; // Last price
   
   symb_symbol    = Symbol();
   symb_digits    = (int) SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   symb_spread    = (int) SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   symb_stoplevel = (int) SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   symb_ask       = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   symb_bid       = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   symb_last      = SymbolInfoDouble("BBAS3", SYMBOL_LAST);
   
   if(tipo == PRINT) {
      //--- Adiciona comentário no log do EA
      Print("Symbol: ", symb_symbol, "\n",
               "Digits: ", symb_digits, "\n",
               "Spread: ", symb_spread, "\n",
               "Stops Level: ", symb_stoplevel, "\n",
               "Ask: ", symb_ask,"\n",
               "Bid: ", symb_bid, "\n",
               "Last: ", symb_last
               );
               
   } else if(tipo == COMMENT) {
      //--- Adiciona comentário no gráfico
      Comment("Symbol: ", symb_symbol, "\n",
                 "Digits: ", symb_digits, "\n",
                 "Spread: ", symb_spread, "\n",
                 "Stops Level: ", symb_stoplevel, "\n",
                 "Ask: ", symb_ask, "\n",
                 "Bid: ", symb_bid, "\n",
                 "Last: ", symb_last
                 );
       
       int mb_res = -1;
       mb_res = MessageBox("Do you want to delete comments from the chart?",NULL,MB_YESNO|MB_ICONQUESTION);
       if(mb_res == IDYES){
         Comment("");
       }
      
   } else if(tipo == ALERT) {  
      //--- Gera popup de alerta
      Alert("Symbol: "+symb_symbol+"\n",
               "Digits: " + IntegerToString(symb_digits) + "\n",
               "Spread: " + IntegerToString(symb_spread) + "\n",
               "Stops Level: " + IntegerToString(symb_stoplevel) + "\n",
               "Ask: " + DoubleToString(symb_ask,_Digits) + "\n",
               "Bid: " + DoubleToString(symb_bid,_Digits) + "\n",
               "Last: " + DoubleToString(symb_last,_Digits)
               );
               
   }
}