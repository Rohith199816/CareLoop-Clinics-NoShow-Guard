# CareLoop-Clinics-NoShow-Guard

[GitHub Repository Link](https://github.com/Rohith199816/CareLoop-Clinics-NoShow-Guard)

---
### Project Summary (Parts 1–4)
1. **Part 1 & 2 (Data Engineering & SQL):** Cleaned **5,000** total appointment records and set up relational SQL queries for clinic data.
2. **Part 3 (Machine Learning):** Trained a Logistic Regression model to predict patient no-shows with an ROC-AUC of **0.77** and a threshold of **0.35**.
3. **Part 4 (GenAI Call Notes):** Used the Gemini API and Pydantic to extract root causes from **10** front-desk follow-up notes.
4. **Integration & Insights:** Merged the data to discover that **5** out of **10** missed appointments occurred because patients received no reminder.

---

### Business Recommendation
To lower the appointment no-show rate, the clinic should immediately set up automated text reminders 24 hours before visits. Out of **5,000** total patient records in the system, analyzing **10** missed-appointment call notes revealed that **5** lacked automated reminders. By combining these findings with our predictive model (set at a **0.35** threshold and **0.77** ROC-AUC), front-desk staff can easily flag high-risk patients and call them ahead of time.

---

### Model Choice & Rationale
* **Chosen Model:** Logistic Regression.
* **Why:** It provides clear, easy-to-interpret probabilities and reliable performance.
* **Key Metrics:** ROC-AUC of **0.77** using a tuned decision threshold of **0.35**.

---

### Limitations
1. **Small Sample Size:** Only **10** call notes were analyzed, which is too small to reflect the entire clinic.
2. **Observational Data:** The data shows strong patterns, but does not prove direct cause and effect.
3. **Single Train/Test Split:** The model was evaluated using only one random train/test split rather than multi-fold validation.
