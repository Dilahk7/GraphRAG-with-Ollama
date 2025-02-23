#!/usr/bin/env python
from langchain_core.runnables import RunnablePassthrough
from langchain_core.prompts import ChatPromptTemplate
from pydantic import BaseModel, Field
from langchain_core.output_parsers import StrOutputParser, JsonOutputParser
from langchain_neo4j import Neo4jGraph
from langchain.text_splitter import RecursiveCharacterTextSplitter, MarkdownHeaderTextSplitter
# from langchain_community.chat_models import ChatOllama
from langchain_ollama import ChatOllama
from langchain_experimental.graph_transformers import LLMGraphTransformer
from neo4j import GraphDatabase
from yfiles_jupyter_graphs import GraphWidget
from langchain_community.vectorstores import Neo4jVector
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores.neo4j_vector import remove_lucene_chars
from langchain_ollama import OllamaEmbeddings
import os
from langchain_experimental.llms.ollama_functions import OllamaFunctions
from neo4j import  Driver
from tqdm import tqdm
from llama_index.core.node_parser import MarkdownElementNodeParser
from markdown import markdown
from bs4 import BeautifulSoup
from markdown_it import MarkdownIt

from dotenv import load_dotenv
load_dotenv()

# Initialize Neo4j graph with the new package

def setup_neo4j_connection():
    """Setup Neo4j connection with proper error handling"""
    try:
        uri = os.getenv("NEO4J_URI", "bolt://localhost:7687")
        # Initialize Neo4j graph - using no auth for local development
        graph = Neo4jGraph(
            url=uri,
            username="",
            password="",
            database="neo4j"
        )
        return graph
    except Exception as e:
        print(f"Error connecting to Neo4j: {e}")
        raise

graph = setup_neo4j_connection()

def load_and_parse_markdown(file_path: str):
    """Use LangChain's built-in markdown splitter"""
    headers_to_split_on = [
        ("#", "Header 1"),
        ("##", "Header 2"), 
        ("###", "Header 3"),
    ]
    
    with open(file_path, 'r') as f:
        md_text = f.read()
    
    splitter = MarkdownHeaderTextSplitter(
        headers_to_split_on=headers_to_split_on
    )
    return splitter.split_text(md_text)

loader = load_and_parse_markdown("/Users/khalid.najam/Obsidian/Documentation/Modules/Non CTC Claim.md")
documents = loader  # Remove text splitter since MarkdownNodeParser handles chunking

# After text splitter section, add print statements
print(f"\n=== Document Loading Statistics ===")
print(f"Number of documents loaded: {len(documents)}")
print(f"Average chunk size: {sum(len(doc.page_content) for doc in documents) / len(documents):.0f} characters")

# Before graph processing
print("\n=== Starting Graph Processing ===")
print("Initializing LLM and graph transformer...")

llm = ChatOllama(model="llama3.1:8b", temperature=0, format="json")
# llm = ChatOllama(model="nezahatkorkmaz/deepseek-v3", temperature=0)
# llm = ChatOllama(model="llama3.1:70b", temperature=0, format="json")
# llm = ChatOllama(model="deepseek-r1:14b", temperature=0)

# llama3.1:70b
# nezahatkorkmaz/deepseek-v3

graph_prompt = ChatPromptTemplate.from_messages([
    ("system", """You are a domain expert in HR reimbursement systems. 
Extract entities and relationships from the documentation with these guidelines:

1. Core Entities to Always Identify:
- Modules (Non-CTC Claim, FBP Claim)
- UI Components (ReimbursementClaim, CommonModalPanel)
- Database Tables (HrEmployeeReimbursement, HrExpenseCategory)
- Workflow Stages (Submission, L1 Approval, Payment Processing)
- Configuration Elements (EligibilityAmount, BreAdminConfig)
- Organizational Concepts (CostCenter, HrOrgUnitType)

2. Relationship Priorities:
- Relationships can be easily identified from [[]] in the document. [[]] creates a link.
- Module <> UI Component (HAS_INTERFACE)
- Table <> Table (RELATED_TO via foreign keys)
- Workflow Stage <> Required Approval (REQUIRES_APPROVAL)
- Configuration <> Table (GOVERNS)
- Entity <> Parent Module (BELONGS_TO)
- Compound Terms -> Split and relate (e.g., "eligibility amount" -> Eligibility -[RELATED_TO]-> Amount)
- Never form relationships of type "MENTIONS", always create meaningful relationships based on the context.

3. Output Format:
{{
  "nodes": [
    {{"id": "HrExpenseHead", "type": "DatabaseTable", "properties": {{"description": "Stores all the expense heads"}}}},
    {{"id": "Eligibility", "type": "ConfigurationElement", "properties": {{"description": "Stores the eligibility amount"}}}},
    {{"id": "HrExpenseCategory", "type": "DatabaseTable", "properties": {{"description": "Stores all the expense categories"}}}},
    {{"id": "BreAdminConfig", "type": "Configuration", "properties": {{"description": "Stores the bre admin config"}}}},
    {{"id": "HrEmployeeReimbursement", "type": "DatabaseTable", "properties": {{"description": "Stores all the reimbursement records"}}}},
    {{"id": "HrExpenseCategory", "type": "DatabaseTable", "properties": {{"description": "Stores all the expense categories"}}}},
  ],
  "relationships": [
    {{"source": "HrExpenseHead", "target": "HrExpenseCategory", "type": "SUBCATEGORY_OF"}},
    {{"source": "BreAdminConfig", "target": "Eligibility", "type": "GOVERNANCE"}}
    {{"source": "HrExpenseCategory", "target": "HrExpenseHead", "type": "SUBCATEGORY_OF"}}
    {{"source": "HrEmployeeReimbursement", "target": "HrExpenseCategory", "type": "HAS_EXPENSE_CATEGORY"}}
  ]
}}"""),
    ("human", "{input}")
])

llm_transformer = LLMGraphTransformer(
    llm=llm,
    prompt=graph_prompt
    # allowed_nodes=["Module", "UIComponent", "DatabaseTable", "WorkflowStage", 
    #               "Configuration", "OrganizationalUnit", "Form", "Attachment",
    #               "PaymentStage", "CalculationFormula", "ApprovalLevel"],
    # allowed_relationships=[
    #     # Module architecture
    #     "HAS_SUBMENU", "HAS_INTERFACE", "REPLACES_LEGACY",
        
    #     # Database relationships
    #     "SUBCATEGORY_OF", "HAS_ATTACHMENT", "STORES_CONFIG",
        
    #     # Workflow connections
    #     "REQUIRES_APPROVAL_LEVEL", "HAS_PAYMENT_STAGE", "HAS_PROXY_APPROVAL",
        
    #     # Configuration logic
    #     "GOVERNS_ELIGIBILITY", "DEFINES_CALCULATION", "HAS_FREQUENCY",
    #     "HAS_CALCULATION_METHOD", "HAS_PARAMETER_GROUP",
        
    #     # UI relationships
    #     "HAS_FORM_COMPONENT", "VALIDATES_VIA_SECURITY",
        
    #     # Specialized connections
    #     "MAPPED_VIA_ORGUNIT", "GENERATES_REPORT", "HAS_CLAIM_LIFECYCLE",
    #     "USED_IN_CALCULATION"
    # ]
)
from tqdm import tqdm

# Check if documents already exist in Neo4j
existing_docs = graph.query(
    """
    MATCH (d:Document) 
    RETURN count(d) as doc_count
    """
)
doc_count = existing_docs[0]["doc_count"]

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

# Modify the document processing section
if doc_count == 0:
    print("\n=== Document to Graph Conversion ===")
    print(f"Starting conversion of {len(documents)} documents to graph format")
    graph_documents = []
    
    for i, doc in enumerate(tqdm(documents, desc="Processing documents")):
        print(f"\nProcessing document chunk {i+1}/{len(documents)}")
        print(f"Chunk size: {len(doc.page_content)} characters")
        try:
            graph_doc = llm_transformer.convert_to_graph_documents([doc])
            print(f"Extracted {len(graph_doc)} graph documents")
            print("\nGraph Document Contents:")
            for gdoc in graph_doc:
                print("\nNodes:")
                for node in gdoc.nodes:
                    print(f"- ID: {node.id}, Type: {node.type}")
                print("\nRelationships:") 
                for rel in gdoc.relationships:
                    print(f"- {rel.source.id} --[{rel.type}]--> {rel.target.id}")
            graph_documents.extend(graph_doc)
        except Exception as e:
            print(f"Error processing document chunk {i+1}: {str(e)}")
            continue

    if len(graph_documents) > 0:
        print(f"\n=== Neo4j Import Statistics ===")
        print(f"Attempting to import {len(graph_documents)} graph documents")
        
        try:
            graph.add_graph_documents(
                graph_documents,
                baseEntityLabel=True,
                include_source=False
            )
            
            # Verification queries
            verification = graph.query(
                """
                MATCH (n)
                RETURN DISTINCT labels(n) as labels, count(n) as count
                """
            )
            print("\nImported Node Statistics:")
            for result in verification:
                print(f"Node type {result['labels']}: {result['count']} nodes")
                
            # Count relationships
            rel_stats = graph.query(
                """
                MATCH ()-[r]->()
                RETURN type(r) as type, count(r) as count
                """
            )
            print("\nRelationship Statistics:")
            for rel in rel_stats:
                print(f"Relationship {rel['type']}: {rel['count']} connections")
                
        except Exception as e:
            print(f"Error during Neo4j import: {str(e)}")
    else:
        print("No documents were processed into graph format")
else:
    print(f"\n=== Existing Data Found ===")
    print(f"Found {doc_count} documents already in Neo4j")
    print("Skipping document conversion process")

# Add vector embedding progress tracking
print("\n=== Vector Embedding Process ===")
print("Initializing Ollama embeddings...")

embeddings = OllamaEmbeddings(
    model="mxbai-embed-large",
)

# Set environment variables for Neo4j connection
os.environ["NEO4J_USERNAME"] = "neo4j"  # Default username
os.environ["NEO4J_PASSWORD"] = "password"  # Default password


vector_index = Neo4jVector.from_existing_graph(
    embeddings,
    url=os.getenv("NEO4J_URI", "bolt://localhost:7687"),
    username="neo4j",  # Default username
    password="password",  # Default password
    search_type="hybrid",
    node_label="Document",
    text_node_properties=["text"],
    embedding_node_property="embedding",
    database="neo4j"
)
vector_retriever = vector_index.as_retriever()


# # In[29]:
# driver = GraphDatabase.driver(
#         uri = os.environ["NEO4J_URI"],
#         auth = (os.environ["NEO4J_USERNAME"],
#                 os.environ["NEO4J_PASSWORD"]))

# In[29]:
driver = GraphDatabase.driver(
        uri = os.environ["NEO4J_URI"],
        auth=None
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
except:
    pass

# Close the driver connection
driver.close()

# In[56]:


# Define entity chain first
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

# Define graph_retriever function
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

# In[57]:


entity_chain


# In[ ]:


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

# Add test section at the end
if __name__ == "__main__":
    print("\n=== Testing RAG System ===")
    
    test_queries = [
        "What is reimbursement?",
        "What are the various ways eligibility amount can be shown on UI?",
        "What is the difference between bre and ctc claim?"
    ]
    
    print("\nRunning test queries...")
    for query in test_queries:
        print(f"\nQuery: {query}")
        print("-" * 50)
        try:
            result = chain.invoke(query)
            print("Response:")
            print(result)
        except Exception as e:
            print(f"Error processing query: {str(e)}")
        print("-" * 50)


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




