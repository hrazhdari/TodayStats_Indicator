#property indicator_chart_window
#property strict
#property indicator_plots 0
#property indicator_buffers 0

input bool   IncludeCommissionAndSwap = true;
input int    RefreshSeconds = 2;

input string FontName = "Tahoma";
input int    FontSize = 10;

input int    X_Distance = 10;   // from left
input int    Y_Distance = 20;   // from bottom (line 0)
input int    LineStep   = 16;   // pixel gap between lines

input color  TextColor  = clrWhite;

string PREFIX = "TodayStats_Line_";
int    LINES  = 6;

datetime TodayStart()
{
   MqlDateTime t;
   TimeToStruct(TimeCurrent(), t);
   t.hour = 0; t.min = 0; t.sec = 0;
   return StructToTime(t); // server day start
}

double DealNetProfit(const ulong deal_ticket)
{
   double profit     = HistoryDealGetDouble(deal_ticket, DEAL_PROFIT);
   double commission = HistoryDealGetDouble(deal_ticket, DEAL_COMMISSION);
   double swap       = HistoryDealGetDouble(deal_ticket, DEAL_SWAP);

   if(IncludeCommissionAndSwap) return (profit + commission + swap);
   return profit;
}

void EnsureLineLabel(const int idx)
{
   string name = PREFIX + IntegerToString(idx);
   if(ObjectFind(0, name) >= 0) return;

   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER); // bottom-left
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, X_Distance);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, Y_Distance + idx * LineStep);

   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FontSize);
   ObjectSetString (0, name, OBJPROP_FONT, FontName);
   ObjectSetInteger(0, name, OBJPROP_COLOR, TextColor);

   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

void SetLine(const int idx, const string text)
{
   string name = PREFIX + IntegerToString(idx);
   EnsureLineLabel(idx);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
}

void UpdateStats()
{
   datetime t0 = TodayStart();
   datetime t1 = TimeCurrent();

   int winsToday = 0, lossToday = 0;
   double plToday = 0.0;

   // TODAY realized (trade closing deals only)
   HistorySelect(t0, t1);
   int deals = HistoryDealsTotal();
   for(int i = 0; i < deals; i++)
   {
      ulong deal = HistoryDealGetTicket(i);
      if(deal == 0) continue;

      long entry = HistoryDealGetInteger(deal, DEAL_ENTRY);
      if(entry != DEAL_ENTRY_OUT && entry != DEAL_ENTRY_OUT_BY) continue;

      long type = HistoryDealGetInteger(deal, DEAL_TYPE);
      if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL) continue;

      double net = DealNetProfit(deal);
      plToday += net;

      if(net > 0.0) winsToday++;
      else if(net < 0.0) lossToday++;
   }

   // Open positions now
   int openPositions = PositionsTotal();

   // ALL-TIME realized trade P/L (trade closing deals only)
   HistorySelect((datetime)0, t1);
   double plAllTrades = 0.0;

   int dealsAll = HistoryDealsTotal();
   for(int j = 0; j < dealsAll; j++)
   {
      ulong deal = HistoryDealGetTicket(j);
      if(deal == 0) continue;

      long entry = HistoryDealGetInteger(deal, DEAL_ENTRY);
      if(entry != DEAL_ENTRY_OUT && entry != DEAL_ENTRY_OUT_BY) continue;

      long type = HistoryDealGetInteger(deal, DEAL_TYPE);
      if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL) continue;

      plAllTrades += DealNetProfit(deal);
   }

   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
   double floating = equity - balance; // current open P/L (incl. swaps etc. depending broker)

   // --- render as multiple lines (NO newlines => NO squares)
   SetLine(0, "Trade Stats (History)");
   SetLine(1, "Today: Wins=" + IntegerToString(winsToday) +
              "  Loss=" + IntegerToString(lossToday) +
              "  Open=" + IntegerToString(openPositions));
   SetLine(2, "Today Realized P/L: " + DoubleToString(plToday, 2));
   SetLine(3, "All-time Realized Trade P/L: " + DoubleToString(plAllTrades, 2));
   SetLine(4, "Balance: " + DoubleToString(balance, 2) + "   Equity: " + DoubleToString(equity, 2));
   SetLine(5, "Floating P/L (Equity-Balance): " + DoubleToString(floating, 2));

   ChartRedraw();
}

int OnInit()
{
   for(int i=0;i<LINES;i++) EnsureLineLabel(i);
   EventSetTimer(MathMax(1, RefreshSeconds));
   UpdateStats();
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   for(int i=0;i<LINES;i++)
      ObjectDelete(0, PREFIX + IntegerToString(i));
}

void OnTimer()
{
   UpdateStats();
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   return rates_total;
}
