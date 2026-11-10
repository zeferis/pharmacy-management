import type { ErrorRequestHandler } from "express";

const errorHandler: ErrorRequestHandler = (err, _req, res, next) => {
  if (res.headersSent) {
    next(err);
    return;
  }

  if (
    err instanceof SyntaxError &&
    "type" in err &&
    err.type === "entity.parse.failed"
  ) {
    res.status(400).json({
      message: "Invalid JSON body",
    });
    return;
  }

  console.error("Request failed:", err);

  res.status(500).json({
    message: "Internal server error",
  });
};

export default errorHandler;
