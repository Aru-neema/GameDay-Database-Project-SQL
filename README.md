# Database-Project
NOTE- This is an academic group project as part of course IST 659- Database admin Concepts and Management, Syracuse University. Also, this document assumes that you know how to operate and connect databases to Azure datastudio. If not, it's still helpful to understand how to write SQL code for creating a database

After reading the documentation, the audience (beginners, students, aspirational data analyst) will know how to do the following tasks:
1) Understand how to make a workflow for building a relational database
2) How to write SQL codes to create tables and populate it with data
3) Get some examples of how to incorporate data logic operations like procedure, views and triggers

Project Background- The purpose of this project was to use the different database designing, creation and implementation concepts taught in IST 659. The objective was to create a working database on any business topic of our choice. 


## Problem Statement 

League ball games such as NFL, TBL are popular in the United States, but ball game lovers might be having a hard time tracking down timely information about each type of games and planning their visits. Additionally, when people are switching between different apps, lots of time is consumed and they also face surge pricing when they’re looking for place to stay. Hence, the lack of information and inefficiency might prevent people from eventually going to a ball game or it might make the game trip more expensive and inefficiently organized

## Proposed Solution 

We are creating an infrastructure that will seamlessly connect fans to all the information on ball games happening in New York State. We tend to optimize the users’ journeys to attend a game by providing information on hotels and places to dine in. 

With the help of our information system, the potential audience of the games will be able to have the latest information on every upcoming game, make accommodation plans accordingly and check out the means of transportation available, leading to a smoother, up-to-date and optimized user experience.  

It will also help the hosts of the game and hotels, as well as transportation services keeping track of the size of the audience. For example, they will be able to calculate how much traffic to expect before the game. So, it will act as single source of record for repeatable, measurable events.  

Lastly, the database is useful for ticket sales and distribution for being able to provide information on the ticket and information for planning marketing campaigns to put on social media.


## Business Description 

The database will contain information on league ball games happening in different stadiums in New York States. It will help people get information about types, locations, time and price of the tickets for each game happening nearby, as well as the availability of accommodations and restaurants.  

Assumptions:  

1. There are 6 stadiums in New York 
2. The games and games details mentioned in the databases are representative of all the games in NY state 
3. Some of the tickets are sold out 
4. The names of hotels and restaurants are representative of all the brands present in the area 
5. One game is played in one stadium in one day
6. Only two teams play in one game
7. The names of transportation providers and restaurants are representative of all the brands present in the area 

## Database designing process

1. The first step to creating the database was to do initial buisness validation of the idea through research and identifying the need which helped in setting up the objective and goals of the project

2. Then an entity relationship diagram (ERD) and cocneptual was constructed which provide a visual starting point for database design that can also helped in defining the entites involved in database desiging and also helps in establishing initial relationships between different tables 

3. Then a logical model was cocnstructed that established the structure of data elements and the relationships among them. It is independent of the physical database that details how the data will be implemented. The logical data model serves as a blueprint for used data. It also helps in establishing different keys. 

4. SQL coding was done on Azure data studio to implement the conceptual and logical model. Here, the code is divided into three sections- the create part (down and p metadata), the insert part (up data) and the special functions part (views, procedures, triggers). 
