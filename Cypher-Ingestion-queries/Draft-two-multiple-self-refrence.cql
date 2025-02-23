// Non-CTC Claim Document Graph Ingestion Queries
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

// 9. Column Nodes and Relationships
// -------------------------------

// 9.1 Create Column nodes for HrEmployeeReimbursement
CREATE (c1_1:Column {name: "ReimbursementID", dataType: "bigint", isPrimaryKey: true});
CREATE (c1_2:Column {name: "ClaimCode", dataType: "varchar(150)"});
CREATE (c1_3:Column {name: "EmployeeID", dataType: "int"});
CREATE (c1_4:Column {name: "L1managerID", dataType: "int"});
CREATE (c1_5:Column {name: "L2managerID", dataType: "int"});
CREATE (c1_6:Column {name: "StageID", dataType: "int"});
CREATE (c1_7:Column {name: "ExpenseCategoryID", dataType: "bigint"});
CREATE (c1_8:Column {name: "CostCenterID", dataType: "int"});
CREATE (c1_9:Column {name: "TenantID", dataType: "int"});
CREATE (c1_10:Column {name: "StartDateID", dataType: "int"});
CREATE (c1_11:Column {name: "EndDateID", dataType: "int"});
CREATE (c1_12:Column {name: "Status", dataType: "varchar(500)"});

// 9.2 Create Column nodes for HrEmployeeReimbursementDetail
CREATE (c2_1:Column {name: "ReimbursementDetailID", dataType: "bigint", isPrimaryKey: true});
CREATE (c2_2:Column {name: "ReimbursementID", dataType: "bigint", isForeignKey: true});
CREATE (c2_3:Column {name: "ExpenseHeadID", dataType: "bigint", isForeignKey: true});
CREATE (c2_4:Column {name: "EligibleAmount", dataType: "numeric(15,5)"});
CREATE (c2_5:Column {name: "ClaimedAmount", dataType: "numeric(15,5)"});

// 9.3 Create Column nodes for HrExpenseCategory
CREATE (c3_1:Column {name: "ExpenseCategoryID", dataType: "bigint", isPrimaryKey: true});
CREATE (c3_2:Column {name: "ExpenseCategoryName", dataType: "nvarchar(100)"});
CREATE (c3_3:Column {name: "ExpenseCategoryDesc", dataType: "nvarchar(250)"});
CREATE (c3_4:Column {name: "ExpenseTypeID", dataType: "int"});

// 9.4 Create Column nodes for HrExpenseHead
CREATE (c4_1:Column {name: "ExpenseHeadID", dataType: "bigint", isPrimaryKey: true});
CREATE (c4_2:Column {name: "ExpenseHeadName", dataType: "nvarchar(100)"});
CREATE (c4_3:Column {name: "ExpenseHeadDesc", dataType: "nvarchar(250)"});
CREATE (c4_4:Column {name: "ExpenseCategoryID", dataType: "bigint", isForeignKey: true});

// 9.5 Link Columns to Tables
MATCH (t1:Table {name: "HrEmployeeReimbursement"}),
      (c1_1:Column {name: "ReimbursementID"}),
      (c1_2:Column {name: "ClaimCode"}),
      (c1_3:Column {name: "EmployeeID"}),
      (c1_4:Column {name: "L1managerID"}),
      (c1_5:Column {name: "L2managerID"}),
      (c1_6:Column {name: "StageID"}),
      (c1_7:Column {name: "ExpenseCategoryID"}),
      (c1_8:Column {name: "CostCenterID"}),
      (c1_9:Column {name: "TenantID"}),
      (c1_10:Column {name: "StartDateID"}),
      (c1_11:Column {name: "EndDateID"}),
      (c1_12:Column {name: "Status"})
CREATE (t1)-[:HAS_COLUMN]->(c1_1),
       (t1)-[:HAS_COLUMN]->(c1_2),
       (t1)-[:HAS_COLUMN]->(c1_3),
       (t1)-[:HAS_COLUMN]->(c1_4),
       (t1)-[:HAS_COLUMN]->(c1_5),
       (t1)-[:HAS_COLUMN]->(c1_6),
       (t1)-[:HAS_COLUMN]->(c1_7),
       (t1)-[:HAS_COLUMN]->(c1_8),
       (t1)-[:HAS_COLUMN]->(c1_9),
       (t1)-[:HAS_COLUMN]->(c1_10),
       (t1)-[:HAS_COLUMN]->(c1_11),
       (t1)-[:HAS_COLUMN]->(c1_12);

MATCH (t2:Table {name: "HrEmployeeReimbursementDetail"}),
      (c2_1:Column {name: "ReimbursementDetailID"}),
      (c2_2:Column {name: "ReimbursementID"}),
      (c2_3:Column {name: "ExpenseHeadID"}),
      (c2_4:Column {name: "EligibleAmount"}),
      (c2_5:Column {name: "ClaimedAmount"})
CREATE (t2)-[:HAS_COLUMN]->(c2_1),
       (t2)-[:HAS_COLUMN]->(c2_2),
       (t2)-[:HAS_COLUMN]->(c2_3),
       (t2)-[:HAS_COLUMN]->(c2_4),
       (t2)-[:HAS_COLUMN]->(c2_5);

MATCH (t3:Table {name: "HrExpenseCategory"}),
      (c3_1:Column {name: "ExpenseCategoryID"}),
      (c3_2:Column {name: "ExpenseCategoryName"}),
      (c3_3:Column {name: "ExpenseCategoryDesc"}),
      (c3_4:Column {name: "ExpenseTypeID"})
CREATE (t3)-[:HAS_COLUMN]->(c3_1),
       (t3)-[:HAS_COLUMN]->(c3_2),
       (t3)-[:HAS_COLUMN]->(c3_3),
       (t3)-[:HAS_COLUMN]->(c3_4);

MATCH (t4:Table {name: "HrExpenseHead"}),
      (c4_1:Column {name: "ExpenseHeadID"}),
      (c4_2:Column {name: "ExpenseHeadName"}),
      (c4_3:Column {name: "ExpenseHeadDesc"}),
      (c4_4:Column {name: "ExpenseCategoryID"})
CREATE (t4)-[:HAS_COLUMN]->(c4_1),
       (t4)-[:HAS_COLUMN]->(c4_2),
       (t4)-[:HAS_COLUMN]->(c4_3),
       (t4)-[:HAS_COLUMN]->(c4_4);

// 9.6 Create Foreign Key Relationships
MATCH (t1:Table {name: "HrEmployeeReimbursement"})-[:HAS_COLUMN]->(c1_1:Column {name: "ReimbursementID"}),
      (t2:Table {name: "HrEmployeeReimbursementDetail"})-[:HAS_COLUMN]->(c2_2:Column {name: "ReimbursementID"})
CREATE (c2_2)-[:REFERENCES]->(c1_1);

MATCH (t3:Table {name: "HrExpenseCategory"})-[:HAS_COLUMN]->(c3_1:Column {name: "ExpenseCategoryID"}),
      (t1:Table {name: "HrEmployeeReimbursement"})-[:HAS_COLUMN]->(c1_7:Column {name: "ExpenseCategoryID"})
CREATE (c1_7)-[:REFERENCES]->(c3_1);

MATCH (t4:Table {name: "HrExpenseHead"})-[:HAS_COLUMN]->(c4_1:Column {name: "ExpenseHeadID"}),
      (t2:Table {name: "HrEmployeeReimbursementDetail"})-[:HAS_COLUMN]->(c2_3:Column {name: "ExpenseHeadID"})
CREATE (c2_3)-[:REFERENCES]->(c4_1);

MATCH (t3:Table {name: "HrExpenseCategory"})-[:HAS_COLUMN]->(c3_1:Column {name: "ExpenseCategoryID"}),
      (t4:Table {name: "HrExpenseHead"})-[:HAS_COLUMN]->(c4_4:Column {name: "ExpenseCategoryID"})
CREATE (c4_4)-[:REFERENCES]->(c3_1);

// 9.7 Create Table Relationships based on Foreign Keys
MATCH (t1:Table {name: "HrEmployeeReimbursement"}),
      (t2:Table {name: "HrEmployeeReimbursementDetail"})
CREATE (t2)-[:BELONGS_TO]->(t1);

MATCH (t3:Table {name: "HrExpenseCategory"}),
      (t1:Table {name: "HrEmployeeReimbursement"})
CREATE (t1)-[:HAS_CATEGORY]->(t3);

MATCH (t4:Table {name: "HrExpenseHead"}),
      (t2:Table {name: "HrEmployeeReimbursementDetail"})
CREATE (t2)-[:HAS_EXPENSE]->(t4);

MATCH (t3:Table {name: "HrExpenseCategory"}),
      (t4:Table {name: "HrExpenseHead"})
CREATE (t4)-[:BELONGS_TO_CATEGORY]->(t3);

// 10. Additional Column Nodes and Relationships
// -----------------------------------------

// 10.1 Create Column nodes for HrEmployeeAttachments
CREATE (c5_1:Column {name: "HrAttachmentID", dataType: "bigint", isPrimaryKey: true});
CREATE (c5_2:Column {name: "ContextEntityID", dataType: "int"});
CREATE (c5_3:Column {name: "ContextInstanceID", dataType: "bigint", isForeignKey: true});
CREATE (c5_4:Column {name: "SysFileName", dataType: "nvarchar(200)"});
CREATE (c5_5:Column {name: "SysFilePath", dataType: "nvarchar(1024)"});
CREATE (c5_6:Column {name: "UserFileName", dataType: "nvarchar(200)"});
CREATE (c5_7:Column {name: "FileSize", dataType: "int"});
CREATE (c5_8:Column {name: "TenantID", dataType: "int"});

// 10.2 Create Column nodes for HrEmpReimbApprovalHistory
CREATE (c6_1:Column {name: "ReimbApprovalHistoryID", dataType: "bigint", isPrimaryKey: true});
CREATE (c6_2:Column {name: "ReimbursementID", dataType: "bigint", isForeignKey: true});
CREATE (c6_3:Column {name: "WorkflowHistoryID", dataType: "bigint"});
CREATE (c6_4:Column {name: "UserID", dataType: "int"});
CREATE (c6_5:Column {name: "Status", dataType: "nvarchar(500)"});
CREATE (c6_6:Column {name: "Remarks", dataType: "nvarchar(500)"});
CREATE (c6_7:Column {name: "TotalApprovedAmount", dataType: "numeric(15,2)"});
CREATE (c6_8:Column {name: "RejectionReasonId", dataType: "int"});

// 10.3 Create Column nodes for HrEmployeeReimbursementPayment
CREATE (c7_1:Column {name: "HrEmployeeReimbursementPaymentid", dataType: "bigint", isPrimaryKey: true});
CREATE (c7_2:Column {name: "ReimbursementID", dataType: "bigint", isForeignKey: true});
CREATE (c7_3:Column {name: "Active", dataType: "bit"});
CREATE (c7_4:Column {name: "ReferenceNo", dataType: "nvarchar(600)"});
CREATE (c7_5:Column {name: "Amount", dataType: "numeric(12,2)"});
CREATE (c7_6:Column {name: "PaymentDate", dataType: "nvarchar(200)"});
CREATE (c7_7:Column {name: "Status", dataType: "nvarchar(1000)"});

// 10.4 Create Column nodes for Raw_EmployeeReimbursementPayment
CREATE (c8_1:Column {name: "HrEmployeeReimbursementPaymentID", dataType: "bigint", isPrimaryKey: true});
CREATE (c8_2:Column {name: "ReimbursementID", dataType: "bigint", isForeignKey: true});
CREATE (c8_3:Column {name: "EmployeeID", dataType: "bigint"});
CREATE (c8_4:Column {name: "TransactionID", dataType: "bigint"});
CREATE (c8_5:Column {name: "isActive", dataType: "bit"});
CREATE (c8_6:Column {name: "isValid", dataType: "bit"});
CREATE (c8_7:Column {name: "isProcessed", dataType: "bit"});
CREATE (c8_8:Column {name: "ClaimCode", dataType: "nvarchar(600)"});

// 10.5 Create Column nodes for HrConveyanceRate
CREATE (c9_1:Column {name: "ConveyanceRateID", dataType: "int", isPrimaryKey: true});
CREATE (c9_2:Column {name: "ConveyanceTypeName", dataType: "nvarchar(100)"});
CREATE (c9_3:Column {name: "ConveyanceType", dataType: "nvarchar(100)"});
CREATE (c9_4:Column {name: "Rate", dataType: "numeric(10,2)"});
CREATE (c9_5:Column {name: "IsActive", dataType: "bit"});

// 10.6 Create Column nodes for BreAdminConfig
CREATE (c10_1:Column {name: "BreAdminConfigID", dataType: "int", isPrimaryKey: true});
CREATE (c10_2:Column {name: "EmployeeGroupID", dataType: "int"});
CREATE (c10_3:Column {name: "ExpenseCategoryID", dataType: "int", isForeignKey: true});
CREATE (c10_4:Column {name: "ExpenseHeadID", dataType: "int", isForeignKey: true});
CREATE (c10_5:Column {name: "ConvenienceModeID", dataType: "int"});
CREATE (c10_6:Column {name: "Name", dataType: "varchar(50)"});
CREATE (c10_7:Column {name: "Active", dataType: "bit"});

// 10.7 Create Column nodes for BreAdminConfigDetails
CREATE (c11_1:Column {name: "BreAdminConfigDetailsID", dataType: "int", isPrimaryKey: true});
CREATE (c11_2:Column {name: "BreAdminConfigID", dataType: "int", isForeignKey: true});
CREATE (c11_3:Column {name: "AgeYears", dataType: "int"});
CREATE (c11_4:Column {name: "Experience", dataType: "int"});
CREATE (c11_5:Column {name: "Doj", dataType: "int"});
CREATE (c11_6:Column {name: "EligibilityAmount", dataType: "numeric(22,5)"});
CREATE (c11_7:Column {name: "Rate", dataType: "numeric(22,5)"});
CREATE (c11_8:Column {name: "ExcessFlag", dataType: "bit"});

// 10.8 Link Columns to Tables
MATCH (t5:Table {name: "HrEmployeeAttachments"}),
      (c5_1:Column {name: "HrAttachmentID"}),
      (c5_2:Column {name: "ContextEntityID"}),
      (c5_3:Column {name: "ContextInstanceID"}),
      (c5_4:Column {name: "SysFileName"}),
      (c5_5:Column {name: "SysFilePath"}),
      (c5_6:Column {name: "UserFileName"}),
      (c5_7:Column {name: "FileSize"}),
      (c5_8:Column {name: "TenantID"})
CREATE (t5)-[:HAS_COLUMN]->(c5_1),
       (t5)-[:HAS_COLUMN]->(c5_2),
       (t5)-[:HAS_COLUMN]->(c5_3),
       (t5)-[:HAS_COLUMN]->(c5_4),
       (t5)-[:HAS_COLUMN]->(c5_5),
       (t5)-[:HAS_COLUMN]->(c5_6),
       (t5)-[:HAS_COLUMN]->(c5_7),
       (t5)-[:HAS_COLUMN]->(c5_8);

MATCH (t6:Table {name: "HrEmpReimbApprovalHistory"}),
      (c6_1:Column {name: "ReimbApprovalHistoryID"}),
      (c6_2:Column {name: "ReimbursementID"}),
      (c6_3:Column {name: "WorkflowHistoryID"}),
      (c6_4:Column {name: "UserID"}),
      (c6_5:Column {name: "Status"}),
      (c6_6:Column {name: "Remarks"}),
      (c6_7:Column {name: "TotalApprovedAmount"}),
      (c6_8:Column {name: "RejectionReasonId"})
CREATE (t6)-[:HAS_COLUMN]->(c6_1),
       (t6)-[:HAS_COLUMN]->(c6_2),
       (t6)-[:HAS_COLUMN]->(c6_3),
       (t6)-[:HAS_COLUMN]->(c6_4),
       (t6)-[:HAS_COLUMN]->(c6_5),
       (t6)-[:HAS_COLUMN]->(c6_6),
       (t6)-[:HAS_COLUMN]->(c6_7),
       (t6)-[:HAS_COLUMN]->(c6_8);

// Link remaining tables' columns similarly...

// 10.9 Create Additional Foreign Key Relationships
MATCH (t1:Table {name: "HrEmployeeReimbursement"})-[:HAS_COLUMN]->(c1_1:Column {name: "ReimbursementID"}),
      (t6:Table {name: "HrEmpReimbApprovalHistory"})-[:HAS_COLUMN]->(c6_2:Column {name: "ReimbursementID"})
CREATE (c6_2)-[:REFERENCES]->(c1_1);

MATCH (t1:Table {name: "HrEmployeeReimbursement"})-[:HAS_COLUMN]->(c1_1:Column {name: "ReimbursementID"}),
      (t7:Table {name: "HrEmployeeReimbursementPayment"})-[:HAS_COLUMN]->(c7_2:Column {name: "ReimbursementID"})
CREATE (c7_2)-[:REFERENCES]->(c1_1);

MATCH (t11:Table {name: "BreAdminConfig"})-[:HAS_COLUMN]->(c10_1:Column {name: "BreAdminConfigID"}),
      (t12:Table {name: "BreAdminConfigDetails"})-[:HAS_COLUMN]->(c11_2:Column {name: "BreAdminConfigID"})
CREATE (c11_2)-[:REFERENCES]->(c10_1);

// 10.10 Create Additional Table Relationships
MATCH (t1:Table {name: "HrEmployeeReimbursement"}),
      (t6:Table {name: "HrEmpReimbApprovalHistory"})
CREATE (t6)-[:TRACKS_APPROVAL_OF]->(t1);

MATCH (t1:Table {name: "HrEmployeeReimbursement"}),
      (t7:Table {name: "HrEmployeeReimbursementPayment"})
CREATE (t7)-[:PROCESSES_PAYMENT_FOR]->(t1);

MATCH (t11:Table {name: "BreAdminConfig"}),
      (t12:Table {name: "BreAdminConfigDetails"})
CREATE (t12)-[:CONFIGURES]->(t11);

// 11. Consolidated Relationships (Replacing previous relationship sections)
// ------------------------------------------------------------------

// 11.1 Create Foreign Key Relationships
// Primary to Foreign key relationships for ReimbursementID
MATCH (pk:Column {name: "ReimbursementID", isPrimaryKey: true})<-[:HAS_COLUMN]-(master:Table {name: "HrEmployeeReimbursement"}),
      (fk:Column {name: "ReimbursementID", isForeignKey: true})<-[:HAS_COLUMN]-(detail:Table)
WHERE detail.name IN ["HrEmployeeReimbursementDetail", "HrEmpReimbApprovalHistory", "HrEmployeeReimbursementPayment", "Raw_EmployeeReimbursementPayment"]
CREATE (fk)-[:REFERENCES]->(pk);

// Primary to Foreign key relationships for ExpenseCategoryID
MATCH (pk:Column {name: "ExpenseCategoryID", isPrimaryKey: true})<-[:HAS_COLUMN]-(master:Table {name: "HrExpenseCategory"}),
      (fk:Column {name: "ExpenseCategoryID", isForeignKey: true})<-[:HAS_COLUMN]-(detail:Table)
WHERE detail.name IN ["HrEmployeeReimbursement", "HrExpenseHead", "BreAdminConfig"]
CREATE (fk)-[:REFERENCES]->(pk);

// Primary to Foreign key relationships for ExpenseHeadID
MATCH (pk:Column {name: "ExpenseHeadID", isPrimaryKey: true})<-[:HAS_COLUMN]-(master:Table {name: "HrExpenseHead"}),
      (fk:Column {name: "ExpenseHeadID", isForeignKey: true})<-[:HAS_COLUMN]-(detail:Table)
WHERE detail.name IN ["HrEmployeeReimbursementDetail", "BreAdminConfig"]
CREATE (fk)-[:REFERENCES]->(pk);

// Primary to Foreign key relationship for BreAdminConfigID
MATCH (pk:Column {name: "BreAdminConfigID", isPrimaryKey: true})<-[:HAS_COLUMN]-(master:Table {name: "BreAdminConfig"}),
      (fk:Column {name: "BreAdminConfigID", isForeignKey: true})<-[:HAS_COLUMN]-(detail:Table {name: "BreAdminConfigDetails"})
CREATE (fk)-[:REFERENCES]->(pk);

// 11.2 Create Business Domain Relationships
// Main reimbursement flow
MATCH (main:Table {name: "HrEmployeeReimbursement"}),
      (detail:Table {name: "HrEmployeeReimbursementDetail"}),
      (approval:Table {name: "HrEmpReimbApprovalHistory"}),
      (payment:Table {name: "HrEmployeeReimbursementPayment"}),
      (raw_payment:Table {name: "Raw_EmployeeReimbursementPayment"})
CREATE (detail)-[:BELONGS_TO]->(main),
       (approval)-[:TRACKS_APPROVAL_OF]->(main),
       (payment)-[:PROCESSES_PAYMENT_FOR]->(main),
       (raw_payment)-[:RAW_DATA_FOR]->(payment);

// Expense categorization structure
MATCH (category:Table {name: "HrExpenseCategory"}),
      (head:Table {name: "HrExpenseHead"}),
      (main:Table {name: "HrEmployeeReimbursement"})
CREATE (head)-[:BELONGS_TO_CATEGORY]->(category),
       (main)-[:HAS_CATEGORY]->(category);

// Configuration structure
MATCH (config:Table {name: "BreAdminConfig"}),
      (config_detail:Table {name: "BreAdminConfigDetails"}),
      (category:Table {name: "HrExpenseCategory"}),
      (head:Table {name: "HrExpenseHead"})
CREATE (config_detail)-[:CONFIGURES]->(config),
       (config)-[:CONFIGURES_CATEGORY]->(category),
       (config)-[:CONFIGURES_HEAD]->(head);

// Conveyance rates
MATCH (rate:Table {name: "HrConveyanceRate"}),
      (detail:Table {name: "HrEmployeeReimbursementDetail"})
CREATE (detail)-[:USES_RATE]->(rate);

// 11.3 Create Metadata Relationships
// Add relationships for tracking and auditing
MATCH (t:Table)
WHERE t.name IN ["HrEmployeeReimbursement", "HrEmployeeReimbursementDetail", "HrEmpReimbApprovalHistory", 
                 "HrEmployeeReimbursementPayment", "Raw_EmployeeReimbursementPayment"]
MATCH (c:Column)<-[:HAS_COLUMN]-(t)
WHERE c.name IN ["CreatedBy", "ModifiedBy", "CreatedDate", "ModifiedDate"]
CREATE (t)-[:HAS_AUDIT_TRAIL]->(c);

// Add relationships for tenant isolation
MATCH (t:Table)
WHERE t.name IN ["HrEmployeeReimbursement", "HrEmployeeReimbursementDetail", "HrEmployeeAttachments", 
                 "HrEmpReimbApprovalHistory", "HrEmployeeReimbursementPayment"]
MATCH (c:Column {name: "TenantID"})<-[:HAS_COLUMN]-(t)
CREATE (t)-[:HAS_TENANT_ISOLATION]->(c); 