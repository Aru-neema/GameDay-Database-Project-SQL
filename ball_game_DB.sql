if not exists(SELECT * FROM sys.databases where name ='ball_game')
create database ball_game

GO
use ball_game
GO

--DOWN
if exists (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
where CONSTRAINT_NAME = 'fk_tickets_ticket_game_id')
    alter table tickets drop CONSTRAINT fk_tickets_ticket_game_id

if exists (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
where CONSTRAINT_NAME = 'fk_restaurants_restaurant_stadium_id')
    alter table restaurants drop CONSTRAINT fk_restaurants_restaurant_stadium_id

if exists (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
where CONSTRAINT_NAME = 'fk_hotels_hotel_stadium_id')
    alter table hotels drop CONSTRAINT fk_hotels_hotel_stadium_id

if exists (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
where CONSTRAINT_NAME = 'fk_teams_team_game_type ')
    alter table teams drop CONSTRAINT  fk_teams_team_game_type 

if exists (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
where CONSTRAINT_NAME = 'fk_games_game_type_name')
    alter table games drop CONSTRAINT  fk_games_game_type_name

if exists (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
where CONSTRAINT_NAME = 'fk_games_hometeam_id')
    alter table games drop CONSTRAINT  fk_games_hometeam_id

if exists (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
where CONSTRAINT_NAME = 'fk_games_awayteam_id')
    alter table games drop CONSTRAINT  fk_games_awayteam_id
 

drop table if exists games
drop table if exists tickets
drop table if exists stadiums
drop table if exists teams
drop table if exists restaurants
drop table if exists hotels 
drop table if exists game_types_lookup
drop table if exists stadium_types_lookup


--UP METADATA

GO

CREATE TABLE game_types_lookup (
     [game_type_name] VARCHAR (20) NOT NULL

    CONSTRAINT [pk_game_types_lookup_game_type_name] primary key(game_type_name)
 --   CONSTRAINT u_games_types_lookup_game_type_name unique (game_type_name)
)

GO

CREATE TABLE stadium_types_lookup (
     stadium_type VARCHAR (20) NOT NULL

    CONSTRAINT pk_stadium_types_lookup_stadium_type primary key(stadium_type)
 
)

GO

CREATE TABLE stadiums (
    stadium_id INT IDENTITY NOT NULL, 
    stadium_name VARCHAR (50) NOT NULL,
    stadium_zipcode int NOT NULL,
    stadium_street VARCHAR (50) NOT NULL,
    stadium_contact VARCHAR (100),
    stadium_capacity int,
    stadium_type varchar (20) NOT NULL,
    stadium_city CHAR(50) NOT NULL,
    CONSTRAINT pk_stadiums_stadium_id primary key(stadium_id),
    CONSTRAINT u_stadiums_stadium_name unique (stadium_name),
    CONSTRAINT cc_stadium_zipcode_positive CHECK (stadium_zipcode !< 0),
    CONSTRAINT cc_stadium_capacity_positive CHECK (stadium_capacity !< 0)
)

ALTER TABLE stadiums
    add CONSTRAINT fk_stadiums_stadium_type foreign key (stadium_type)
    REFERENCES stadium_types_lookup (stadium_type)

GO

CREATE TABLE restaurants (
    restaurant_id INT IDENTITY NOT NULL, 
    restaurant_name VARCHAR (50) NOT NULL,
    restaurant_zipcode int NOT NULL,
    restaurant_street VARCHAR (50),  
    restaurant_rating int NOT NULL,
    restaurant_city CHAR (50) NOT NULL,
    restaurant_stadium_id INT NOT NULL

    CONSTRAINT pk_restaurants_restaurant_id primary key(restaurant_id),
    CONSTRAINT comp_u_restaurants_restaurant unique (restaurant_name,restaurant_zipcode,restaurant_street, restaurant_city),
    CONSTRAINT cc_restaurant_zipcode_positive CHECK (restaurant_zipcode !< 0),
    CONSTRAINT cc_restaurant_rating_positive CHECK (restaurant_rating !< 0)
    
)

ALTER TABLE restaurants
    add CONSTRAINT fk_restaurants_restaurant_stadium_id foreign key (restaurant_stadium_id)
    REFERENCES stadiums (stadium_id)

GO

CREATE TABLE hotels (
    hotel_id INT IDENTITY NOT NULL, 
    hotel_name VARCHAR (50) NOT NULL,
    hotel_zipcode int NOT NULL,
    hotel_street VARCHAR (50),  
    hotel_rating int NOT NULL,
    hotel_city CHAR (20) NOT NULL,
    hotel_price MONEY NOT NULL,
    hotel_stadium_id INT NOT NULL,

    CONSTRAINT pk_hotel_hotel_id primary key(hotel_id),
    CONSTRAINT comp_u_hotels_hotel unique (hotel_name, hotel_city,hotel_zipcode,hotel_street),
    CONSTRAINT cc_hotel_zipcode_positive CHECK (hotel_zipcode !< 0),
    CONSTRAINT cc_hotel_rating_positive CHECK (hotel_rating !< 0)
    
)

ALTER TABLE hotels 
    add CONSTRAINT fk_hotels_hotel_stadium_id foreign key (hotel_stadium_id)
    REFERENCES stadiums (stadium_id)

GO

CREATE TABLE teams (
    team_id INT IDENTITY NOT NULL, 
    team_name VARCHAR (100) NOT NULL,
    team_website VARCHAR (100) ,
    team_coach_firstname CHAR (50) , 
    team_coach_lastname CHAR (50) ,
    team_game_type VARCHAR (20) NOT NULL

    CONSTRAINT pk_teams_team_id primary key(team_id),
    CONSTRAINT u_teams_team_website unique (team_website)
)

ALTER TABLE teams 
    add CONSTRAINT fk_teams_team_game_type foreign key (team_game_type)
    REFERENCES game_types_lookup (game_type_name)

GO
CREATE TABLE games (
    game_id INT IDENTITY NOT NULL, 
    game_type VARCHAR (20) NOT NULL,
    game_name VARCHAR (100) NOT NULL,
    team_away_name VARCHAR (100) NOT NULL,
    team_home_name VARCHAR (100) NOT NULL,
    game_date DATETIME NULL,
    game_hometeam_id INT NOT NULL,
    game_awayteam_id INT NOT NULL,
    game_stadium_id INT NOT NULL,
    CONSTRAINT pk_game_game_id primary key(game_id),
    CONSTRAINT u_game_game_name unique (game_name)
)


ALTER TABLE games 
    add CONSTRAINT fk_games_game_type_name foreign key (game_type)
    REFERENCES game_types_lookup (game_type_name)

ALTER TABLE games
    add CONSTRAINT fk_games_hometeam_id foreign key (game_hometeam_id)
    REFERENCES teams (team_id)

ALTER TABLE games
    add CONSTRAINT fk_games_awayteam_id foreign key (game_awayteam_id)
    REFERENCES teams (team_id)

ALTER TABLE games 
    add CONSTRAINT fk_games_stadium_id foreign key (game_stadium_id)
    REFERENCES stadiums (stadium_id)


GO

CREATE TABLE tickets (
    ticket_id INT IDENTITY NOT NULL, 
    ticket_serial_no VARCHAR (50) NOT NULL,
    total_number_of_tickets int,
    ticket_price money NOT NULL,
    ticket_available INT,
    ticket_game_id INT NOT NULL,
    
    CONSTRAINT pk_tickets_ticket_id primary key(ticket_id),
    CONSTRAINT u_tickets_ticket_serial_no unique (ticket_serial_no),
    CONSTRAINT CC_tickets_ticket_available_positive CHECK (ticket_available !< 0),
    CONSTRAINT CC_tickets_total_number_of_tickets_positive CHECK (total_number_of_tickets !< 0)
    
)

ALTER TABLE tickets 
    add CONSTRAINT fk_tickets_ticket_game_id foreign key (ticket_game_id)
    REFERENCES games(game_id)

ALTER TABLE tickets 
    add ticket_status VARCHAR (20) NOT NULL
    CONSTRAINT df_tickets_ticket_status default 'Available'

GO

--TRIGGERS
DROP trigger if exists t_no_tickets
GO

CREATE TRIGGER t_no_tickets
ON tickets
AFTER insert, update
AS BEGIN
update tickets
    set ticket_status = 'Sold'
    WHERE ticket_available = 0
END

-- GO
-- update tickets set ticket_available = 0 where ticket_game_id=1
-- SELECT * FROM tickets
---
GO
--UP DATA

GO
insert into game_types_lookup
    (game_type_name)
    VALUES
    ('Football'),('Basketball'), ('Baseball')

GO
insert into stadium_types_lookup
    (stadium_type)
    VALUES
    ('open'),('oval'), ('horseshoe'), ('closed')

GO

INSERT INTO stadiums (stadium_name, stadium_zipcode, stadium_street, stadium_type, stadium_contact, stadium_capacity, stadium_city) 
VALUES ('Yankee Stadium', 10451, '1 East 161st Street, Bronx', 'open', '(718) 293-4300',54251,'New York')
,('Citi Field', 11368, '41 Seaver Way,Location, Flushing, Queens', 'oval', '(718) 507-8499',41922,'New York')
, ('Madison Square Garden', 10001, '7th Ave & 32nd Street', 'horseshoe', '(212) 465-6741',20789,'New York')
, ('Barclays Center', 940106, 'Atlantic Avenue', 'open', '(917) 618-6100',19000,'San Francisco')
, ('JMA Wireless Dome', 13244, '900 Irving Ave, Syracuse', 'closed', 'dometix@syr.edu',49057,'Syracuse')
, ('UB Stadium', 14260, '102 Alumni Arena, Buffalo', 'closed', '(716) 645-3946',29013,'Buffalo')

GO
INSERT INTO hotels (hotel_name, hotel_city, hotel_zipcode,hotel_rating,hotel_price,hotel_street,hotel_stadium_id) 
VALUES ('Marriotte','New York',10451,4,10,'genesee',1)
,('Sheraton','New York',11368,3,40,'baldwin',2)
,('Eko hotels en suites','New York',10001,1,20,'university ave',3)
,('Clarks','San Francisco',940106,2,30,'salino',4)
,('We love wings','Syracuse',13244,4,25,'east araba',5)
,('Axencture','Buffalo',14260,3,33,'half road',6)
,('Dark side','Syracuse',13244,3,76,'full road',5)
,('Light side','Buffalo',14260,5,15,'runaway',6)
,('williams and sons','New York',11368,2,65,'right way',2)
,('Holiday Inn','New York',10001,3,23,'left way',3)    



GO

INSERT INTO restaurants (restaurant_name, restaurant_zipcode, restaurant_street, restaurant_city,restaurant_rating,restaurant_stadium_id) 
VALUES ('pizza republic',10451,'300 University avenue' ,'New York',4,1)
,('tasty sweeties',11368,'114 N Lorraine','New York',3,2)
,('taste of france',10001,'100 Euclid avenue','New York',1,3)
,('pastaroni',940106,'414 Greenland Parkway','San Francisco',2,4)
,('rice goodies',13244,'200 Fisher Avenue','Syracuse',4,5)
,('tasty sweeties',14260,'125 Westcott','Buffalo',3,6)
,('chicken lungu',13244,'503 Madison street','Syracuse',3,5)
,('only sauce',14260,'335 Comstock street','Buffalo',5,6)
,('pastaroni',11368,'321 Ackerman avenue ','New York',2,2)
,('pizza republic',10001,'521 Marshall Street','New York',3,3)


GO

INSERT INTO teams (team_name, team_game_type, team_website,team_coach_firstname, team_coach_lastname) 
VALUES ('Purdue University Boilermakers Football','Football', 'www.purdueBoilermakers.com', 'Dumble', 'Door') 
,('Indianapolis Colts','Football', 'www.indianapolis.com', 'Volde', 'Mort')
,('New York Yankees', 'Baseball','www.NYankees.com', 'Ricky', 'Martin')
,('Miami Marlins', 'Baseball','www.MiamiMarlins.com','Micheal', 'Jackson' )
,('Portland Trail Blazers','Basketball','www.PttrailBLazer.com', 'George', 'Clooney')
,('Portland Warriors','Basketball', 'wwwPtWarriors.com', 'Brad', 'Pitt')
, ('Bucknell','Football','www.Bucknell.com', 'Robert', 'Downey')
, ('Oakland University Golden Grizzlies','Basketball','www.OaklandGrizzlies.com', 'Jason', 'Mamoa')
, ('Kent State University Golden Flashes', 'Basketball','www.KentFlashes.com', 'Clark', 'Kent')
, ('Syracuse University Orange Football', 'Football','www.Syracuse.com', 'Ernie', 'Davis')
,('New York Giants','Baseball','www.NYGiants.com','Steve', 'Jobs' )
,('San Francisco Giants','Baseball', 'www.SanFranciscoGiants.com', 'Taylor', 'Swift')
, ('New York Mets','Baseball','www.NewyoukMets.com', 'Angelina', 'Jolie')
, ('New York Knicks','Basketball', 'www.NewYorknicks.com', 'Tom', 'Hanks')
, ('Brooklyn Nets','Basketball','www.BrooklynNets.com', 'Steve','Carell')
,('Syracuse University Women Basketball','Basketball', 'www.syracusewomenbasket.com', 'Gal', 'Gadot')
, ('Syracuse University Men Basketball','Basketball','www.syracusemenbasket.com','Chris', 'Helmsworth')
, ('University at Buffalo Bulls','Football','www.buffalobulls.com', 'Chris','Evans')


/*
UPDATE teams
SET team_game_type = 'Alfred Schmidt'
WHERE team_name='Purdue University Boilermakers Football';
*/

GO

INSERT INTO games (game_name, game_type, team_away_name, team_home_name, game_date, game_stadium_id, game_hometeam_id, game_awayteam_id) 
VALUES ('Syracuse vs Purdue', 'Football', 'Purdue University Boilermakers Football', 'Syracuse University Orange Football', '2022-11-12', 4, 10, 1)
,('New York Giants vs. Indianapolis Colts', 'Football', 'Indianapolis Colts', 'New York Giants', '2022-11-13',3, 11, 2)
,('New York Yankees vs. San Francisco Giants', 'Baseball', 'New York Yankees', 'San Francisco Giants','2022-11-14',4, 12, 3)
, ('New York Mets vs. Miami Marlins', 'Baseball', 'Miami Marlins', 'New York Mets', '2022-11-15',2 ,13, 4)
, ('New York Knicks vs. Portland Trail Blazers', 'Basketball', 'Portland Trail Blazers', 'New York Knicks','2022-11-16', 1,14, 5)
, ('Brooklyn Nets vs. Portland Warriors', 'Basketball', 'Portland Warriors', 'Brooklyn Nets','2022-11-17',6, 15, 6)
,('Syracuse Womens Basketball vs. Bucknell Womens Basketball', 'Basketball', 'Bucknell', 'Syracuse University Women Basketball', '2022-11-18', 5, 16, 7)
,('Syracuse University Men Basketball vs. Oakland University Golden Grizzlies Mens Basketball', 'Basketball', 'Oakland University Golden Grizzlies', 'Syracuse University Men Basketball', '2022-11-19',5, 17, 8)
,('University at Buffalo Bulls Football vs. Kent State University Golden Flashes Football', 'Football', 'Kent State University Golden Flashes', 'University at Buffalo Bulls','2022-11-20',6,18, 9)


GO


INSERT INTO tickets (ticket_serial_no, total_number_of_tickets, ticket_price, ticket_available, ticket_game_id) 
VALUES ('153-1001', '1000', '35', 200, 1)
, ('153-1002','1000', '100', 100, 2)
, ('153-1004', '2500', '75', 0, 4)
, ('153-1003',2500 ,'49', 500, 3)
, ('153-1005', 5000,'98', 1000, 5)
, ('153-1006', 7000,'10', 3500, 6)
, ('153-1007', 5000 ,'20', 0,7)
, ('153-1008', 2500,'40', 2300,8)
, ('153-1009', 3000,'10', 0, 9)
, ('163-1001', 6000,'20', 125,1)

--VERIFY

SELECT * FROM teams
SELECT * FROM stadiums
SELECT * FROM game_types_lookup
SELECT * FROM stadium_types_lookup
SELECT * FROM games
SELECT * FROM hotels
SELECT * FROM restaurants
SELECT * FROM tickets


GO
--------------------------------------------------------------------------------------------------------------------
---VIEWS---

--VIEW 1--
-- What are the hotels and restaurants available near the stadium? 
drop VIEW restaurants_and_hotels
GO
create view restaurants_and_hotels as 
    select s.stadium_name, h.hotel_name, r.restaurant_name, s.stadium_city,
        CASE WHEN s.stadium_zipcode=r.restaurant_zipcode AND s.stadium_zipcode=h.hotel_zipcode 
        THEN 'Both is near'
        WHEN s.stadium_zipcode!=h.hotel_zipcode AND s.stadium_zipcode !=h.hotel_zipcode then 'Far'
        ELSE 'Either is Far'
        END AS hotel_restaurant_distance
    from stadiums as s
        join hotels as h on h.hotel_city =  s.stadium_city
        join restaurants as r on r.restaurant_city = s.stadium_city
      --  group by s.stadium_name, h.hotel_name, r.restaurant_name, s.stadium_city
GO

SELECT * FROM restaurants_and_hotels
---VIEW 2---
-- What game is held, between whom, where (city,stadium) and contact of place

GO  
drop VIEW game_details
GO
create view game_details as 
    select  g.game_name, g.game_type, g.team_away_name, g.team_home_name, g.game_date, s.stadium_name, s.stadium_city,s.stadium_contact
    FROM games AS g
    JOIN stadiums AS s on s.stadium_id=g.game_stadium_id
    GROUP BY  g.game_name, g.game_type, g.team_away_name, g.team_home_name, g.game_date, s.stadium_name, s.stadium_city,s.stadium_contact
GO

SELECT * FROM game_details

---VIEW 3---
-- what is the ticket price and availability of the different games? 
GO
drop VIEW ticket_stadium
GO
create view ticket_stadium as 
    select  g.game_name, g.game_date, s.stadium_name,  t.total_number_of_tickets, t.ticket_available, t.ticket_status, t.ticket_price
    FROM games AS g
    JOIN tickets AS t on t.ticket_game_id=g.game_id
    JOIN stadiums AS s on s.stadium_id=g.game_stadium_id
    GROUP BY  g.game_name, g.game_date, s.stadium_name,  t.total_number_of_tickets,t.ticket_available, t.ticket_status, t.ticket_price
GO

SELECT * FROM ticket_stadium
GO
---------------------------------------------------------------------------------------------
-- TRIGGER EXAMPLE
update tickets set ticket_available = 0 where ticket_game_id=1

SELECT * FROM tickets
-------------------------------------------------------------------------------

--PROCEDURES 1
---Procedure to update or insert new teams into teams table---
drop procedure if exists p_upsert_teams
GO
create procedure p_upsert_teams (
    @team_name VARCHAR (100) ,
    @team_website VARCHAR (100) ,
    @team_coach_firstname CHAR (50) , 
    @team_coach_lastname CHAR (50) ,
    @team_game_type VARCHAR (20)
) as begin
if exists(select * from teams where team_name = @team_name) begin 
update teams set team_website=@team_website,
team_coach_firstname=@team_coach_firstname, team_coach_lastname=@team_coach_lastname, team_game_type=@team_game_type
where team_name = @team_name
end
else begin
insert into teams (team_name, team_website,team_coach_firstname,team_coach_lastname,team_game_type) 
values (@team_name, @team_website,@team_coach_firstname,@team_coach_lastname,@team_game_type) 
end
end 
GO

---DEMONSTRATION FOR PROCEDURE 1
select * from teams
EXEC p_upsert_teams
@team_name='New York Giants', @team_website='www.NYGiants.com',@team_coach_firstname='Christian',@team_coach_lastname='Bale',@team_game_type='Football' 

EXEC p_upsert_teams
@team_name='Gryffindor', @team_website='www.gryfiindor.com',@team_coach_firstname='Dumble',@team_coach_lastname='Door',@team_game_type='Football' 

---Procedure 2---
-- Procedure to warn database admin to update teams table first before adding new teams to games table
drop procedure if exists p_upsert_games
GO
create procedure p_upsert_games (
    @game_type VARCHAR (20),
    @game_name VARCHAR (100) ,
    @team_away_name VARCHAR (100),
    @team_home_name VARCHAR (100) ,
    @game_date DATETIME
) as begin
    begin TRY
    begin TRANSACTION
    update games set game_type=@game_type, game_name=@game_name,
    team_away_name=@team_away_name, team_home_name=@team_home_name, game_date=@game_date,
    game_awayteam_id=(select team_id from teams where team_name=@team_away_name),
    game_hometeam_id=(select team_id from teams where team_name=@team_home_name)
    print 'committing'
    commit 
    end try
    begin CATCH
    throw 50001, 'Please first insert the new team into teams', 1
        rollback 
    end CATCH
END

---DEMONSTRATION FOR PROCEDURE 2
EXEC p_upsert_games
@game_type='Football', @game_name='New York Giants Vs New York Tiny', @team_away_name='New York Giants',@team_home_name='New York Tiny',
@game_date='2022-11-29'

---

