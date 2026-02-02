# 📊 TodayStats — MT5 Trading Statistics Indicator

A lightweight **MetaTrader 5 indicator** that displays **daily and all-time trading statistics** directly on the chart using text labels (no plots, no buffers).

---

## ✨ Features

* Daily trading performance

  * Winning trades count
  * Losing trades count
  * Today’s realized profit/loss
* Current open positions
* All-time realized trading P/L
* Balance, Equity, and Floating P/L
* Uses **multiple chart labels** (no newline rendering issues)
* Auto-refresh using a timer
* Fully customizable (font, size, color, position)

---

## 🧠 What This Indicator Is (and Is Not)

### ✅ What it is

* A **statistics overlay** for MT5
* Based on **History Deals**
* Focused on **real trading performance (BUY/SELL only)**

### ❌ What it is NOT

* It does not plot indicators
* It does not mix deposits/withdrawals with trade P/L
* It does not depend on market ticks

---

## 🖥️ On-Chart Display (Line by Line)

```
Trade Stats (History)
Today: Wins=3  Loss=1  Open=2
Today Realized P/L: 125.40
All-time Realized Trade P/L: 2431.75
Balance: 5231.75   Equity: 5198.30
Floating P/L (Equity-Balance): -33.45
```

---

## 📐 How “Today” Is Calculated

* Based on **broker server time**
* Day starts at `00:00:00` server time
* Trades are counted by **close time**, not open time

---

## 🔍 Calculation Logic (High Level)

1. Select deal history using `HistorySelect`
2. Filter only:

   * Closing deals (`DEAL_ENTRY_OUT`, `DEAL_ENTRY_OUT_BY`)
   * Trade types (`DEAL_TYPE_BUY`, `DEAL_TYPE_SELL`)
3. Calculate net profit:

   ```
   profit + commission + swap
   ```
4. Aggregate:

   * Today’s realized P/L
   * All-time realized trade P/L
5. Display results using multiple labels

---

## 🧩 Why Multiple Labels?

MT5 sometimes fails to render multi-line text correctly.
Using **one label per line** guarantees:

* No broken characters
* No square symbols
* Correct layout on all MT5 builds

---

## 🧱 Code Architecture Overview

| Component         | Purpose                    |
| ----------------- | -------------------------- |
| Inputs            | User customization         |
| Utility functions | Date & profit calculations |
| UI helpers        | Label creation & updates   |
| Core engine       | Statistics calculation     |
| Event handlers    | Timer-based refresh        |

---

## 🛠️ Installation

1. Copy `TodayStats.mq5` into:

   ```
   MQL5/Indicators/
   ```
2. Compile using MetaEditor
3. Attach to any chart

---

## 📜 License

Free to use and modify.
Attribution appreciated.

---

---

# 📊 TodayStats — اندیکاتور آماری معاملات برای MT5 (فارسی)

این اندیکاتور یک **نمایش‌دهنده‌ی آماری سبک و دقیق** برای متاتریدر ۵ است که **وضعیت معاملات امروز و کل حساب** را به‌صورت متنی روی چارت نمایش می‌دهد.

---

## 🎯 هدف این اندیکاتور

* نمایش **نتیجه واقعی ترید**
* تفکیک معاملات بسته‌شده از معاملات باز
* جلوگیری از قاطی شدن:

  * واریز / برداشت
  * کردیت
  * عملیات بالانس
    با سود و ضرر معاملات

---

## 📌 اطلاعاتی که نمایش داده می‌شود

### 1️⃣ تعداد برد و باخت امروز

* بر اساس **زمان بسته‌شدن معامله**
* فقط معاملات Buy / Sell

### 2️⃣ سود و ضرر امروز (Realized)

* فقط معاملات **بسته‌شده‌ی امروز**
* شامل:

  * Profit
  * Commission
  * Swap

### 3️⃣ سود و ضرر کل تاریخچه معاملات

* جمع تمام معاملات بسته‌شده در History
* **فقط ترید واقعی**
* بدون واریز و برداشت

### 4️⃣ معاملات باز

* تعداد Positionهای باز فعلی

### 5️⃣ Balance / Equity

* Balance: موجودی بدون معاملات باز
* Equity: موجودی واقعی لحظه‌ای

### 6️⃣ Floating P/L

```
Floating = Equity - Balance
```

سود یا ضرر معاملات باز فعلی

---

## ⏰ تعریف «امروز»

* بر اساس **ساعت سرور بروکر**
* از 00:00:00 تا زمان فعلی
* نه ساعت سیستم کاربر

---

## 🧠 منطق محاسبه سود و ضرر

اندیکاتور فقط این Dealها را حساب می‌کند:

* `DEAL_ENTRY_OUT`
* `DEAL_ENTRY_OUT_BY`
* `DEAL_TYPE_BUY`
* `DEAL_TYPE_SELL`

❌ موارد زیر حذف می‌شوند:

* Deposit
* Withdrawal
* Credit
* Balance operations

---

## 🧩 چرا از چند Label استفاده شده؟

در MT5 نمایش متن چندخطی گاهی خراب می‌شود.
برای حل قطعی مشکل:

✔ هر خط = یک Label
✔ بدون `\n`
✔ بدون مربع‌های ناخوانا

---

## 👨‍💻 مناسب چه کسانی است؟

* تریدرهای دستی
* الگوتریدرها
* برنامه‌نویس‌های MQL5
* کسانی که می‌خواهند **آمار واقعی ترید** ببینند

---




## 1) سرآیند Indicator (Properties)

```mq5
#property indicator_chart_window
#property strict
#property indicator_plots 0
#property indicator_buffers 0
```

* `indicator_chart_window` یعنی این اندیکاتور داخل **پنجره اصلی چارت** نمایش داده می‌شود (نه زیر چارت مثل RSI).
* `strict` یعنی کامپایلر سخت‌گیرتر می‌شود (کد تمیزتر و خطاها زودتر مشخص می‌شود).
* `indicator_plots 0` یعنی **هیچ نموداری رسم نمی‌کنیم**.
* `indicator_buffers 0` یعنی **هیچ بافری برای رسم نداریم**.

این ۲ خط آخر باعث می‌شود Warning مربوط به “no plot defined” هم نیاد.

---

## 2) ورودی‌ها (Inputs)

```mq5
input bool   IncludeCommissionAndSwap = true;
input int    RefreshSeconds = 2;

input string FontName = "Tahoma";
input int    FontSize = 10;

input int    X_Distance = 10;   // from left
input int    Y_Distance = 20;   // from bottom (line 0)
input int    LineStep   = 16;   // pixel gap between lines

input color  TextColor  = clrWhite;
```

`input` یعنی کاربر بتواند از تنظیمات اندیکاتور تغییرش دهد.

* `IncludeCommissionAndSwap`
  اگر `true` باشد، سود/ضرر خالص = Profit + Commission + Swap.
  اگر `false` باشد فقط Profit.
* `RefreshSeconds` هر چند ثانیه یکبار متن بروزرسانی شود.
* `FontName` و `FontSize` برای فونت متن.
* `X_Distance` فاصله از لبه چپ.
* `Y_Distance` فاصله خط اول از پایین.
* `LineStep` فاصله هر خط نسبت به خط قبلی (پیکسل).
* `TextColor` رنگ متن.

---

## 3) متغیرهای سراسری (Global)

```mq5
string PREFIX = "TodayStats_Line_";
int    LINES  = 6;
```

* `PREFIX` برای نام‌گذاری آبجکت‌ها. چون ما چند Label داریم، نام هر کدام می‌شود:

  * TodayStats_Line_0
  * TodayStats_Line_1
  * ...
* `LINES` تعداد خطوطی است که می‌خواهیم نمایش بدهیم (۶ خط).

---

## 4) تابع شروع روز (TodayStart)

```mq5
datetime TodayStart()
{
   MqlDateTime t;
   TimeToStruct(TimeCurrent(), t);
   t.hour = 0; t.min = 0; t.sec = 0;
   return StructToTime(t); // server day start
}
```

این تابع یک `datetime` برمی‌گرداند: **شروع امروز** به وقت سرور بروکر.

* `MqlDateTime t;`
  یک ساختار (struct) که اجزای تاریخ/زمان را جداگانه نگه می‌دارد (سال/ماه/روز/ساعت/…).
* `TimeCurrent()`
  زمان فعلی **سرور** را می‌دهد (خیلی مهم: نه زمان کامپیوتر).
* `TimeToStruct(..., t)`
  datetime را تبدیل می‌کند به ساختار `t` تا بتوانیم ساعت/دقیقه/ثانیه را تغییر دهیم.
* `t.hour=0...`
  ساعت را می‌کنیم صفر، یعنی 00:00:00
* `StructToTime(t)`
  دوباره ساختار را تبدیل به datetime می‌کنیم.

پس `t0 = TodayStart()` یعنی “از ابتدای امروز”.

---

## 5) محاسبه سود خالص یک Deal (DealNetProfit)

```mq5
double DealNetProfit(const ulong deal_ticket)
{
   double profit     = HistoryDealGetDouble(deal_ticket, DEAL_PROFIT);
   double commission = HistoryDealGetDouble(deal_ticket, DEAL_COMMISSION);
   double swap       = HistoryDealGetDouble(deal_ticket, DEAL_SWAP);

   if(IncludeCommissionAndSwap) return (profit + commission + swap);
   return profit;
}
```

اینجا ما از **History Deals** می‌خوانیم.

* `deal_ticket` شناسه یکتای یک Deal است.
* `HistoryDealGetDouble(ticket, DEAL_PROFIT)` سود خام آن Deal.
* `DEAL_COMMISSION` کمیسیون همان Deal.
* `DEAL_SWAP` سواپ همان Deal.

اگر گزینه ورودی `IncludeCommissionAndSwap` روشن باشد، سود خالص حساب می‌شود.

> نکته آموزشی: در MT5 “History” با Deal و Order و Position فرق دارد.
> Profit نهایی وقتی معامله بسته می‌شود معمولاً در Dealهای خروجی ثبت می‌شود.

---

## 6) ساخت Label برای هر خط (EnsureLineLabel)

```mq5
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
```

هدف: اگر Label آن خط وجود ندارد، بسازش.

* `idx` شماره خط (۰ تا ۵).
* `name` اسم آبجکت می‌شود مثلا `TodayStats_Line_3`
* `ObjectFind(0,name)`
  اگر آبجکت روی چارت هست، مقدار >=0 می‌دهد، پس دیگر دوباره نساز.
* `ObjectCreate(..., OBJ_LABEL, ...)`
  یک Label ایجاد می‌کند.
* `OBJPROP_CORNER` تعیین می‌کند مبنای فاصله‌ها کدام گوشه است.
  `CORNER_LEFT_LOWER` یعنی **پایین-چپ**
* `XDISTANCE` فاصله از چپ
* `YDISTANCE` فاصله از پایین
  ما گفتیم: `Y_Distance + idx * LineStep`
  یعنی هر خط کمی بالاتر از خط قبلی قرار بگیرد.

بقیه:

* تنظیم فونت/سایز/رنگ
* `SELECTABLE=false` یعنی با ماوس قابل انتخاب نباشد
* `HIDDEN=true` یعنی در لیست Objects خیلی توی دست و پا نباشد

---

## 7) نوشتن متن هر خط (SetLine)

```mq5
void SetLine(const int idx, const string text)
{
   string name = PREFIX + IntegerToString(idx);
   EnsureLineLabel(idx);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
}
```

این تابع یک API ساده برای ماست:

* اول مطمئن می‌شود Label ساخته شده (`EnsureLineLabel`)
* بعد متن را با `OBJPROP_TEXT` داخلش می‌نویسد.

---

## 8) تابع اصلی محاسبه و نمایش (UpdateStats)

این مهم‌ترین بخش است.

### 8-1) گرفتن بازه زمانی امروز

```mq5
datetime t0 = TodayStart();
datetime t1 = TimeCurrent();
```

* `t0` شروع امروز
* `t1` الآن

### 8-2) متغیرهای امروز

```mq5
int winsToday = 0, lossToday = 0;
double plToday = 0.0;
```

* شمارنده برد و باخت امروز
* جمع سود/ضرر امروز

### 8-3) انتخاب History امروز

```mq5
HistorySelect(t0, t1);
int deals = HistoryDealsTotal();
```

* `HistorySelect(from,to)` به MT5 می‌گوید تاریخچه بین این دو زمان را آماده کند.
* `HistoryDealsTotal()` تعداد Dealهایی که در این بازه وجود دارد.

### 8-4) حلقه روی Dealها (امروز)

```mq5
for(int i = 0; i < deals; i++)
{
   ulong deal = HistoryDealGetTicket(i);
   if(deal == 0) continue;
```

* `HistoryDealGetTicket(i)` تیکت Deal شماره i را می‌دهد.
* اگر 0 بود یعنی معتبر نیست.

### 8-5) فیلتر کردن فقط Dealهای بستن معامله

```mq5
   long entry = HistoryDealGetInteger(deal, DEAL_ENTRY);
   if(entry != DEAL_ENTRY_OUT && entry != DEAL_ENTRY_OUT_BY) continue;
```

* `DEAL_ENTRY` مشخص می‌کند این Deal مربوط به ورود است یا خروج.
* ما فقط خروجی‌ها را می‌خواهیم:

  * `OUT` = خروج معمولی
  * `OUT_BY` = خروج با معامله مخالف (برای بعضی حالت‌ها)

بدون این فیلتر، ممکن است Dealهای ورود هم وارد محاسبه شوند و آمار خراب شود.

### 8-6) فیلتر کردن فقط Buy/Sell (نه واریز و …)

```mq5
   long type = HistoryDealGetInteger(deal, DEAL_TYPE);
   if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL) continue;
```

این خیلی مهم است:
در History ممکن است Dealهای غیرتجاری هم باشد (Balance/Credit/Charge).
ما فقط Buy/Sell را حساب می‌کنیم تا “P/L ترید” درست باشد.

### 8-7) محاسبه سود خالص و جمع زدن

```mq5
   double net = DealNetProfit(deal);
   plToday += net;
```

* سود خالص Deal
* اضافه به مجموع سود امروز

### 8-8) برد/باخت

```mq5
   if(net > 0.0) winsToday++;
   else if(net < 0.0) lossToday++;
```

* اگر مثبت = برد
* اگر منفی = باخت
* اگر صفر باشد هیچکدام (نه برد نه باخت)

---

### 8-9) تعداد پوزیشن‌های باز

```mq5
int openPositions = PositionsTotal();
```

* تعداد Positionهای باز فعلی (معاملات هنوز بسته نشده).

---

### 8-10) محاسبه سود/ضرر کل تاریخچه (All-time)

```mq5
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
```

همان منطق امروز، فقط بازه زمانی از `0` تا الآن است.

این خروجی یعنی:
✅ “کل سود/ضرر معاملات بسته‌شده Buy/Sell در تمام تاریخچه”

---

### 8-11) Balance / Equity / Floating

```mq5
double balance = AccountInfoDouble(ACCOUNT_BALANCE);
double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
double floating = equity - balance;
```

* `ACCOUNT_BALANCE` = موجودی بدون معاملات باز
* `ACCOUNT_EQUITY` = موجودی با معاملات باز
* `floating = equity - balance` = سود/ضرر معاملات باز (Floating P/L)

---

### 8-12) چاپ روی چارت با چند خط Label

```mq5
SetLine(0, "Trade Stats (History)");
SetLine(1, "Today: Wins=" + IntegerToString(winsToday) +
           "  Loss=" + IntegerToString(lossToday) +
           "  Open=" + IntegerToString(openPositions));
SetLine(2, "Today Realized P/L: " + DoubleToString(plToday, 2));
SetLine(3, "All-time Realized Trade P/L: " + DoubleToString(plAllTrades, 2));
SetLine(4, "Balance: " + DoubleToString(balance, 2) + "   Equity: " + DoubleToString(equity, 2));
SetLine(5, "Floating P/L (Equity-Balance): " + DoubleToString(floating, 2));
```

* هر خط یک Label جداست → مشکل مربع‌ها و یک‌خط شدن **حل می‌شود**.
* `IntegerToString` تبدیل عدد صحیح به رشته
* `DoubleToString(x,2)` عدد اعشاری با ۲ رقم اعشار

در آخر:

```mq5
ChartRedraw();
```

به چارت می‌گوید فوراً رفرش کند.

---

## 9) رویدادهای اصلی Indicator

### OnInit (شروع)

```mq5
int OnInit()
{
   for(int i=0;i<LINES;i++) EnsureLineLabel(i);
   EventSetTimer(MathMax(1, RefreshSeconds));
   UpdateStats();
   return INIT_SUCCEEDED;
}
```

* همه Labelها را از اول می‌سازد.
* تایمر می‌گذارد هر `RefreshSeconds` ثانیه اجرا شود.
* یکبار هم همین اول `UpdateStats()` را صدا می‌زند تا فوری نمایش بدهد.

### OnDeinit (پایان)

```mq5
void OnDeinit(const int reason)
{
   EventKillTimer();
   for(int i=0;i<LINES;i++)
      ObjectDelete(0, PREFIX + IntegerToString(i));
}
```

* تایمر را خاموش می‌کند
* تمام Labelها را از چارت پاک می‌کند (تمیزکاری)

### OnTimer (هر چند ثانیه)

```mq5
void OnTimer()
{
   UpdateStats();
}
```

هر بار که تایمر “زنگ” می‌زند، دوباره محاسبه و نمایش می‌کند.

### OnCalculate (اجباری برای Indicator)

```mq5
int OnCalculate(...)
{
   return rates_total;
}
```

چون ما چیزی رسم نمی‌کنیم، فقط مقدار `rates_total` را برمی‌گردانیم.

---

## ✅ نتیجه نهایی: این اندیکاتور دقیقاً چه چیزهایی را درست می‌دهد؟

* تعداد برد/باخت امروز = فقط معاملات **بسته‌شده امروز**
* سود/ضرر امروز = جمع سود/ضرر **بسته‌شده امروز**
* سود/ضرر کل تاریخچه = جمع سود/ضرر **تمام معاملات بسته‌شده Buy/Sell**
* معاملات باز = تعداد Positionهای الان
* Floating = سود/ضرر معاملات باز همین لحظه

---

