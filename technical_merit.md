# Technical Merit - FairScale AI

*(The following is a draft you can use for the "Technical Merit" or architecture section of your GDGC Solution Challenge application!)*

---

### Architecture & Technology Stack
FairScale AI is a full-stack, cloud-native application built entirely on the Google Developer ecosystem. Our architecture intentionally segregates heavy AI training from real-time evaluation to ensure high performance and seamless user experience.

1. **Frontend (Flutter Web):** 
   Our Manager Dashboard is built using Flutter for Web. Flutter was chosen for its high-performance rendering engine, allowing us to build a seamless, native-feeling UI with complex micro-animations (such as the Vertex AI spawning mockups and real-time intercept scanners). It operates as a Single Page Application (SPA) enforcing a strict Material 3 design system to ensure accessibility and aesthetic professionalism.

2. **Backend & Real-Time Sync (Firebase Cloud Firestore):** 
   To mimic real-time loan origination and live bias interception, we utilize Firebase Cloud Firestore. When an applicant (e.g., Leo) submits their HTML/JS Bank Form, the document is securely injected into Firestore. Our Flutter dashboard listens to this Firestore collection via bi-directional WebSockets (`StreamBuilder`), granting managers instantaneous notifications of intercepted applications without manual polling.

3. **Machine Learning Pipeline (Vertex AI):** 
   Our core bias-mitigation engine relies on a multi-model architecture. Upon dataset ingestion, we utilize Google Vertex AI to spawn three concurrent engines:
   - **Model A**: The standard baseline model prone to historical data biases.
   - **Model B (The Detective)**: An adversarial model trained specifically to flag correlations between decisions and protected attributes (e.g., Race, Gender).
   - **Model C (The Fair Mirror)**: A sanitized model relying strictly on valid feature mapping via causal inference mechanisms.
   This "Shield" architecture prevents catastrophic bias propagation by intercepting Model A's output *before* it reaches the user.

4. **Explainable AI (Gemini 1.5):**
   A major challenge in AI fairness is "black box" math. We integrate the Gemini API to act as an abstraction layer. Gemini takes the raw feature weights and bias score differentials between Model A and Model C and uses Natural Language Generation to produce a plain-English, human-readable summary. This empowers the human-in-the-loop (the Manager) to quickly understand *why* an interception occurred and confidently apply the FairFlow Fix.

### Innovation & Technical Complexity
The primary technical merit of FairScale AI lies in its **Self-Healing Loop framework**. By integrating Vertex AI model isolation with human-in-the-loop validation via Gemini's generative capabilities, we have created an audit-compliant, robust middleware. When a manager applies the "FairFlow Fix," the system not only overrides the immediate API response to the user, but it logs an adversarial correction back into the model's training pipeline, ensuring the bias is mechanically smoothed out in future epochs.
