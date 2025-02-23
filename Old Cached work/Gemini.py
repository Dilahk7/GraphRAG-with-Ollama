#!/usr/bin/env python
from langchain_core.runnables import RunnablePassthrough
from langchain_core.prompts import ChatPromptTemplate
from pydantic import BaseModel, Field
from langchain_core.output_parsers import StrOutputParser, JsonOutputParser
from langchain_neo4j import Neo4jGraph
from langchain.text_splitter import RecursiveCharacterTextSplitter
# from langchain_community.chat_models import ChatOllama
from langchain_ollama import ChatOllama
from langchain_experimental.graph_transformers import LLMGraphTransformer
from neo4j import GraphDatabase
from yfiles_jupyter_graphs import GraphWidget
from langchain_community.vectorstores import Neo4jVector
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores.neo4j_vector import remove_lucene_chars
from langchain_community.embeddings import OllamaEmbeddings
import os
from langchain_experimental.llms.ollama_functions import OllamaFunctions
from neo4j import  Driver
from tqdm import tqdm
import google.generativeai as genai
from langchain_google_genai import ChatGoogleGenerativeAI, GoogleGenerativeAIEmbeddings
from dotenv import load_dotenv
from custom_graph_transformer import CustomGraphTransformer

from dotenv import load_dotenv
load_dotenv()

# Configure Gemini
genai.configure(api_key=os.environ["GOOGLE_API_KEY"])

generation_config = {
    "temperature": 0,
    "top_p": 0.95,
    "top_k": 40,
    "max_output_tokens": 8192,
}

# Initialize the Gemini model through LangChain
llm = ChatGoogleGenerativeAI(
    model="gemini-pro",  # Using gemini-pro instead of flash for better stability
    generation_config=generation_config,
    convert_system_message_to_human=False  # Don't convert system messages
)

def setup_neo4j_connection():
    """Setup Neo4j connection with proper error handling"""
    try:
        uri = os.getenv("NEO4J_URI", "bolt://localhost:7687")
        username = os.getenv("NEO4J_USERNAME", "")
        password = os.getenv("NEO4J_PASSWORD", "")
        
        # Initialize Neo4j graph
        graph = Neo4jGraph(
            url=uri,
            username=username,
            password=password,
            database="neo4j"
        )
        return graph
    except Exception as e:
        print(f"Error connecting to Neo4j: {e}")
        raise

graph = setup_neo4j_connection()

# Load and split documents
loader = TextLoader(file_path="/Users/khalid.najam/Obsidian/Documentation/Modules/Non CTC Claim.md")
docs = loader.load()

text_splitter = RecursiveCharacterTextSplitter(chunk_size=250, chunk_overlap=24)
documents = text_splitter.split_documents(documents=docs)

# Initialize our custom graph transformer
graph_transformer = CustomGraphTransformer(llm=llm)

# Add diagnostic info
print("\nDiagnostic Information:")
print("-" * 50)

# Check entity nodes
entity_count = graph.query(
    """
    MATCH (n:__Entity__)
    RETURN count(n) as count
    """
)
print(f"Entity nodes found: {entity_count[0]['count'] if entity_count else 0}")

# Check relationships
rel_count = graph.query(
    """
    MATCH ()-[r]-() 
    RETURN type(r) as type, count(r) as count
    """
)
print("\nRelationship types:")
for rel in rel_count:
    print(f"- {rel['type']}: {rel['count']}")

# Check fulltext index
index_info = graph.query(
    """
    SHOW INDEXES
    YIELD name, type, labelsOrTypes, properties
    WHERE name = 'fulltext_entity_id'
    """
)
print("\nFulltext index status:")
if index_info:
    print("Index found with configuration:")
    for idx in index_info:
        print(f"- Labels: {idx['labelsOrTypes']}")
        print(f"- Properties: {idx['properties']}")
else:
    print("Warning: Fulltext index not found!")

print("-" * 50)

# Check if documents already exist in Neo4j
existing_docs = graph.query(
    """
    MATCH (d:Document) 
    RETURN count(d) as doc_count
    """
)
doc_count = existing_docs[0]["doc_count"]

if doc_count == 0:
    print("Converting documents to graph format")
    graph_documents = []
    for doc in tqdm(documents, desc="Processing documents"):
        graph_doc = graph_transformer.convert_to_graph_documents([doc])
        graph_documents.extend(graph_doc)

    if len(graph_documents) > 0:
        print(f"Processing {len(graph_documents)} documents into Neo4j")
        graph.add_graph_documents(
            graph_documents,
            baseEntityLabel=True,
            include_source=True
        )
        # Verify documents were added
        verification = graph.query(
            """
            MATCH (n)
            RETURN DISTINCT labels(n) as labels, count(n) as count
            """
        )
        print("\nVerification of added nodes:")
        for result in verification:
            print(f"Node type {result['labels']}: {result['count']} nodes")
    else:
        print("No documents were processed into graph format")
else:
    print(f"Found {doc_count} documents already in Neo4j, skipping conversion")

# Initialize embeddings with Google's text-embedding-001 model
embeddings = GoogleGenerativeAIEmbeddings(
    model="models/embedding-001",
    google_api_key=os.environ["GOOGLE_API_KEY"]
)

# Use consistent Neo4j credentials
username = os.getenv("NEO4J_USERNAME", "")
password = os.getenv("NEO4J_PASSWORD", "")

vector_index = Neo4jVector.from_existing_graph(
    embeddings,
    url=os.getenv("NEO4J_URI", "bolt://localhost:7687"),
    username=username,
    password=password,
    search_type="hybrid",
    node_label="Document",
    text_node_properties=["text"],
    embedding_node_property="embedding",
    database="neo4j"
)
vector_retriever = vector_index.as_retriever()

# Create Neo4j driver with consistent auth
driver = GraphDatabase.driver(
    uri=os.environ["NEO4J_URI"],
    auth=(username, password) if username and password else None
)

def create_fulltext_index(tx):
    query = '''
    CREATE FULLTEXT INDEX `fulltext_entity_id` 
    FOR (n:__Entity__) 
    ON EACH [n.id];
    '''
    tx.run(query)

# Function to execute the query
def create_index():
    with driver.session() as session:
        session.execute_write(create_fulltext_index)
        print("Fulltext index created successfully.")

# Call the function to create the index
try:
    create_index()
except Exception as e:
    print(f"Note: Could not create index (may already exist): {e}")

# Close the driver connection
driver.close()

class Entities(BaseModel):
    """Identifying information about entities."""
    names: list[str] = Field(
        ...,
        description="All the person, organization, or business entities that appear in the text"
    )

entity_prompt = ChatPromptTemplate.from_messages([
    (
        "system",
        """You are an entity extractor that breaks down text into individual entities.
        You must ONLY return a JSON object with a 'names' array containing strings.
        DO NOT include any explanations or additional text.
        ONLY return the JSON object.
        
        Example input: "eligibility amount"
        Example output: {{"names": ["eligibility", "amount"]}}
        
        Example input: "reimbursement process"
        Example output: {{"names": ["reimbursement", "process"]}}
        
        Always split compound terms into separate entities.
        Remember: Return ONLY the JSON object, no other text."""
    ),
    (
        "human",
        "Extract entities from the following text: {question}"
    ),
])

parser = JsonOutputParser(pydantic_object=Entities)
entity_chain = entity_prompt | llm | parser

def graph_retriever(question: str) -> str:
    """Collects the neighborhood of entities mentioned in the question"""
    result = ""
    try:
        entities = entity_chain.invoke({"question": question})
        for entity in entities['names']:
            # First try to find exact matches
            response = graph.query(
                """
                CALL db.index.fulltext.queryNodes('fulltext_entity_id', $query)
                YIELD node, score
                WITH node, score
                WHERE score > 0.5
                MATCH (node)-[r]-(neighbor)
                RETURN 
                    node.id + ' - ' + type(r) + ' -> ' + neighbor.id AS output
                ORDER BY score DESC
                LIMIT 10
                """,
                {"query": entity},
            )
            
            if not response:  # If no exact matches, try fuzzy search
                response = graph.query(
                    """
                    CALL db.index.fulltext.queryNodes('fulltext_entity_id', $query + '~')
                    YIELD node, score
                    WITH node, score
                    WHERE score > 0.3
                    MATCH (node)-[r]-(neighbor)
                    RETURN 
                        node.id + ' - ' + type(r) + ' -> ' + neighbor.id AS output
                    ORDER BY score DESC
                    LIMIT 5
                    """,
                    {"query": entity},
                )
            
            result += "\n".join([el['output'] for el in response])
            if result:
                result += "\n"
    except Exception as e:
        print(f"Error in graph retriever: {e}")
        return ""
    
    return result.strip()

def generate_full_text_query(input: str) -> str:
    words = [el for el in remove_lucene_chars(input).split() if el]
    if not words:
        return ""
    full_text_query = " AND ".join([f"{word}~2" for word in words])
    print(f"Generated Query: {full_text_query}")
    return full_text_query.strip()

def full_retriever(question: str):
    graph_data = graph_retriever(question)
    vector_data = [el.page_content for el in vector_retriever.invoke(question)]
    
    # Format graph data
    graph_section = "Graph Relationships:\n" + ("-" * 50) + "\n"
    if graph_data.strip():
        graph_section += graph_data + "\n"
    else:
        graph_section += "No relevant graph relationships found.\n"
    
    # Format vector data
    vector_section = "\nRelevant Document Excerpts:\n" + ("-" * 50) + "\n"
    if vector_data:
        for i, text in enumerate(vector_data, 1):
            vector_section += f"{i}. {text.strip()}\n"
    else:
        vector_section += "No relevant documents found.\n"
    
    return graph_section + vector_section

template = """Answer the question based only on the following context:
{context}

Question: {question}
Use natural language and be concise.
Answer:"""
prompt = ChatPromptTemplate.from_template(template)

chain = (
    {
        "context": full_retriever,
        "question": RunnablePassthrough(),
    }
    | prompt
    | llm
    | StrOutputParser()
)

if __name__ == "__main__":
    print("Testing entity extraction...")
    result = entity_chain.invoke({"question": "Reimbursement"})
    print(f"Extracted entities: {result['names']}")

    # Test graph retriever
    print("\nTesting graph retriever...")
    graph_result = graph_retriever("what is reimbursement?")
    print("Graph retriever results:")
    print(graph_result if graph_result else "No graph results found")

    # Test vector retriever
    print("\nTesting vector retriever...")
    vector_result = vector_retriever.invoke("what is reimbursement?")
    print("Vector retriever results:")
    print([doc.page_content for doc in vector_result] if vector_result else "No vector results found")

    # Test the full chain
    print("\nTesting full chain...")
    chain_result = chain.invoke("Tell me how to configure eligibility amount?")
    print("Full chain results:")
    print(chain_result if chain_result else "No chain results found")


# In[59]:


def generate_full_text_query(input: str) -> str:
    words = [el for el in remove_lucene_chars(input).split() if el]
    if not words:
        return ""
    full_text_query = " AND ".join([f"{word}~2" for word in words])
    print(f"Generated Query: {full_text_query}")
    return full_text_query.strip()


# Fulltext index query
def full_retriever(question: str):
    graph_data = graph_retriever(question)
    vector_data = [el.page_content for el in vector_retriever.invoke(question)]
    
    # Format graph data
    graph_section = "Graph Relationships:\n" + ("-" * 50) + "\n"
    if graph_data.strip():
        graph_section += graph_data + "\n"
    else:
        graph_section += "No relevant graph relationships found.\n"
    
    # Format vector data
    vector_section = "\nRelevant Document Excerpts:\n" + ("-" * 50) + "\n"
    if vector_data:
        for i, text in enumerate(vector_data, 1):
            vector_section += f"{i}. {text.strip()}\n"
    else:
        vector_section += "No relevant documents found.\n"
    
    return graph_section + vector_section


# In[62]:


template = """Answer the question based only on the following context:
{context}

Question: {question}
Use natural language and be concise.
Answer:"""
prompt = ChatPromptTemplate.from_template(template)

chain = (
        {
            "context": full_retriever,
            "question": RunnablePassthrough(),
        }
    | prompt
    | llm
    | StrOutputParser()
)


# In[63]:


chain.invoke(input="What are the various ways eligibility amount can be shown on UI?")


# In[ ]:




