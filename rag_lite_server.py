
# rag_lite_server.py

from fastapi import FastAPI, Query
from fastapi.responses import JSONResponse
from pathlib import Path
from typing import List
import uvicorn
import markdown
import numpy as np
from sentence_transformers import SentenceTransformer
import os

app = FastAPI()
DOCS_PATH = Path("docs")
model = SentenceTransformer("all-MiniLM-L6-v2")

documents = []
vectors = []
paths = []

def load_docs():
    global documents, vectors, paths
    print("🔍 Indexing markdown files...")
    for file in DOCS_PATH.rglob("*.md"):
        text = file.read_text(encoding="utf-8")
        text_clean = markdown.markdown(text)
        embedding = model.encode(text_clean, convert_to_numpy=True)
        documents.append(text)
        vectors.append(embedding)
        paths.append(str(file))
    print(f"✅ Indexed {len(documents)} files.")

def cosine_similarity(a, b):
    a = a / np.linalg.norm(a)
    b = b / np.linalg.norm(b)
    return np.dot(a, b)

@app.on_event("startup")
def startup_event():
    load_docs()

@app.get("/search")
def search(query: str = Query(...), k: int = 3):
    qvec = model.encode(query, convert_to_numpy=True)
    scored = [(cosine_similarity(qvec, vec), i) for i, vec in enumerate(vectors)]
    top_matches = sorted(scored, key=lambda x: x[0], reverse=True)[:k]

    results = []
    for score, idx in top_matches:
        results.append({
            "file": paths[idx],
            "score": float(score),
            "content": documents[idx]
        })

    return JSONResponse(content={"matches": results})

if __name__ == "__main__":
    uvicorn.run("rag_lite_server:app", host="0.0.0.0", port=8010, reload=True)
