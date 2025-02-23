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
  content: "Details the two forms (ReimburseMentClaim and ReimbursementClaimDialogbox for ESS and additional ones for MSS) and their usage for initiating, saving, submitting, or re‐submitting claims." 
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
CREATE (t1:Table {name: "HrEmployeeReimbursement", role: "Main BRE Table", description: "Primary table for reimbursement claims"});
CREATE (t2:Table {name: "HrEmployeeReimbursementDetail", role: "Main BRE Table", description: "Details of each reimbursement claim"});
CREATE (t3:Table {name: "HrEmployeeAttachments", role: "Main BRE Table", description: "Attachments for claims"});
CREATE (t4:Table {name: "HrEmpReimbApprovalHistory", role: "Main BRE Table", description: "Approval workflow history"});
CREATE (t5:Table {name: "HrEmployeeReimbursementPayment", role: "Main BRE Table", description: "Payment processing information"});
CREATE (t6:Table {name: "Raw_EmployeeReimbursementPayment", role: "Main BRE Table", description: "Raw payment data"});

// 5.2 Supporting BRE Tables
CREATE (t7:Table {name: "HrExpenseCategory", role: "Supporting BRE Table", description: "Expense categories master"});
CREATE (t8:Table {name: "HrExpenseHead", role: "Supporting BRE Table", description: "Expense heads under categories"});
CREATE (t9:Table {name: "HrConveyanceRate", role: "Supporting BRE Table", description: "Conveyance rates configuration"});

// 5.3 Configuration Tables
CREATE (t10:Table {name: "BreAdminConfig", role: "Drools Config Table", description: "BRE configuration master"});
CREATE (t11:Table {name: "BreAdminConfigDetails", role: "Drools Config Table", description: "Detailed BRE configuration rules"});

// 5.4 Link Tables to BRE Tables Section
MATCH (s6:Section {title:"BRE Tables"}),
      (t1:Table {name:"HrEmployeeReimbursement"}), (t2:Table {name:"HrEmployeeReimbursementDetail"}),
      (t3:Table {name:"HrEmployeeAttachments"}), (t4:Table {name:"HrEmpReimbApprovalHistory"}),
      (t5:Table {name:"HrEmpReimbDetailHistory"}), (t6:Table {name:"Raw_EmployeeReimbursementPayment"}),
      (t7:Table {name:"HrExpenseCategory"}), (t8:Table {name:"HrExpenseHead"}),
      (t9:Table {name:"HrConveyanceRate"}), (t10:Table {name:"BreAdminConfig"}),
      (t11:Table {name:"BreAdminConfigDetails"})
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
       (s6)-[:INCLUDES_TABLE]->(t11);

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

// 9. Column Nodes Creation (All columns defined once)
// ------------------------------------------------

// HrEmployeeReimbursement columns
MERGE (c1_1:Column {name: "ReimbursementID"}) 
  SET c1_1.dataType = "bigint", 
      c1_1.isPrimaryKey = true, 
      c1_1.description = "Unique identifier for reimbursement claims";

MERGE (c1_2:Column {name: "ClaimCode"})
  SET c1_2.dataType = "varchar(150)",
      c1_2.description = "Business reference code for the claim";

MERGE (c1_3:Column {name: "EmployeeID"})
  SET c1_3.dataType = "int",
      c1_3.description = "Employee who submitted the claim";

MERGE (c1_4:Column {name: "L1managerID"})
  SET c1_4.dataType = "int",
      c1_4.description = "First level approver";

MERGE (c1_5:Column {name: "L2managerID"})
  SET c1_5.dataType = "int",
      c1_5.description = "Second level approver";

MERGE (c1_6:Column {name: "StageID"})
  SET c1_6.dataType = "int",
      c1_6.description = "Current workflow stage";

MERGE (c1_7:Column {name: "ExpenseCategoryID"})
  SET c1_7.dataType = "bigint",
      c1_7.isForeignKey = true, 
      c1_7.description = "Category of expense";

MERGE (c1_8:Column {name: "CostCenterID"})
  SET c1_8.dataType = "int",
      c1_8.description = "Cost center for accounting";

MERGE (c1_9:Column {name: "TenantID"})
  SET c1_9.dataType = "int",
      c1_9.description = "Multi-tenant identifier";

MERGE (c1_10:Column {name: "StartDateID"})
  SET c1_10.dataType = "int",
      c1_10.description = "Claim period start";

MERGE (c1_11:Column {name: "EndDateID"})
  SET c1_11.dataType = "int",
      c1_11.description = "Claim period end";

MERGE (c1_12:Column {name: "Status"})
  SET c1_12.dataType = "varchar(500)",
      c1_12.description = "Current claim status";

MERGE (c1_13:Column {name: "CreatedBy"})
  SET c1_13.dataType = "int",
      c1_13.description = "User who created the record";

MERGE (c1_14:Column {name: "ModifiedBy"})
  SET c1_14.dataType = "int",
      c1_14.description = "User who last modified the record";

MERGE (c1_15:Column {name: "CreatedDate"})
  SET c1_15.dataType = "datetime",
      c1_15.description = "Record creation timestamp";

MERGE (c1_16:Column {name: "ModifiedDate"})
  SET c1_16.dataType = "datetime",
      c1_16.description = "Last modification timestamp";

// HrEmployeeReimbursementDetail columns
MERGE (c2_1:Column {name: "ReimbursementDetailID"})
  SET c2_1.dataType = "bigint",
      c2_1.isPrimaryKey = true, 
      c2_1.description = "Unique identifier for claim detail";

MERGE (c2_2:Column {name: "ReimbursementID"})
  SET c2_2.dataType = "bigint",
      c2_2.isForeignKey = true, 
      c2_2.description = "Reference to main reimbursement claim";

MERGE (c2_3:Column {name: "ExpenseHeadID"})
  SET c2_3.dataType = "bigint",
      c2_3.isForeignKey = true, 
      c2_3.description = "Type of expense";

MERGE (c2_4:Column {name: "EligibleAmount"})
  SET c2_4.dataType = "numeric(15,5)",
      c2_4.description = "Maximum eligible amount";

MERGE (c2_5:Column {name: "ClaimedAmount"})
  SET c2_5.dataType = "numeric(15,5)",
      c2_5.description = "Actually claimed amount";

MERGE (c2_6:Column {name: "CreatedBy"})
  SET c2_6.dataType = "int",
      c2_6.description = "User who created the record";

MERGE (c2_7:Column {name: "ModifiedBy"})
  SET c2_7.dataType = "int",
      c2_7.description = "User who last modified the record";

MERGE (c2_8:Column {name: "CreatedDate"})
  SET c2_8.dataType = "datetime",
      c2_8.description = "Record creation timestamp";

MERGE (c2_9:Column {name: "ModifiedDate"})
  SET c2_9.dataType = "datetime",
      c2_9.description = "Last modification timestamp";

// Update HrEmployeeReimbursementDetail columns with new/modified columns
MERGE (c2_10:Column {name: "VendorName"})
  SET c2_10.dataType = "nvarchar(100)",
      c2_10.description = "Name of the vendor";

MERGE (c2_11:Column {name: "BillNumber"})
  SET c2_11.dataType = "nvarchar(100)",
      c2_11.description = "Bill reference number";

MERGE (c2_12:Column {name: "StartDateID"})
  SET c2_12.dataType = "int",
      c2_12.isForeignKey = true, 
      c2_12.description = "Start date reference";

MERGE (c2_13:Column {name: "EndDateID"})
  SET c2_13.dataType = "int",
      c2_13.isForeignKey = true, 
      c2_13.description = "End date reference";

MERGE (c2_14:Column {name: "BillDateID"})
  SET c2_14.dataType = "int",
      c2_14.isForeignKey = true, 
      c2_14.description = "Bill date reference";

MERGE (c2_15:Column {name: "PaymentModeTypeID"})
  SET c2_15.dataType = "int",
      c2_15.isForeignKey = true, 
      c2_15.description = "Payment mode type reference";

MERGE (c2_16:Column {name: "EmployeeComments"})
  SET c2_16.dataType = "nvarchar(4000)",
      c2_16.description = "Comments from employee";

MERGE (c2_17:Column {name: "TenantID"})
  SET c2_17.dataType = "int",
      c2_17.description = "Tenant identifier";

MERGE (c2_18:Column {name: "Comments"})
  SET c2_18.dataType = "nvarchar(4000)",
      c2_18.description = "General comments";

MERGE (c2_19:Column {name: "ApprovedAmount"})
  SET c2_19.dataType = "numeric(15,5)",
      c2_19.description = "Approved amount for reimbursement";

// Add conveyance-related columns
MERGE (c2_20:Column {name: "ConveyanceDistance"})
  SET c2_20.dataType = "numeric(12,2)",
      c2_20.description = "Distance for conveyance";

MERGE (c2_21:Column {name: "ConveyanceRate"})
  SET c2_21.dataType = "numeric(12,2)",
      c2_21.description = "Rate per unit for conveyance";

MERGE (c2_22:Column {name: "ConveyanceMode"})
  SET c2_22.dataType = "int",
      c2_22.description = "Mode of conveyance";

MERGE (c2_23:Column {name: "ConveyanceFrom"})
  SET c2_23.dataType = "nvarchar(100)",
      c2_23.description = "Starting point of conveyance";

MERGE (c2_24:Column {name: "ConveyanceTo"})
  SET c2_24.dataType = "nvarchar(100)",
      c2_24.description = "Destination of conveyance";

// Add additional fields
MERGE (c2_25:Column {name: "ExcessClaimReason"})
  SET c2_25.dataType = "nvarchar(500)",
      c2_25.description = "Reason for excess claim";

MERGE (c2_26:Column {name: "BillPeriodID"})
  SET c2_26.dataType = "int",
      c2_26.description = "Billing period reference";

// Add mobile and CUG related fields
MERGE (c2_27:Column {name: "MobileNumber"})
  SET c2_27.dataType = "nvarchar(40)",
      c2_27.description = "Mobile number";

MERGE (c2_28:Column {name: "IsCUG"})
  SET c2_28.dataType = "bit",
      c2_28.description = "Closed User Group flag";

// Add document and payment related fields
MERGE (c2_29:Column {name: "DocID"})
  SET c2_29.dataType = "nvarchar(100)",
      c2_29.description = "Document identifier";

MERGE (c2_30:Column {name: "PaymentID"})
  SET c2_30.dataType = "nvarchar(100)",
      c2_30.description = "Payment identifier";

// Add customer related fields
MERGE (c2_31:Column {name: "InternalOrderNumber"})
  SET c2_31.dataType = "nvarchar(200)",
      c2_31.description = "Internal order reference";

MERGE (c2_32:Column {name: "customerName"})
  SET c2_32.dataType = "nvarchar(500)",
      c2_32.description = "Customer name";

MERGE (c2_33:Column {name: "phoneNo"})
  SET c2_33.dataType = "nvarchar(200)",
      c2_33.description = "Phone number";

// Add system fields
MERGE (c2_34:Column {name: "Rowkey"})
  SET c2_34.dataType = "timestamp",
      c2_34.description = "Row version timestamp";

MERGE (c2_35:Column {name: "Rowkeynum"})
  SET c2_35.dataType = "bigint",
      c2_35.description = "Computed column from rowkey";

// Add temporal fields
MERGE (c2_36:Column {name: "SysStartTime"})
  SET c2_36.dataType = "datetime2",
      c2_36.description = "System row start time";

MERGE (c2_37:Column {name: "SysEndTime"})
  SET c2_37.dataType = "datetime2",
      c2_37.description = "System row end time";

// Add calculation related fields
MERGE (c2_38:Column {name: "CalculateOnDates"})
  SET c2_38.dataType = "bit",
      c2_38.description = "Calculate based on dates flag";

MERGE (c2_39:Column {name: "ReduceDays"})
  SET c2_39.dataType = "int",
      c2_39.description = "Number of days to reduce";

// Add GST and service charge related fields
MERGE (c2_40:Column {name: "GstAmount"})
  SET c2_40.dataType = "decimal(11,5)",
      c2_40.description = "GST amount";

MERGE (c2_41:Column {name: "ServiceChargeAmount"})
  SET c2_41.dataType = "decimal(11,5)",
      c2_41.description = "Service charge amount";

MERGE (c2_42:Column {name: "GstPercentage"})
  SET c2_42.dataType = "decimal(8,2)",
      c2_42.description = "GST percentage";

MERGE (c2_43:Column {name: "ServiceChargePercentage"})
  SET c2_43.dataType = "decimal(8,2)",
      c2_43.description = "Service charge percentage";

// Add amount related fields
MERGE (c2_44:Column {name: "ActualAmount"})
  SET c2_44.dataType = "numeric(15,5)",
      c2_44.description = "Actual amount";

MERGE (c2_45:Column {name: "TaxAmount"})
  SET c2_45.dataType = "numeric(15,5)",
      c2_45.description = "Tax amount";

MERGE (c2_46:Column {name: "approvedActualAmount"})
  SET c2_46.dataType = "numeric(15,5)",
      c2_46.description = "Approved actual amount";

MERGE (c2_47:Column {name: "approvedTaxAmount"})
  SET c2_47.dataType = "numeric(15,5)",
      c2_47.description = "Approved tax amount";

// Create TimeDimension table and indexes
MERGE (t15:Table {name: "TimeDimension", role: "Reference Table", description: "Time dimension reference data"})

MERGE (idx7:Index {
  name: "IX_HrEmployeeReimbursementDetail_VendorName_BillNumber_BillDateID_TenantID",
  type: "NONCLUSTERED",
  columns: ["VendorName", "BillNumber", "BillDateID", "TenantID"]
})
WITH idx7

MERGE (idx8:Index {
  name: "idx_HREMPLOYEEREIMBURSEMENTDETAIL_Key",
  type: "NONCLUSTERED",
  columns: ["Rowkeynum"]
})
WITH idx8

MERGE (idx9:Index {
  name: "idx_HrEmployeeReimbursementDetail_ReimbursementID",
  type: "NONCLUSTERED",
  columns: ["ReimbursementID"]
})
WITH idx9

// Link indexes to table
MATCH (t:Table {name: "HrEmployeeReimbursementDetail"})
MATCH (idx:Index)
WHERE idx.name STARTS WITH "IX_HrEmployeeReimbursementDetail" 
   OR idx.name STARTS WITH "idx_HrEmployeeReimbursementDetail"
MERGE (t)-[:HAS_INDEX]->(idx);

// Create relationships for TimeDimension
MATCH (t15:Table {name: "TimeDimension"})
MATCH (fk:Column {name: "StartDateID"})<-[:HAS_COLUMN]-(t:Table {name: "HrEmployeeReimbursementDetail"})
MERGE (fk)-[:REFERENCES]->(t15);

MATCH (t15:Table {name: "TimeDimension"})
MATCH (fk:Column {name: "EndDateID"})<-[:HAS_COLUMN]-(t:Table {name: "HrEmployeeReimbursementDetail"})
MERGE (fk)-[:REFERENCES]->(t15);

MATCH (t15:Table {name: "TimeDimension"})
MATCH (fk:Column {name: "BillDateID"})<-[:HAS_COLUMN]-(t:Table {name: "HrEmployeeReimbursementDetail"})
MERGE (fk)-[:REFERENCES]->(t15);

// Create relationship for HrContentType
MATCH (fk:Column {name: "PaymentModeTypeID"})<-[:HAS_COLUMN]-(t:Table {name: "HrEmployeeReimbursementDetail"})
MATCH (ref:Table {name: "HrContentType"})
MERGE (fk)-[:REFERENCES]->(ref);
