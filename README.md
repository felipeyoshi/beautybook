# BeautyBook Analytics — Gold Layer (dbt)

This dbt project implements the **Gold analytics layer** for the BeautyBook platform, with a focus on **professional engagement and booking conversion**.

The models are designed following a **Value-Driven Data Modeling (VDDM)** approach:  
business questions → analytical requirements → scalable data models.

---

## 🎯 Business Objectives

This Gold layer enables the business to answer the following core questions:

1. **What is the booking conversion rate by professional segment?**

   - Segmented by:
     - Professional tenure
     - Service category
     - Geographic location (city/state)

2. **How does session engagement correlate with booking volume?**

   - Session frequency
   - Session duration

3. **How does professional message responsiveness impact bookings?**

   - Average and median response time
   - Response rate within SLA windows

4. **When are professionals most engaged?**

   - Day of week
   - Time of day (hour + time buckets)

5. **How has professional engagement trended over time?**
   - Weekly trends
   - Monthly trends

These insights directly support **growth, retention, monetization, and product UX decisions**.

---

## 🏗 Architecture Overview

The project assumes a **medallion-style architecture**, and this repository covers **Gold only**.

### Source Tables (Raw)

- `pros`
- `bookings`
- `sessions`
- `messages`

These are referenced via dbt `sources` and lightly cleaned in staging models.

---

## 📂 Project Structure

```text
models/
├─ silver/
│  ├─ _sources.yml
└─ gold/
   ├─ dim_date.sql
   ├─ dim_time.sql
   ├─ dim_professional.sql
   ├─ dim_client.sql
   ├─ dim_service.sql
   │
   ├─ fct_bookings.sql
   ├─ fct_sessions.sql
   ├─ fct_messages.sql
   │
   └─ pro_engagements/
      ├─ fct_message_responses.sql
      ├─ fct_professional_metrics_daily.sql
```
