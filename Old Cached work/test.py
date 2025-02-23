Below is an example set of Cypher queries that "ingest" the Non‑CTC Claim document into a graph‐knowledge base. In these queries we:

• Create a top-level Document node for the Non‑CTC Claim article (using its title, YAML "aliases" and "tags" from the front‐matter, and a source reference).  
• Create several Section nodes (one per major section in the document: Introduction, UI and Menus, Form Security, Cost Centre, Related Classes, BRE Tables, Bre Admin Logic, Approval Workflow, Work Life – Submitting a Claim, and Diagrams/PlantUML).  
• Link the sections to the Document using a HAS_SECTION relationship.  
• Create nodes for the related "classes" (both Java and UI) found under "Related Classes" and link them to that section.  
• Create nodes for BRE Tables (both main and supporting) and attach them to the BRE Tables section.  
• Finally, create nodes for the various PlantUML diagrams (which represent system flows) and link them under the "Diagrams and PlantUML" section.

You can run the following queries one by one (or adjust as needed):

────────────────────────────
1. Create the top-level document node

CREATE (doc:Document {
  title: "Non CTC Claim",
  aliases: ["Business related expenses", "Business requirement expenses", "BER", "Business expenses related", "non-CTC-claim", "Reimbursement", "non ctc claim"],
  tags: ["module"],
  source: "Non CTC Claim.md"
});
────────────────────────────
2. Create Section nodes for each major section

CREATE (s1:Section { 
  title: "Introduction", 
  content: "All the expenses that an employee has made from his own pocket for smooth business facilitation qualify as business-related expenses. This section also outlines the primary differences between FBP Claim (CTC – claim) and Non-CTC Claim." 
});

CREATE (s2:Section { 
  title: "UI and Menus", 
  content: "Describes the application navigation and menus. For ESS there are two sub menus (New non-CTC claim and My claims) and for Manager Self Service there are four sub menus, including All Claims page, Configuration page, Reports page, and Proxy Reimbursement." 
});

CREATE (s3:Section { 
  title: "Form Security", 
  content: "Details the two forms (ReimbursementClaim and ReimbursementClaimDialogbox for ESS and additional ones for MSS) and their usage for initiating, saving, submitting, or re‐submitting claims." 
});

CREATE (s4:Section { 
  title: "Cost Centre", 
  content: "Explains what constitutes a cost centre, including the hierarchy (Company > SBU > Business Unit > Function > Sub-function > Project Code) and the mapping from HrOrgUnitType used for UI drop downs." 
});

CREATE (s5:Section { 
  title: "Related Classes", 
  content: "Lists and describes the Java and UI classes involved with Non‑CTC claim operations. For example, ReimburseMentClaimAction (JSF), ReimbursementClaimRestService (Mobile), and several UI XHML pages are included."
});

CREATE (s6:Section { 
  title: "BRE Tables", 
  content: "Documents the BRE-related tables including main BRE tables (e.g. HrEmployeeReimbursement, HrEmployeeReimbursementDetail, etc.), supporting tables (e.g. HrExpenseCategory, HrExpenseHead, HrConveyanceRate), and Drools configuration tables (BreAdminConfig and BreAdminConfigDetails)." 
});

CREATE (s7:Section { 
  title: "Bre Admin Logic", 
  content: "Covers the business logic in BRE Admin configuration. It describes how different employee attributes (DOJ, GDOJ, Age) are compared via configured rules to select the applicable configuration." 
});

CREATE (s8:Section { 
  title: "Approval Workflow", 
  content: "Describes the overall flow for claim approvals: from claim submission (by an employee) to verification/approval by L1/L2 managers and further processing by payroll SPOCs." 
});

CREATE (s9:Section { 
  title: "Work Life - Submitting a Claim", 
  content: "Explains the three entry points for submitting a claim via the Web (ReimburseMentClaimAction), Mobile (ReimbursementClaimRestService), and Outbound APIs (ReimbursementController)." 
});

CREATE (s10:Section { 
  title: "Diagrams and PlantUML", 
  content: "Contains several PlantUML diagrams that illustrate key processes (BRE tables relationships, claim submission flow, Bre Admin Logic, and approval workflow)." 
});
────────────────────────────
3. Link all Section nodes to the Document

MATCH (doc:Document {title:"Non CTC Claim"}),
      (s1:Section {title:"Introduction"}),
      (s2:Section {title:"UI and Menus"}),
      (s3:Section {title:"Form Security"}),
      (s4:Section {title:"Cost Centre"}),
      (s5:Section {title:"Related Classes"}),
      (s6:Section {title:"BRE Tables"}),
      (s7:Section {title:"Bre Admin Logic"}),
      (s8:Section {title:"Approval Workflow"}),
      (s9:Section {title:"Work Life - Submitting a Claim"}),
      (s10:Section {title:"Diagrams and PlantUML"})
CREATE (doc)-[:HAS_SECTION]->(s1),
       (doc)-[:HAS_SECTION]->(s2),
       (doc)-[:HAS_SECTION]->(s3),
       (doc)-[:HAS_SECTION]->(s4),
       (doc)-[:HAS_SECTION]->(s5),
       (doc)-[:HAS_SECTION]->(s6),
       (doc)-[:HAS_SECTION]->(s7),
       (doc)-[:HAS_SECTION]->(s8),
       (doc)-[:HAS_SECTION]->(s9),
       (doc)-[:HAS_SECTION]->(s10);
────────────────────────────
4. Create nodes for the related classes (Java and UI)

-- Java Classes
CREATE (jc1:Class {name:"ReimburseMentClaimAction", context:"Web", purpose:"Employee submitting a new claim"});
CREATE (jc2:Class {name:"ReimbursementClaimRestService", context:"Mobile", purpose:"Employee submitting a new claim"});
CREATE (jc3:Class {name:"ReimbursementController", context:"Outbound", purpose:"Employee submitting a new claim"});
CREATE (jc4:Class {name:"AllReimburseMentClaimStatusAction", context:"Web", purpose:"Action page for all reimbursement claims"});
CREATE (jc5:Class {name:"HrReimburseMentClaimAction", context:"Web", purpose:"Approver page for taking action"});
CREATE (jc6:Class {name:"ReimbursementProxyAction", context:"Web", purpose:"Approver page for setting up a proxy reimbursement"});
CREATE (jc7:Class {name:"LakhsFormatConverter", context:"Web", purpose:"Helper class for converting into Lakhs notation"});
CREATE (jc8:Class {name:"HrReimburseMentClaimRestService", context:"Mobile", purpose:"Approver class for taking action"});

-- UI Classes
CREATE (uic1:Class {name:"ReimburseMentClaim.xhtml", context:"Web", purpose:"Employee submitting a new claim"});
CREATE (uic2:Class {name:"CommonModalPanel.xhtml", context:"Web", purpose:"Employee dialogue box for filling claim details"});
CREATE (uic3:Class {name:"ReimburseMentClaimStatus.xhtml", context:"Web", purpose:"Status page for viewing saved and processed claim details"});
CREATE (uic4:Class {name:"ReimbursementProxy.xhtml", context:"Web", purpose:"Proxy page for raising proxy claims"});
CREATE (uic5:Class {name:"HrReimburseMentClaim.xhtml", context:"Web", purpose:"Approver page for approving claims"});
CREATE (uic6:Class {name:"HrCommonModalPanel.xhtml", context:"Web", purpose:"Dialogue box for approvers"});
CREATE (uic7:Class {name:"AllReimbursementClaimStatus.xhtml", context:"Web", purpose:"Page for viewing all claims"});

-- Link all classes to the Related Classes section
MATCH (s5:Section {title:"Related Classes"})
MATCH (jc1:Class {name:"ReimburseMentClaimAction"}), (jc2:Class {name:"ReimbursementClaimRestService"}), (jc3:Class {name:"ReimbursementController"}),
      (jc4:Class {name:"AllReimburseMentClaimStatusAction"}), (jc5:Class {name:"HrReimburseMentClaimAction"}), (jc6:Class {name:"ReimbursementProxyAction"}),
      (jc7:Class {name:"LakhsFormatConverter"}), (jc8:Class {name:"HrReimburseMentClaimRestService"}),
      (uic1:Class {name:"ReimburseMentClaim.xhtml"}), (uic2:Class {name:"CommonModalPanel.xhtml"}), (uic3:Class {name:"ReimburseMentClaimStatus.xhtml"}),
      (uic4:Class {name:"ReimbursementProxy.xhtml"}), (uic5:Class {name:"HrReimburseMentClaim.xhtml"}), (uic6:Class {name:"HrCommonModalPanel.xhtml"}),
      (uic7:Class {name:"AllReimbursementClaimStatus.xhtml"})
CREATE (s5)-[:INCLUDES_CLASS]->(jc1),
       (s5)-[:INCLUDES_CLASS]->(jc2),
       (s5)-[:INCLUDES_CLASS]->(jc3),
       (s5)-[:INCLUDES_CLASS]->(jc4),
       (s5)-[:INCLUDES_CLASS]->(jc5),
       (s5)-[:INCLUDES_CLASS]->(jc6),
       (s5)-[:INCLUDES_CLASS]->(jc7),
       (s5)-[:INCLUDES_CLASS]->(jc8),
       (s5)-[:INCLUDES_CLASS]->(uic1),
       (s5)-[:INCLUDES_CLASS]->(uic2),
       (s5)-[:INCLUDES_CLASS]->(uic3),
       (s5)-[:INCLUDES_CLASS]->(uic4),
       (s5)-[:INCLUDES_CLASS]->(uic5),
       (s5)-[:INCLUDES_CLASS]->(uic6),
       (s5)-[:INCLUDES_CLASS]->(uic7);
────────────────────────────
5. Create nodes for BRE tables and link them

CREATE (t1:Table {name:"HrEmployeeReimbursement", role:"Main BRE Table"});
CREATE (t2:Table {name:"HrEmployeeReimbursementDetail", role:"Main BRE Table"});
CREATE (t3:Table {name:"HrEmployeeAttachments", role:"Main BRE Table"});
CREATE (t4:Table {name:"HrEmpReimbApprovalHistory", role:"Main BRE Table"});
CREATE (t5:Table {name:"HrEmpReimbDetailHistory", role:"Main BRE Table"});
CREATE (t6:Table {name:"HrEmployeeReimbursementPayment", role:"Main BRE Table"});
CREATE (t7:Table {name:"Raw_EmployeeReimbursementPayment", role:"Main BRE Table"});
CREATE (t8:Table {name:"HrExpenseCategory", role:"Supporting BRE Table"});
CREATE (t9:Table {name:"HrExpenseHead", role:"Supporting BRE Table"});
CREATE (t10:Table {name:"HrConveyanceRate", role:"Supporting BRE Table"});
CREATE (t11:Table {name:"BreAdminConfig", role:"Drools Config Table"});
CREATE (t12:Table {name:"BreAdminConfigDetails", role:"Drools Config Table"});

MATCH (s6:Section {title:"BRE Tables"}),
      (t1:Table {name:"HrEmployeeReimbursement"}), (t2:Table {name:"HrEmployeeReimbursementDetail"}),
      (t3:Table {name:"HrEmployeeAttachments"}), (t4:Table {name:"HrEmpReimbApprovalHistory"}),
      (t5:Table {name:"HrEmpReimbDetailHistory"}), (t6:Table {name:"HrEmployeeReimbursementPayment"}),
      (t7:Table {name:"Raw_EmployeeReimbursementPayment"}), (t8:Table {name:"HrExpenseCategory"}),
      (t9:Table {name:"HrExpenseHead"}), (t10:Table {name:"HrConveyanceRate"}),
      (t11:Table {name:"BreAdminConfig"}), (t12:Table {name:"BreAdminConfigDetails"})
CREATE (s6)-[:INCLUDES_TABLE]->(t1),
       (s6)-[:INCLUDES_TABLE]->(t2),
       (s6)-[:INCLUDES_TABLE]->(t3),
       (s6)-[:INCLUDES_TABLE]->(t4),
       (s6)-[:INCLUDES_TABLE]->(t5),
       (s6)-[:INCLUDES_TABLE]->(t6),
       (s6)-[:INCLUDES_TABLE]->(t7),
       (s6)-[:INCLUDES_TABLE]->(t8),
       (s6)-[:INCLUDES_TABLE]->(t9),
       (s6)-[:INCLUDES_TABLE]->(t10),
       (s6)-[:INCLUDES_TABLE]->(t11),
       (s6)-[:INCLUDES_TABLE]->(t12);
────────────────────────────
6. Create nodes for the PlantUML diagrams and attach them

CREATE (d1:Diagram {title:"BRE Tables Relationship Diagram", description:"PlantUML diagram illustrating the relationships between BRE tables and related classes"});
CREATE (d2:Diagram {title:"Claim Submission Flow", description:"Diagram showing the sequence of events when a claim is submitted (fetching cost centre, manager lists, expense category changes, saving a claim, etc.)"});
CREATE (d3:Diagram {title:"Bre Admin Logic", description:"Diagram detailing how the BRE Admin configuration selects the appropriate configuration based on employee DoJ, GDOJ, and Age"});
CREATE (d4:Diagram {title:"Approval Workflow", description:"Diagram representing the flow for claim approval from employee submission through L1/L2 managers and payroll SPOCs"});

MATCH (s10:Section {title:"Diagrams and PlantUML"}),
      (d1:Diagram {title:"BRE Tables Relationship Diagram"}),
      (d2:Diagram {title:"Claim Submission Flow"}),
      (d3:Diagram {title:"Bre Admin Logic"}),
      (d4:Diagram {title:"Approval Workflow"})
CREATE (s10)-[:INCLUDES_DIAGRAM]->(d1),
       (s10)-[:INCLUDES_DIAGRAM]->(d2),
       (s10)-[:INCLUDES_DIAGRAM]->(d3),
       (s10)-[:INCLUDES_DIAGRAM]->(d4);
────────────────────────────

These queries break down the document's content into a graph—with the document as the root node, its sections as children, and further details (classes, tables, diagrams) attached where relevant. You can extend or adjust property values (such as the "content" field) as necessary to suit your ingestion and querying needs.

<think>
Okay, let's tackle the user's request. They want a detailed plan to ingest the Non-CTC Claim document into a graph database using Cypher queries. I'll start by reviewing the provided files to understand the structure and content.

First, looking at the existing Cypher queries in test.py, they already create Document, Section nodes, and link them. They also handle Related Classes, BRE Tables, and Diagrams. The user's markdown file has more detailed information, so I need to identify what's missing in the current queries.

The markdown includes sections like Cost Centre, L1/L2 Manager, HrExpenseCategory, HrExpenseHead, HrConveyanceRate, and others that aren't covered in the existing queries. These sections contain entities and relationships that should be modeled in the graph.

I'll start by breaking down the document into sections and subsections. For each major section, I'll create nodes and link them to the Document. Then, I'll identify entities within each section, like CostCentre, Manager, ExpenseCategory, etc., and create nodes for them. Relationships like HAS_SUBSECTION, HAS_ENTITY, and others will connect these nodes.

Next, I'll look at the existing entities in the queries. For example, the Related Classes section is already handled, but the new sections like Configuration, Drools, and BRE Admin have tables and parameters that need nodes. I'll create nodes for SysRuleEngineConfig, BreAdminConfig, and their parameters, linking them appropriately.

The user's document also mentions workflows and processes, like the approval workflow and claim submission flow. These can be modeled as Process nodes with relationships to the involved entities.

I need to ensure that all entities from the markdown are represented: CostCentre, HrOrgUnitType, HrExpenseCategory, HrExpenseHead, etc. Each of these should have their own nodes with properties extracted from the document.

For the PlantUML diagrams, the current queries create Diagram nodes, but the markdown has more diagrams, so I'll check if they're all included. If not, I'll add them.

I'll structure the plan into phases, starting with enhancing the existing structure, adding new sections and entities, handling BRE Admin and Drools configurations, processes and workflows, and finally, enriching existing nodes with additional relationships.

Each step in the plan will outline the Cypher operations needed, ensuring that all entities and relationships from the document are accurately represented in the graph. I'll make sure to use consistent labels and relationship types, and include properties like source references for traceability.

Potential challenges include ensuring all entities are covered and avoiding duplication. I'll cross-reference the markdown with the existing queries to spot gaps. For example, the Cost Centre hierarchy and HrOrgUnitType aren't in the current model, so they need to be added.

Testing the queries incrementally and verifying against the document structure will be important. The final plan should provide a comprehensive graph model that mirrors the document's content, enabling effective querying and analysis.
</think>

Here's a structured plan to ingest the Non-CTC Claim document into a graph database using Cypher queries, with improvements over the existing structure:

### 1. Document Structure Enhancement
```cypher:ingestion_queries.cql
// 1.1 Create hierarchical section structure
MATCH (doc:Document {title:"Non CTC Claim"})
CREATE (doc)-[:HAS_SECTION]->(:Section:Subsystem {
  title: "Core Components",
  description: "Fundamental building blocks of Non-CTC Claim system"
})-[:HAS_SUBSECTION]->(:Section {
  title: "Structural Elements",
  content: "Includes Cost Centre, Org Units, and system hierarchies"
}),
(doc)-[:HAS_SECTION]->(:Section:Process {
  title: "Workflows",
  description: "End-to-end claim handling processes"
})-[:HAS_SUBSECTION]->(:Section {
  title: "Approval Mechanism",
  content: "L1/L2 manager approval logic and payment workflows"
});
```

### 2. Entity Extraction Plan
For each major entity type in the document, we'll create specialized nodes:

```cypher:ingestion_queries.cql
// 2.1 Cost Centre Structure
CREATE (cc:CostCentre:SystemComponent {
  name: "CostCentre",
  hierarchy: "Company > SBU > Business Unit > Function > Sub-function > Project Code",
  sourceTable: "HrCostCentre",
  mappingLogic: "Uses HrOrgUnitType.IsCostCenterLevel for UI mapping"
});

// 2.2 Manager Relationships
CREATE (mgr:Manager:Role {
  type: "L1/L2 Manager",
  approvalLogic: "Populated from user configuration with form security override",
  source: "HrEmployee table mappings"
});

// 2.3 Expense Configuration
CREATE (ec:ExpenseConfig:BusinessRule {
  name: "EligibilityRules",
  calculationBasis: ["Per transaction", "Per day", "Per month", "Date range", "Financial year", "Calendar year"],
  precedenceOrder: "Per transaction < Per day < Per month < Date range < Financial year < Calendar year",
  source: "BRE Admin Configuration and Drools rules"
});
```

### 3. BRE Configuration Modeling
```cypher:ingestion_queries.cql
// 3.1 BRE Admin Tables
CREATE (bac:Table:Configuration {
  name: "BreAdminConfig",
  columns: ["EmployeeGroupID", "ExpenseCategoryID", "ExpenseHeadID", "ConvenienceModeID"],
  purpose: "Main configuration table for BRE rules"
});

CREATE (bacd:Table:Configuration {
  name: "BreAdminConfigDetails",
  columns: ["AgeYears", "Experience", "Doj", "EligibilityAmount"],
  purpose: "Detailed rule parameters for BRE configurations"
});

// 3.2 Drools Configuration
CREATE (drc:Table:Configuration {
  name: "SysRuleEngineConfig",
  columns: ["RuleName", "RuleContent", "Status"],
  purpose: "Drools rule storage and deployment status"
});

CREATE (drp:Table:Configuration {
  name: "SysRuleEngineConfigParam",
  columns: ["ParamName", "ParamType", "DefaultValue"],
  purpose: "Parameter definitions for Drools rules"
});
```

### 4. Process Flow Modeling
```cypher:ingestion_queries.cql
// 4.1 Claim Submission Process
CREATE (csp:Process {
  name: "ClaimSubmission",
  entryPoints: ["Web (ReimburseMentClaimAction)", "Mobile (ReimbursementClaimRestService)", "Outbound APIs (ReimbursementController)"],
  steps: [
    "Cost Center Selection",
    "Manager Verification",
    "Expense Category/Head Configuration",
    "Attachment Upload",
    "Eligibility Calculation"
  ],
  exceptionHandling: "Excess claim flagging with mandatory comments"
});

// 4.2 Approval Workflow
CREATE (apw:Process {
  name: "ClaimApproval",
  participants: ["L1 Manager", "L2 Manager", "Payroll SPOCs"],
  approvalMethods: ["Direct approval", "Amount adjustment", "Proxy approval"],
  validationRules: ["Cannot approve with zero amount", "Mandatory remark fields"]
});
```

### 5. Enhanced Relationships
```cypher:ingestion_queries.cql
// 5.1 Connect Configuration to Processes
MATCH (ec:ExpenseConfig {name:"EligibilityRules"}), 
      (csp:Process {name:"ClaimSubmission"})
CREATE (csp)-[:USES_CONFIGURATION]->(ec);

// 5.2 Link Tables to Components
MATCH (bac:Table {name:"BreAdminConfig"}),
      (ec:ExpenseConfig {name:"EligibilityRules"})
CREATE (ec)-[:IMPLEMENTED_BY]->(bac);
```

### Implementation Strategy

1. **Phase 1 - Structural Foundation**
   - Create document node with enhanced metadata
   - Build hierarchical section structure with HAS_SUBSECTION relationships
   - Add source references to original markdown locations

2. **Phase 2 - Entity Extraction**
   - Create specialized nodes for key entities:
     - `CostCentre`, `OrgUnitType`, `ExpenseCategory`
     - `Manager`, `ApprovalRole`, `PaymentProcess`
   - Add entity properties from document details

3. **Phase 3 - BRE Configuration**
   - Model Drools vs BRE Admin differences
   - Create parameter nodes with data types
   - Connect configuration tables to business rules

4. **Phase 4 - Process Modeling**
   - Map claim submission flow steps
   - Model approval workflow states
   - Connect processes to UI components

5. **Phase 5 - Relationship Enrichment**
   - Add temporal relationships (BEFORE, TRIGGERS)
   - Connect error handling paths
   - Model configuration precedence

### Key Improvements Over Existing Model:
1. Hierarchical section structure with subsystem categorization
2. Specialized node types for different entity classes
3. Process flow modeling with step-by-step relationships
4. Configuration management with parameter tracking
5. Temporal relationships for workflow sequencing
6. Explicit error handling paths
7. Source reference tracking to original document sections

Would you like me to elaborate on any particular aspect of this ingestion plan or provide sample queries for specific sections?
