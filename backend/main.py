import os

import uvicorn


def main() -> None:
    uvicorn.run(
        "backend.api.server:app",
        host=os.environ.get("HOST", "0.0.0.0"),
        port=int(os.environ.get("PORT", "8000")),
        reload=os.environ.get("RELOAD", "").lower() == "true",
    )


if __name__ == "__main__":
    main()
