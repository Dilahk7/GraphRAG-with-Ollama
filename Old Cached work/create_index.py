from neo4j import GraphDatabase

# Connect to Neo4j
driver = GraphDatabase.driver('bolt://localhost:7687', auth=None)

def create_fulltext_index(tx):
    # Create fulltext index if it doesn't exist
    query = '''
    CREATE FULLTEXT INDEX fulltext_entity_id 
    IF NOT EXISTS 
    FOR (n:__Entity__) 
    ON EACH [n.id]
    '''
    tx.run(query)

# Execute the index creation
with driver.session() as session:
    session.execute_write(create_fulltext_index)
    print("Fulltext index created successfully")

# Close the driver
driver.close() 