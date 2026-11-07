import "dotenv/config";
import app from "./app.js";
import pool from "./config/db.js";
const port = Number(process.env.PORT);
if (!Number.isInteger(port) || port < 1 || port > 65535) {
  throw new Error("PORT phải là số nguyên từ 1 đến 65535");
}
const startServer = async () => {
  try {
    await pool.query("SELECT 1");
    console.log("Connected to PostgreSQL");
    app.listen(port, () => {
      console.log(`Server running at http://localhost:${port}`);
    });
  } catch (err) {
    console.error("Không thể kết nối PostgreSQL:", err);
    await pool.end();
    process.exitCode = 1;
  }
};
startServer();
