from fastapi import FastAPI, HTTPException
from neo4j import GraphDatabase
from pydantic import BaseModel
from typing import Dict, List, Optional
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = FastAPI(title="Neo4j MCP Server")

# Neo4j configuration
NEO4J_URI = os.getenv("NEO4J_URI", "neo4j://neo4j:7687")
NEO4J_AUTH = os.getenv("NEO4J_AUTH", "none")

class Neo4jConnection:
    def __init__(self):
        self._driver = None

    def connect(self):
        if not self._driver:
            try:
                if NEO4J_AUTH == "none":
                    self._driver = GraphDatabase.driver(NEO4J_URI)
                else:
                    username = os.getenv("NEO4J_USERNAME", "neo4j")
                    password = os.getenv("NEO4J_PASSWORD", "password")
                    self._driver = GraphDatabase.driver(
                        NEO4J_URI,
                        auth=(username, password)
                    )
            except Exception as e:
                raise HTTPException(status_code=500, detail=f"Failed to connect to Neo4j: {str(e)}")

    def close(self):
        if self._driver:
            self._driver.close()
            self._driver = None

    def get_driver(self):
        if not self._driver:
            self.connect()
        return self._driver

neo4j_connection = Neo4jConnection()

@app.on_event("startup")
async def startup_event():
    neo4j_connection.connect()

@app.on_event("shutdown")
async def shutdown_event():
    neo4j_connection.close()

class QueryModel(BaseModel):
    query: str
    parameters: Optional[Dict] = {}

@app.post("/query")
async def execute_query(query_model: QueryModel):
    try:
        driver = neo4j_connection.get_driver()
        with driver.session() as session:
            result = session.run(query_model.query, query_model.parameters)
            return [dict(record) for record in result]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    try:
        driver = neo4j_connection.get_driver()
        with driver.session() as session:
            result = session.run("RETURN 1 as test")
            return {"status": "healthy", "neo4j_connected": bool(result.single())}
    except Exception as e:
        raise HTTPException(status_code=503, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 