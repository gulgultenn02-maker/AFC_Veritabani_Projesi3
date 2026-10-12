# 🚌 AFC (Automatic Fare Collection) — Enterprise Database Architecture & Reporting

Bu proje, toplu taşıma sistemlerinde (otobüs, metro, turnike vb.) kullanılan **Otomatik Ücret Toplama (AFC)** altyapısının kurumsal veritabanı mimarisini, veri modellemesini ve analitik raporlama yordamlarını içermektedir.

---

## 🛠️ Teknolojik Mimariler & Araçlar
* **Veritabanı Engine:** SQL Server (Azure SQL Edge - Docker Container)
* **Geliştirme Ortamı:** macOS & Visual Studio Code (MSSQL Extension)
* **Veritabanı Standartları:** Corporate Standard v2 (Single Primary Key, Normalized FK Naming, Standard Audit Trail Fields)

---

## 📐 Veritabanı Mimarisi ve v2 Standartları

Sistemdeki tüm tablolar kurumsal veri standartlarına uygun olarak tasarlanmıştır:
1. **Primary Key Yapısı:** Tüm ana ve işlem tabloları `IDENTITY(1,1)` türünde tekil `Id` alanına sahiptir.
2. **Foreign Key Standartları:** İlişkili tablolar `{ReferencedTable}_Id` formatında adlandırılmıştır (Örn: `Vehicle.Validator_Id`, `Transactions.Vehicle_Id`).
3. **Audit Log Alanları:** Tüm master tablolarda kayıt izleme için `InsertDate`, `TransactionDate`, `IsActive` ve `IsDeleted` alanları mevcuttur.

---

## 💡 Kritik Mimari Tasarım Kararı (Trade-Off)

> **Banka Kartı (Contactless Credit/Debit Card) Biniş Mimarisi:**
> System; fiziki şehir kartlarının yanı sıra temassız banka kartı okutmalarını da desteklemektedir. 
> 
> Banka kartlarının sistemde kayıtlı bir kart numarası (`CardNumber`), kart tipi (`CardType_Id`) veya bakiyesi (`RemainingBalance`) **bulunmamaktadır**. Banka kartı biniş verilerini genel `Transactions` tablosuna `NULL` alanlarla zorlamak veri kirliliğine yol açacağından, bu veriler **`BankCardTaps`** adı altında ayrı ve izole bir tabloda modellenmiştir.
> 
> Raporlama aşamasında veriler, finansal kayıpları ve verinin tekleşerek kaybolmasını önlemek adına **`UNION ALL`** mimarisi ile konsolide raporda birleştirilmektedir.

---

## 🚀 Öne Çıkan Özellikler & Raporlama (`sp_GetCardUsageReport`)

`afc.sp_GetCardUsageReport` saklı yordamı (Stored Procedure); fiziki binişleri (`Transactions`), yüklemeleri (`TopUps`) ve banka kartı temaslarını (`BankCardTaps`) tek bir zaman sıralı aktivite akışında birleştirir:

* **Tarihsel Bakiye Doğruluğu:** Yükleme işlemlerinde canlı bakiye yerine tarihsel doğruluğu korumak için işlem anındaki bakiye (`BalanceAfter`) kullanılır.
* **Akıllı Filtreleme:** Kart numarasına göre arama yapıldığında, ön kaydı olmayan temassız banka kartları otomatik olarak filtrelenerek doğru sonuç üretilir.

```sql
-- Örnek Rapor Çağrısı
EXEC afc.sp_GetCardUsageReport @StartDate = '2026-09-01', @EndDate = '2026-09-30';