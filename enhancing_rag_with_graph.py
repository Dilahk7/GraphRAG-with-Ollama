# In[68]:


from langchain_core.runnables import  RunnablePassthrough
from langchain_core.prompts import ChatPromptTemplate
from pydantic import BaseModel, Field
from langchain_core.output_parsers import StrOutputParser
from langchain_community.graphs import Neo4jGraph
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.chat_models import ChatOllama
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

from dotenv import load_dotenv

load_dotenv()


# In[3]:


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


# In[4]:


loader = TextLoader(file_path="Non CTC Claim.md")
docs = loader.load()

text_splitter = RecursiveCharacterTextSplitter(chunk_size=250, chunk_overlap=24)
documents = text_splitter.split_documents(documents=docs)


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



# In[83]:


llm = OllamaFunctions(model="llama3.1:8b", temperature=0, format="json", verbose=True)


llm_transformer = LLMGraphTransformer(
    llm=llm,
    prompt=graph_prompt
)


# In[88]:


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

# In[90]:


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


# In[92]:


embeddings = OllamaEmbeddings(
    model="nomic-embed-text",
)

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


# In[103]:


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


# In[94]:


class Entities(BaseModel):
    """Identifying information about entities related to business expenses and reimbursement systems."""

    names: list[str] = Field(
        ...,
        description="All business modules, database tables, UI components, and system entities that "
        "appear in the text. Includes tables like HrEmployeeReimbursement, BreAdminConfig, "
        "HrExpenseCategory, HrConveyanceRate; UI components like ReimbursementClaim.xhtml, "
        "CommonModalPanel.xhtml; and system concepts like CTC Claim, Non-CTC Claim, "
        "EligibilityAmount, Drools configuration, BRE Admin configuration",
    )

prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are extracting technical and business entities related to reimbursement systems from the text. "
            "Focus on: "
            "- Database tables (e.g. HrEmployeeReimbursement, BreAdminConfigDetails) "
            "- UI components (e.g. ReimbursementClaimStatus.xhtml) "
            "- Business concepts (e.g. CTC Claim, Per Transaction eligibility) "
            "- System components (e.g. Drools, BRE Admin)",
        ),
        (
            "human",
            "Use the given format to extract information from the following "
            "input: {question}",
        ),
    ]
)


entity_chain = llm.with_structured_output(Entities)


# In[95]:


entity_chain.invoke("Who are Nonna Lucia and Giovanni Caruso?")


# In[96]:


def generate_full_text_query(input: str) -> str:
    words = [el for el in remove_lucene_chars(input).split() if el]
    if not words:
        return ""
    full_text_query = " AND ".join([f"{word}~2" for word in words])
    print(f"Generated Query: {full_text_query}")
    return full_text_query.strip()


# Fulltext index query
def graph_retriever(question: str) -> str:
    """
    Collects the neighborhood of entities mentioned in the question by:
    1. Finding relevant entities using fulltext search
    2. Traversing their relationships in both directions (up to depth 2)
    3. Aggregating and formatting the results
    """
    try:
        # First ensure entities are properly labeled
        graph.query(
            """
            // Add __Entity__ label to all nodes that should be searchable
            MATCH (n) 
            WHERE (n:Class OR n:Table OR n:Process OR n:SystemComponent OR 
                  n:Configuration OR n:BusinessRule OR n:Section)
                AND NOT n:__Entity__
            SET n:__Entity__
            SET n.id = CASE 
                WHEN n.name IS NOT NULL THEN n.name 
                WHEN n.title IS NOT NULL THEN n.title
                ELSE coalesce(n.id, 'unnamed_entity')
            END
            RETURN count(n) as labeled_count
            """
        )
        
        result = []
        entities = entity_chain.invoke(question)
        
        # First try to get a list of all relevant entities
        entity_list = graph.query(
            """
            MATCH (n:__Entity__)
            RETURN n.id as id, labels(n) as labels
            """
        )
        
        # Helper function to score entity relevance
        def score_entity(entity_id, query):
            query_terms = set(query.lower().split())
            entity_terms = set(entity_id.lower().split())
            
            # Direct match
            if entity_id.lower() == query.lower():
                return 1.0
            
            # All terms match
            if all(term in entity_id.lower() for term in query_terms):
                return 0.9
                
            # Some terms match
            matching_terms = len(query_terms.intersection(entity_terms))
            if matching_terms > 0:
                return 0.5 + (0.4 * matching_terms / len(query_terms))
                
            return 0.0
        
        for entity in entities.names:
            # Score and filter relevant entities
            relevant_entities = [
                e['id'] for e in entity_list 
                if score_entity(e['id'], entity) > 0.5
            ]
            
            if not relevant_entities:
                continue
                
            # Query relationships for relevant entities
            response = graph.query(
                """
                MATCH (start:__Entity__)
                WHERE start.id IN $entities
                
                // Find direct relationships in both directions
                OPTIONAL MATCH (start)-[r1]->(target1:__Entity__)
                WHERE type(r1) IN [
                    'INCLUDES_TABLE', 'INCLUDES_CLASS', 'USES_CONFIGURATION',
                    'IMPLEMENTED_BY', 'CONFIGURES', 'HAS_DATA', 'CONTAINS',
                    'ENFORCES', 'MANAGES', 'REQUIRES', 'IMPLEMENTS'
                ]
                WITH start, collect({
                    source: start.id,
                    target: target1.id,
                    type: type(r1),
                    outgoing: true
                }) as outgoing
                
                OPTIONAL MATCH (start)<-[r2]-(target2:__Entity__)
                WHERE type(r2) IN [
                    'INCLUDES_TABLE', 'INCLUDES_CLASS', 'USES_CONFIGURATION',
                    'IMPLEMENTED_BY', 'CONFIGURES', 'HAS_DATA', 'CONTAINS',
                    'ENFORCES', 'MANAGES', 'REQUIRES', 'IMPLEMENTS'
                ]
                WITH start, outgoing, collect({
                    source: target2.id,
                    target: start.id,
                    type: type(r2),
                    outgoing: false
                }) as incoming
                
                // Combine and format relationships
                WITH outgoing + incoming as rels
                UNWIND rels as rel
                WITH rel
                WHERE rel.target IS NOT NULL
                RETURN DISTINCT 
                    rel.source + ' -[' + rel.type + ']-> ' + rel.target as output
                ORDER BY output
                LIMIT 25
                """,
                {"entities": relevant_entities}
            )
            
            # Add results to our collection
            result.extend([el['output'] for el in response])
        
        # Return unique relationships, joined by newlines
        return "\n".join(list(set(result))) if result else "No relevant relationships found."
        
    except Exception as e:
        print(f"Error in graph retriever: {str(e)}")
        return "Error retrieving graph relationships."


# In[97]:


print(graph_retriever('What configuration tables are used in the system?'))


# In[99]:


def full_retriever(question: str):
    graph_data = graph_retriever(question)
    vector_data = [el.page_content for el in vector_retriever.invoke(question)]
    final_data = f"""Graph data:
{graph_data}
vector data:
{"#Document ". join(vector_data)}
    """
    return final_data


# In[100]:
print('===Full Retriever===')
print(full_retriever('What configuration tables are used in the system?'))



template = """Answer questions about non-CTC claims and reimbursements using the following context:
{context}

For reimbursement-related questions, ensure:
1. Verify expense category matches HrExpenseCategory records
2. Check eligibility amounts against BreAdminConfig rules
3. Confirm required attachments are present per HrEmployeeAttachments
4. Validate approval workflow steps with HrEmpReimbursementApprovalHistory
5. Reference cost center mappings from HrCostCentre where applicable

Question: {question}
Provide a structured response:
1. Summary of key factors
2. Step-by-step verification process
3. Relevant database tables/configuration used
4. Module-specific implementation details
5. Escalation path for discrepancies

Format numerical answers as: 
"Calculation: [Formula] = [Value1] [Operator] [Value2] = [Result]"

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


# In[101]:
print('===Chain===')
question = "What is BreAdminConfig?"
print(question)
print(chain.invoke(input=question))

# %%
