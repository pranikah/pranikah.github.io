const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const nodemailer = require("nodemailer");

initializeApp();

// Konfigurasi email — set via: firebase functions:secrets:set EMAIL_PASS
// Atau pakai environment config
const ADMIN_EMAIL = "leimportant@gmail.com";

// Gmail transporter — gunakan App Password (bukan password biasa)
// Set di Firebase: firebase functions:secrets:set EMAIL_PASS
function getTransporter() {
  return nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: ADMIN_EMAIL,
      pass: process.env.EMAIL_PASS, // App Password dari Google Account
    },
  });
}

/**
 * Trigger: saat dokumen baru ditambahkan ke admin_notifications
 * Kirim email ke admin dengan info user yang request premium
 */
exports.sendPremiumRequestEmail = onDocumentCreated(
  "admin_notifications/{docId}",
  async (event) => {
    const data = event.data.data();
    if (data.type !== "premium_request") return;

    const { user_email, user_name } = data;
    const db = getFirestore();

    // Get user UID from premium_users collection
    const premiumSnap = await db
      .collection("premium_users")
      .where("email", "==", user_email)
      .limit(1)
      .get();

    const uid = premiumSnap.empty ? "unknown" : premiumSnap.docs[0].id;
    const approveUrl = `https://pranikah.github.io`; // Admin buka app untuk approve

    const mailOptions = {
      from: `"PraNikah App" <${ADMIN_EMAIL}>`,
      to: ADMIN_EMAIL,
      subject: `[PraNikah] Premium Request: ${user_name || user_email}`,
      html: `
        <h2>🔔 New Premium Request</h2>
        <table>
          <tr><td><b>Nama:</b></td><td>${user_name || "-"}</td></tr>
          <tr><td><b>Email:</b></td><td>${user_email}</td></tr>
          <tr><td><b>UID:</b></td><td>${uid}</td></tr>
          <tr><td><b>Waktu:</b></td><td>${new Date().toLocaleString("id-ID")}</td></tr>
        </table>
        <br>
        <p>Buka Admin Panel untuk approve/reject:</p>
        <a href="${approveUrl}" style="background:#E91E63;color:white;padding:12px 24px;text-decoration:none;border-radius:8px;">
          Buka Admin Panel
        </a>
        <br><br>
        <small>Email otomatis dari PraNikah App</small>
      `,
    };

    try {
      const transporter = getTransporter();
      await transporter.sendMail(mailOptions);
      // Mark notification as sent
      await event.data.ref.update({ email_sent: true });
      console.log(`Email sent for premium request: ${user_email}`);
    } catch (error) {
      console.error("Error sending email:", error);
      await event.data.ref.update({ email_error: error.message });
    }
  }
);
