from typing import List, Dict, Any
from pydantic import BaseModel, Field
from langchain_core.documents import Document
from langchain_core.messages import SystemMessage, HumanMessage

class GraphNode(BaseModel):
    """A node in the graph with its properties."""
    id: str = Field(description="Unique identifier for the node")
    type: str = Field(description="Type/label of the node")
    properties: Dict[str, Any] = Field(default_factory=dict, description="Properties of the node")

class GraphRelationship(BaseModel):
    """A relationship between two nodes in the graph."""
    source: str = Field(description="ID of the source node")
    target: str = Field(description="ID of the target node")
    type: str = Field(description="Type/label of the relationship")
    properties: Dict[str, Any] = Field(default_factory=dict, description="Properties of the relationship")

class GraphDocument(BaseModel):
    """A document represented as a graph with nodes and relationships."""
    nodes: List[GraphNode] = Field(default_factory=list, description="List of nodes in the graph")
    relationships: List[GraphRelationship] = Field(default_factory=list, description="List of relationships between nodes")

class CustomGraphTransformer:
    """A custom graph transformer that works with Gemini's function calling capabilities."""
    def __init__(self, llm):
        """Initialize the transformer with an LLM."""
        self.llm = llm

    def convert_to_graph_documents(self, documents: List[Document]) -> List[GraphDocument]:
        """Convert documents to graph format using the LLM."""
        graph_documents = []
        
        for doc in documents:
            try:
                # Create a combined prompt that includes both system and user messages
                prompt = f"""You are a domain expert in HR reimbursement systems.
Extract entities and relationships from the documentation with these guidelines:

1. Core Entities to Always Identify:
- Modules (Non-CTC Claim, FBP Claim)
- UI Components (ReimbursementClaim, CommonModalPanel)
- Database Tables (HrEmployeeReimbursement, HrExpenseCategory)
- Workflow Stages (Submission, L1 Approval, Payment Processing)
- Configuration Elements (EligibilityAmount, BreAdminConfig)
- Organizational Concepts (CostCenter, HrOrgUnitType)

2. Relationship Priorities:
- Module <> UI Component (HAS_INTERFACE)
- Table <> Table (RELATED_TO via foreign keys)
- Workflow Stage <> Required Approval (REQUIRES_APPROVAL)
- Configuration <> Table (GOVERNS)
- Entity <> Parent Module (BELONGS_TO)
- Compound Terms -> Split and relate (e.g., "eligibility amount" -> Eligibility -[RELATED_TO]-> Amount)

3. Special Handling:
- Treat numbered lists as sequence relationships
- Capture hierarchy in org units (Company > SBU > Business Unit)
- Split hyphenated terms but maintain relations (non-CTC -> Non -[HYPHENATED]-> CTC)
- Preserve case sensitivity for table/class names

Extract entities and relationships from the following text:

{doc.page_content}"""

                # Call the LLM with structured output
                result = self.llm.with_structured_output(GraphDocument).invoke(prompt)

                # Add source document metadata
                for node in result.nodes:
                    node.properties["source"] = doc.metadata.get("source", "")
                
                graph_documents.append(result)

            except Exception as e:
                print(f"Error processing document: {e}")
                continue

        return graph_documents 