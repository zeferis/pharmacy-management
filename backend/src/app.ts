import express from "express";
import cors from "cors";
import authRouter from "./routes/authRoutes.js"
import errorHandler from "./middleware/errorHandler.js";
const app = express();
app.use(express.json());
app.use(
  cors({
    origin: process.env.FRONTEND_URL,
  }),
);
app.use("/api/auth",authRouter);
app.use(errorHandler);
export default app;
