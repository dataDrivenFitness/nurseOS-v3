
# rag_context_server.py

import os
from fastapi import FastAPI, Query
from fastapi.responses import JSONResponse
from txtai.embeddings import Embeddings
from pathlib import Path
import markdown
import uvicorn

app = FastAPI()
index = Embeddings({"path": "sentence-transformers/all-MiniLM-L6-v2"})
DOCS_PATH = Path("docs")

@app.on_event("startup")
def load_index():
    if not index.exists("index"):
        print("🔍 Indexing markdown files...")
        files = list(DOCS_PATH.rglob("*.md"))
        data = []
        for file in files:
            with open(file, "r", encoding="utf-8") as f:
                text = f.read()
                clean_text = markdown.markdown(text)
                data.append((str(file), clean_text))
        index.index([(uid, text, None) for uid, text in data])
        index.save("index")
    else:
        index.load("index")
        print("✅ Loaded existing index")

@app.get("/search")
def search_docs(query: str = Query(...), k: int = 3):
    results = index.search(query, k)
    output = []
    for r in results:
        file_path = r[0]
        score = r[1]
        content = Path(file_path).read_text(encoding="utf-8")
        output.append({
            "file": file_path,
            "score": score,
            "content": content
        })
    return JSONResponse(content={"matches": output})

if __name__ == "__main__":
    uvicorn.run("rag_context_server:app", host="0.0.0.0", port=8010, reload=True)
