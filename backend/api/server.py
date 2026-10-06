from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def read_root():
    return {"message": "Welcome to the Anvesha Project API!"}

@app.get("/status")
async def read_status():
    pass
