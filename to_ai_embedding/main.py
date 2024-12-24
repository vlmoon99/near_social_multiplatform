from fastapi import FastAPI
from pydantic import BaseModel


from langchain.embeddings import HuggingFaceEmbeddings
from langchain.vectorstores import FAISS
from langchain.chains import RetrievalQA
from langchain.prompts import PromptTemplate

app = FastAPI()


class ParamsForCreateEmbeddings(BaseModel):
    user_query: str


@app.post("/createembeddings")
def CreateEmbeddings(new_params: ParamsForCreateEmbeddings):
    # Инициализируем объект для создания эмбеддингов
    embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")

    # Получаем эмбеддинг для текста
    embedding = embeddings.embed_query(new_params.user_query)

    print("Эмбеддинг для текста:", embedding)
