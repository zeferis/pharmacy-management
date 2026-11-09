import type { Request, Response, NextFunction } from "express";

const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  if (res.headersSent) {
    next(err);
    return;
  }
  console.error(err);
  return res.status(500).json({ message: "Serve Error" });
};
export default errorHandler;
