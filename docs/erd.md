# BeautyBook Gold Layer — ERD (Star Schema)

This diagram represents the **Gold-layer star schema** for professional engagement
and booking conversion analytics.

```mermaid
erDiagram

  %% =========================
  %% Dimensions
  %% =========================
  DIM_PROFESSIONALFESSIONAL {
    string professional_id PK
    string email
    string first_name
    string last_name
    string business_name
    string service_category
    string city
    string state
    string zip_code
    date   signup_date
    int    tenure_days
    string tenure_band
    string subscription_tier
    boolean is_active
    float  profile_completeness_pct
    float  avg_rating
    int    total_reviews
  }

  DIM_CLIENT {
    string client_id PK
  }

  DIM_SERVICE {
    string service_id PK
    string service_name UK
  }

  DIM_DATE {
    string date_id PK
    date   date_day UK
    int    year
    int    month
    int    day
    int    day_of_week
    string day_name
    date   week_start_date
    date   month_start_date
    boolean is_weekend
  }

  DIM_TIME {
    string time_id PK
    int    hour_of_day UK
    string time_bucket
  }


  %% =========================
  %% Atomic Facts
  %% =========================
  FCT_BOOKINGS {
    string booking_id PK
    string professional_id FK
    string client_id FK
    string service_name
    timestamp booking_created_at
    date   booking_created_date
    int    booking_created_hour
    string booking_status
    string payment_status
    date   appointment_date
    string appointment_start_time
    string appointment_end_time
    float  booking_amount
    float  tip_amount
    string cancellation_reason
    boolean is_first_time_client
  }

  FCT_SESSIONS {
    string session_id PK
    string professional_id FK
    timestamp session_start_at
    timestamp session_end_at
    date   session_start_date
    int    session_start_hour
    string platform
    string device_type
    int    pages_viewed
    int    calendar_views
    int    messages_opened
    int    profile_edits
    int    photos_uploaded
    int    session_duration_seconds
  }

  FCT_MESSAGES {
    string message_id PK
    string professional_id FK
    string client_id FK
    string thread_id
    string sender_type
    timestamp message_sent_at
    timestamp message_read_at
    date   message_sent_date
    int    message_sent_hour
    string message_type
    boolean has_attachment
    string booking_id FK_nullable
  }

  %% =========================
  %% Pro Engagement Rollups (Gold Pro Engagement schema)
  %% =========================

  FCT_MESSAGE_RESPONSES {
    string client_message_id PK
    string pro_reply_message_id
    string professional_id FK
    string client_id FK
    string thread_id
    timestamp client_message_sent_at
    timestamp pro_reply_sent_at
    int    response_time_seconds
    date   response_date
    int    response_hour
  }

  FCT_PROFESSIONAL_METRICS_DAILY {
    string professional_id FK
    date   date_day
    int    sessions_count
    int    session_duration_seconds_total
    float  session_duration_seconds_avg
    int    messages_count
    int    pro_messages_sent_count
    int    client_messages_sent_count
    float  avg_response_time_seconds
    float  median_response_time_seconds
    int    responses_within_5m
    int    responses_count
    int    bookings_created_count
    int    bookings_success_count
    float  conversion_rate_created_to_success
  }

  %% =========================
  %% Relationships (Stars)
  %% =========================
  DIM_PROFESSIONAL ||--o{ FCT_BOOKINGS : professional_id
  DIM_CLIENT ||--o{ FCT_BOOKINGS : client_id
  DIM_DATE ||--o{ FCT_BOOKINGS : booking_created_date
  DIM_TIME ||--o{ FCT_BOOKINGS : booking_created_hour
  DIM_SERVICE ||--o{ FCT_BOOKINGS : service_name

  DIM_PROFESSIONAL ||--o{ FCT_SESSIONS : professional_id
  DIM_DATE ||--o{ FCT_SESSIONS : session_start_date
  DIM_TIME ||--o{ FCT_SESSIONS : session_start_hour

  DIM_PROFESSIONAL ||--o{ FCT_MESSAGES : professional_id
  DIM_CLIENT ||--o{ FCT_MESSAGES : client_id
  DIM_DATE ||--o{ FCT_MESSAGES : message_sent_date
  DIM_TIME ||--o{ FCT_MESSAGES : message_sent_hour
  FCT_BOOKINGS ||--o{ FCT_MESSAGES : booking_id

  DIM_PROFESSIONAL ||--o{ FCT_MESSAGE_RESPONSES : professional_id
  DIM_CLIENT ||--o{ FCT_MESSAGE_RESPONSES : client_id
  DIM_DATE ||--o{ FCT_MESSAGE_RESPONSES : response_date
  DIM_TIME ||--o{ FCT_MESSAGE_RESPONSES : response_hour

  %% Rollup facts: conformed to pro + date grains
  DIM_PROFESSIONAL ||--o{ FCT_PROFESSIONAL_METRICS_DAILY : professional_id
  DIM_DATE ||--o{ FCT_PROFESSIONAL_METRICS_DAILY : date_day
```
