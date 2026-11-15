-- =========================================================================
-- PART 2: Database Setup, Loading, and Business Queries
-- =========================================================================

-- -------------------------------------------------------------------------
-- Task 2.1 — Build and load the database & test constraints
-- -------------------------------------------------------------------------

-- CREATE DATABASE noshowguard;
-- USE noshowguard;

-- I have skipped this, as I am using SQLiteOnline

CREATE TABLE clinics (
  clinic_id VARCHAR(5) PRIMARY KEY,
  clinic_name VARCHAR(40) NOT NULL,
  city VARCHAR(20) NOT NULL,
  tier VARCHAR(10),
  latitude DECIMAL(8,4),
  longitude DECIMAL(8,4),
  temp_c DECIMAL(5,1)
);

CREATE TABLE appointments (
  appointment_id VARCHAR(8) PRIMARY KEY,
  patient_id VARCHAR(8) NOT NULL,
  clinic_id VARCHAR(5) NOT NULL,
  booked_on DATE,
  appt_date DATE,
  age INT,
  gender VARCHAR(1),
  distance_km DECIMAL(5,1),
  fee_inr INT,
  booking_channel VARCHAR(10),
  visit_type VARCHAR(12),
  reminder_sent VARCHAR(3),
  prior_no_shows INT,
  status VARCHAR(10),
  lead_days INT,
  no_show INT,
  FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id)
);

-- Note: Run your load_data.sql script here to populate 'clinics' and 'appointments'.

SELECT COUNT(*) AS total_appointments FROM appointments;
SELECT SUM(no_show) AS total_no_shows FROM appointments;

INSERT INTO appointments (
  appointment_id, patient_id, clinic_id, booked_on, appt_date, 
  age, gender, distance_km, fee_inr, booking_channel, 
  visit_type, reminder_sent, prior_no_shows, status, lead_days, no_show
) 
VALUES (
  'A0001', 'P999', 'C01', '2025-01-01', '2025-01-05', 
  30, 'F', 5.0, 500, 'App', 
  'Consult', 'Yes', 0, 'Completed', 4, 0
);

-- ERROR COMMENT:
-- MySQL Error Code: 1062. Duplicate entry 'A0001' for key 'appointments.PRIMARY'
-- SQLite Error: UNIQUE constraint failed: appointments.appointment_id


-- -------------------------------------------------------------------------
-- Task 2.2 — No-show rate by clinic
-- -------------------------------------------------------------------------

-- A. Keeping only clinics with at least 95 appointments (HAVING clause)
SELECT 
    c.clinic_name, 
    c.city, 
    COUNT(a.appointment_id) AS appointments, 
    SUM(a.no_show) AS no_shows, 
    ROUND(100.0 * SUM(a.no_show) / COUNT(*), 1) AS no_show_pct
FROM clinics c
JOIN appointments a ON c.clinic_id = a.clinic_id
GROUP BY c.clinic_id, c.clinic_name, c.city
HAVING COUNT(a.appointment_id) >= 95
ORDER BY no_show_pct DESC;

-- B. All 8 clinics (without HAVING) to identify highest rate and appointment count
SELECT 
    c.clinic_name, 
    c.city, 
    COUNT(a.appointment_id) AS appointments, 
    SUM(a.no_show) AS no_shows, 
    ROUND(100.0 * SUM(a.no_show) / COUNT(*), 1) AS no_show_pct
FROM clinics c
JOIN appointments a ON c.clinic_id = a.clinic_id
GROUP BY c.clinic_id, c.clinic_name, c.city
ORDER BY no_show_pct DESC;


-- -------------------------------------------------------------------------
-- Task 2.3 — Does booking far ahead matter? (Lead-time bands)
-- -------------------------------------------------------------------------

SELECT 
    CASE 
        WHEN lead_days BETWEEN 1 AND 7 THEN '1-7'
        WHEN lead_days BETWEEN 8 AND 14 THEN '8-14'
        WHEN lead_days BETWEEN 15 AND 30 THEN '15-30'
        ELSE '31+'
    END AS lead_band,
    COUNT(*) AS appointments,
    SUM(no_show) AS no_shows,
    ROUND(100.0 * SUM(no_show) / COUNT(*), 1) AS no_show_pct
FROM appointments
GROUP BY lead_band
ORDER BY MIN(lead_days);


-- -------------------------------------------------------------------------
-- Task 2.4 — Month-by-month trend with LAG()
-- -------------------------------------------------------------------------

WITH monthly AS (
    SELECT 
        SUBSTR(appt_date, 1, 7) AS month,
        COUNT(*) AS appointments,
        ROUND(100.0 * SUM(no_show) / COUNT(*), 1) AS no_show_pct
    FROM appointments
    GROUP BY month
)
SELECT 
    month,
    appointments,
    no_show_pct,
    ROUND(no_show_pct - LAG(no_show_pct) OVER (ORDER BY month), 1) AS pct_point_change
FROM monthly
ORDER BY month;


-- -------------------------------------------------------------------------
-- Task 2.5 — Rank clinics inside each city & compare vs overall rate
-- -------------------------------------------------------------------------

WITH clinic_rates AS (
    SELECT 
        c.clinic_name AS clinic,
        c.city,
        ROUND(100.0 * SUM(a.no_show) / COUNT(*), 1) AS no_show_pct
    FROM clinics c
    JOIN appointments a ON c.clinic_id = a.clinic_id
    GROUP BY c.clinic_id, c.clinic_name, c.city
)
SELECT 
    clinic,
    city,
    no_show_pct,
    RANK() OVER (PARTITION BY city ORDER BY no_show_pct DESC) AS rank_in_city,
    CASE 
        WHEN no_show_pct > (SELECT ROUND(100.0 * SUM(no_show) / COUNT(*), 1) FROM appointments) THEN 'above'
        WHEN no_show_pct < (SELECT ROUND(100.0 * SUM(no_show) / COUNT(*), 1) FROM appointments) THEN 'below'
        ELSE 'equal'
    END AS vs_overall
FROM clinic_rates
ORDER BY city, rank_in_city;