## How to test the database connection

psql postgresdb-products cust-user

\dt;

           List of relations
 Schema |   Name    | Type  |   Owner
--------+-----------+-------+-----------
 public | addresses | table | cust-user
 public | customers | table | cust-user
 
 