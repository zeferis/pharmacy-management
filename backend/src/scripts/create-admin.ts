import "dotenv/config";
import bcrypt from "bcrypt";
import pool from "../config/db.js";

const createAdmin = async () => {
  try {
    const username = process.env.ADMIN_USERNAME?.trim().toLowerCase();
    const password = process.env.ADMIN_PASSWORD;
    const fullname = process.env.ADMIN_FULL_NAME?.trim();
    if (!username || !password || !fullname) {
      throw new Error("missing information");
    }
    if ([...password].length < 8) {
      throw new Error("Password must contain at least 8 characters");
    }

    if (!/\p{L}/u.test(password)) {
      throw new Error("Password must contain at least one letter");
    }

    if (!/[0-9]/.test(password)) {
      throw new Error("Password must contain at least one number");
    }

    if (!/[\p{P}\p{S}]/u.test(password)) {
      throw new Error("Password must contain at least one special character");
    }

    if (Buffer.byteLength(password, "utf8") > 72) {
      throw new Error("Password must not exceed 72 bytes when using bcrypt");
    }
    const passwordHash = await bcrypt.hash(password, 12);
    const result = await pool.query(
      "INSERT INTO users(username,password_hash,full_name,role) VALUES ($1,$2,$3,'manager') ON CONFLICT (username) DO NOTHING RETURNING id,username,full_name,role",
      [username, passwordHash, fullname],
    );
    if (!result.rowCount) {
      console.error("username have been registered before");
      return;
    }
    console.log("Admin created successfully:", result.rows[0]);
  } catch (err) {
    console.error("cannot create manager account:", err);
    process.exitCode = 1;
  } finally {
    await pool.end();
  }
};
createAdmin();
