// Non-CTC Claim Document Graph Ingestion Queries Draft one
// ==========================================

// 1. Document Node Creation
// ------------------------
CREATE (doc:Document {
  title: "Non CTC Claim",
  aliases: ["Business related expenses", "Business requirement expenses", "BER", 
           "Business expenses related", "non-CTC-claim", "Reimbursement", "non ctc claim"],
  tags: ["module"],
  source: "Non CTC Claim.md"
});

// 2. Section Structure
// -------------------

// 2.1 Create Section Nodes
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
  content: "Documents the BRE-related tables including main BRE tables, supporting tables, and Drools configuration tables." 
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

// 2.2 Link Sections to Document
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

// 3. Entity Creation
// -----------------

// 3.1 Cost Centre Structure
CREATE (cc:CostCentre:SystemComponent {
  name: "CostCentre",
  hierarchy: "Company > SBU > Business Unit > Function > Sub-function > Project Code",
  sourceTable: "HrCostCentre",
  mappingLogic: "Uses HrOrgUnitType.IsCostCenterLevel for UI mapping"
});

// 3.2 Manager Configuration
CREATE (mgr:Manager:Role {
  type: "L1/L2 Manager",
  approvalLogic: "Populated from user configuration with form security override",
  source: "HrEmployee table mappings"
});

// 3.3 Expense Configuration
CREATE (ec:ExpenseConfig:BusinessRule {
  name: "EligibilityRules",
  calculationBasis: ["Per transaction", "Per day", "Per month", "Date range", "Financial year", "Calendar year"],
  precedenceOrder: "Per transaction < Per day < Per month < Date range < Financial year < Calendar year",
  source: "BRE Admin Configuration and Drools rules"
});

// 4. Class Nodes
// -------------

// 4.1 Java Classes
CREATE (jc1:Class {name:"ReimburseMentClaimAction", context:"Web", purpose:"Employee submitting a new claim"});
CREATE (jc2:Class {name:"ReimbursementClaimRestService", context:"Mobile", purpose:"Employee submitting a new claim"});
CREATE (jc3:Class {name:"ReimbursementController", context:"Outbound", purpose:"Employee submitting a new claim"});
CREATE (jc4:Class {name:"AllReimburseMentClaimStatusAction", context:"Web", purpose:"Action page for all reimbursement claims"});
CREATE (jc5:Class {name:"HrReimburseMentClaimAction", context:"Web", purpose:"Approver page for taking action"});
CREATE (jc6:Class {name:"ReimbursementProxyAction", context:"Web", purpose:"Approver page for setting up a proxy reimbursement"});
CREATE (jc7:Class {name:"LakhsFormatConverter", context:"Web", purpose:"Helper class for converting into Lakhs notation"});
CREATE (jc8:Class {name:"HrReimburseMentClaimRestService", context:"Mobile", purpose:"Approver class for taking action"});

// 4.2 UI Classes
CREATE (uic1:Class {name:"ReimburseMentClaim.xhtml", context:"Web", purpose:"Employee submitting a new claim"});
CREATE (uic2:Class {name:"CommonModalPanel.xhtml", context:"Web", purpose:"Employee dialogue box for filling claim details"});
CREATE (uic3:Class {name:"ReimburseMentClaimStatus.xhtml", context:"Web", purpose:"Status page for viewing saved and processed claim details"});
CREATE (uic4:Class {name:"ReimbursementProxy.xhtml", context:"Web", purpose:"Proxy page for raising proxy claims"});
CREATE (uic5:Class {name:"HrReimburseMentClaim.xhtml", context:"Web", purpose:"Approver page for approving claims"});
CREATE (uic6:Class {name:"HrCommonModalPanel.xhtml", context:"Web", purpose:"Dialogue box for approvers"});
CREATE (uic7:Class {name:"AllReimbursementClaimStatus.xhtml", context:"Web", purpose:"Page for viewing all claims"});

// 4.3 Link Classes to Related Classes Section
MATCH (s5:Section {title:"Related Classes"})
MATCH (jc1:Class {name:"ReimburseMentClaimAction"}), (jc2:Class {name:"ReimbursementClaimRestService"}), 
      (jc3:Class {name:"ReimbursementController"}), (jc4:Class {name:"AllReimburseMentClaimStatusAction"}), 
      (jc5:Class {name:"HrReimburseMentClaimAction"}), (jc6:Class {name:"ReimbursementProxyAction"}),
      (jc7:Class {name:"LakhsFormatConverter"}), (jc8:Class {name:"HrReimburseMentClaimRestService"}),
      (uic1:Class {name:"ReimburseMentClaim.xhtml"}), (uic2:Class {name:"CommonModalPanel.xhtml"}), 
      (uic3:Class {name:"ReimburseMentClaimStatus.xhtml"}), (uic4:Class {name:"ReimbursementProxy.xhtml"}), 
      (uic5:Class {name:"HrReimburseMentClaim.xhtml"}), (uic6:Class {name:"HrCommonModalPanel.xhtml"}),
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

// 5. BRE Tables
// ------------

// 5.1 Main BRE Tables
CREATE (t1:Table {name:"HrEmployeeReimbursement", role:"Main BRE Table"});
CREATE (t2:Table {name:"HrEmployeeReimbursementDetail", role:"Main BRE Table"});
CREATE (t3:Table {name:"HrEmployeeAttachments", role:"Main BRE Table"});
CREATE (t4:Table {name:"HrEmpReimbApprovalHistory", role:"Main BRE Table"});
CREATE (t5:Table {name:"HrEmpReimbDetailHistory", role:"Main BRE Table"});
CREATE (t6:Table {name:"HrEmployeeReimbursementPayment", role:"Main BRE Table"});
CREATE (t7:Table {name:"Raw_EmployeeReimbursementPayment", role:"Main BRE Table"});

// 5.2 Supporting BRE Tables
CREATE (t8:Table {name:"HrExpenseCategory", role:"Supporting BRE Table"});
CREATE (t9:Table {name:"HrExpenseHead", role:"Supporting BRE Table"});
CREATE (t10:Table {name:"HrConveyanceRate", role:"Supporting BRE Table"});

// 5.3 Configuration Tables
CREATE (t11:Table {name:"BreAdminConfig", role:"Drools Config Table"});
CREATE (t12:Table {name:"BreAdminConfigDetails", role:"Drools Config Table"});

// 5.4 Link Tables to BRE Tables Section
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

// 6. Process Nodes
// ---------------

// 6.1 Claim Submission Process
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

// 6.2 Approval Workflow
CREATE (apw:Process {
  name: "ClaimApproval",
  participants: ["L1 Manager", "L2 Manager", "Payroll SPOCs"],
  approvalMethods: ["Direct approval", "Amount adjustment", "Proxy approval"],
  validationRules: ["Cannot approve with zero amount", "Mandatory remark fields"]
});

// 7. Process Relationships
// ----------------------

// 7.1 Link Processes to Configuration
MATCH (ec:ExpenseConfig {name:"EligibilityRules"}), 
      (csp:Process {name:"ClaimSubmission"})
CREATE (csp)-[:USES_CONFIGURATION]->(ec);

// 7.2 Link Tables to Components
MATCH (bac:Table {name:"BreAdminConfig"}),
      (ec:ExpenseConfig {name:"EligibilityRules"})
CREATE (ec)-[:IMPLEMENTED_BY]->(bac);

// 8. Diagrams
// ----------
CREATE (d1:Diagram {
  title:"BRE Tables Relationship Diagram", 
  description:"PlantUML diagram illustrating the relationships between BRE tables and related classes"
});

CREATE (d2:Diagram {
  title:"Claim Submission Flow", 
  description:"Diagram showing the sequence of events when a claim is submitted (fetching cost centre, manager lists, expense category changes, saving a claim, etc.)"
});

CREATE (d3:Diagram {
  title:"Bre Admin Logic", 
  description:"Diagram detailing how the BRE Admin configuration selects the appropriate configuration based on employee DoJ, GDOJ, and Age"
});

CREATE (d4:Diagram {
  title:"Approval Workflow", 
  description:"Diagram representing the flow for claim approval from employee submission through L1/L2 managers and payroll SPOCs"
});

// 8.1 Link Diagrams to Section
MATCH (s10:Section {title:"Diagrams and PlantUML"}),
      (d1:Diagram {title:"BRE Tables Relationship Diagram"}),
      (d2:Diagram {title:"Claim Submission Flow"}),
      (d3:Diagram {title:"Bre Admin Logic"}),
      (d4:Diagram {title:"Approval Workflow"})
CREATE (s10)-[:INCLUDES_DIAGRAM]->(d1),
       (s10)-[:INCLUDES_DIAGRAM]->(d2),
       (s10)-[:INCLUDES_DIAGRAM]->(d3),
       (s10)-[:INCLUDES_DIAGRAM]->(d4); 