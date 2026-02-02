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

