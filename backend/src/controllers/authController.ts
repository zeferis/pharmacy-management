import type { Request, Response } from "express";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import pool from "../config/db.js";

export const login = async (req: Request, res: Response) => {
  const { username, password } = req.body ?? {};
  if (typeof username != "string" || typeof password != "string") {
    return res
      .status(400)
      .json({ message: "username and password must be string" });
  }
  if (!username.trim()||[...password].length < 8) {
    return res.status(400).json({ message: "invalid username or password" });
  }
  const result = await pool.query("SELECT * FROM users WHERE username=$1", [
    username,
  ]);
  if (!result.rowCount) {
    return res.status(401).json({ message: "Invalid username or password" });
  }
  const user = result.rows[0];
  if (!user || !user.is_active) {
    return res.status(401).json({
      message: "Invalid username or password",
    });
  }
  const isMatch = await bcrypt.compare(password, user.password_hash);
  if (!isMatch) {
    return res.status(401).json({ message: "Invalid username or password" });
  }
  const secret = process.env.JWT_SECRET;
  if (!secret) {
    throw new Error("JWT_SECRET is not configured");
  }
  const token = jwt.sign(
    {
      userId: user.id,
    },
    secret,
    { expiresIn: "1h" },
  );
  return res.status(200).json({
    message: "login successful",
    token,
    user: {
      id: user.id,
      username: user.username,
      role: user.role,
      fullname: user.full_name,
    },
  });
};
