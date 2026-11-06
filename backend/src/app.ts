import express from "express";
import cors from "cors";
import healthRouter from "./routes/health.js";

const app = express();
app.use(express.json());
app.use(
  cors({
    origin: process.env.FRONTEND_URL,
  }),
);
app.use("/api/health", healthRouter);
export default app;
