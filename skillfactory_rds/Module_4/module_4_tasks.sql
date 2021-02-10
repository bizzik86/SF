-- 4.1
SELECT city,
       count(1)
FROM dst_project.airports
GROUP BY city
HAVING count(1)>1;

-- 4.2
SELECT count(DISTINCT status)
FROM dst_project.flights ;

SELECT count(1)
FROM dst_project.flights
WHERE status = 'Departed';

SELECT count(s.seat_no)
FROM dst_project.aircrafts a
JOIN dst_project.seats s ON s.aircraft_code = a.aircraft_code
WHERE a.aircraft_code = '773'

SELECT count(1)
FROM dst_project.flights
WHERE (actual_departure BETWEEN '2017-04-01' AND '2017-09-01'
       OR actual_arrival BETWEEN '2017-04-01' AND '2017-09-01')
  AND status = 'Arrived'
  
-- 4.3
SELECT count(1)
FROM dst_project.flights
WHERE status = 'Cancelled';

SELECT CASE
           WHEN model like 'Boeing%' THEN 'Boeing'
           WHEN model like 'Sukhoi Superjet%' THEN 'Sukhoi Superjet'
           WHEN model like 'Airbus%' THEN 'Airbus'
       END AS main_model,
       count(1)
FROM dst_project.aircrafts
WHERE model like 'Boeing%'
  OR model like 'Sukhoi Superjet%'
  OR model like 'Airbus%'
GROUP BY CASE
             WHEN model like 'Boeing%' THEN 'Boeing'
             WHEN model like 'Sukhoi Superjet%' THEN 'Sukhoi Superjet'
             WHEN model like 'Airbus%' THEN 'Airbus'
         END
		 
SELECT left(timezone, position('/' in timezone) - 1) AS region,
       count(1)
FROM dst_project.airports a
GROUP BY left(timezone, position('/' in timezone) - 1)
ORDER BY 2 DESC

SELECT f.flight_id,
       f.actual_arrival - f.scheduled_arrival
FROM dst_project.flights f
WHERE f.actual_arrival IS NOT NULL
ORDER BY 2 DESC

-- 4.4
SELECT min(scheduled_departure)
FROM dst_project.flights f

SELECT extract(epoch
               FROM
                 (SELECT max(f.scheduled_arrival - f.scheduled_departure)
                  FROM dst_project.flights f))/60

SELECT DISTINCT departure_airport,
                arrival_airport
FROM dst_project.flights f
WHERE f.scheduled_arrival - f.scheduled_departure =
    (SELECT max(f.scheduled_arrival - f.scheduled_departure)
     FROM dst_project.flights f)
 
SELECT trunc(extract(epoch
                     FROM
                       (SELECT avg(f.scheduled_arrival - f.scheduled_departure)
                        FROM dst_project.flights f))/60)
						
-- 4.5						
SELECT fare_conditions,
       count(1)
FROM dst_project.seats
WHERE aircraft_code = 'SU9'
GROUP BY fare_conditions
ORDER BY 2 DESC
LIMIT 1		

SELECT min(total_amount)
FROM dst_project.bookings

SELECT bp.seat_no
FROM dst_project.tickets t
JOIN dst_project.boarding_passes bp ON t.ticket_no = bp.ticket_no
WHERE t.passenger_id = '4313 788533'		

-- 5.1
SELECT count(1)
FROM dst_project.airports a
JOIN dst_project.flights f ON a.airport_code = f.arrival_airport
AND extract(YEAR
            FROM actual_arrival) = 2017
WHERE a.city = 'Anapa'		

SELECT count(1)
FROM dst_project.airports a
JOIN dst_project.flights f ON a.airport_code = f.departure_airport
AND extract(YEAR
            FROM actual_arrival) = 2017
AND extract(MONTH
            FROM actual_arrival) in (1,
                                     2,
                                     12)
WHERE a.city = 'Anapa'

SELECT count(1)
FROM dst_project.airports a
JOIN dst_project.flights f ON a.airport_code = f.departure_airport
AND status = 'Cancelled'
WHERE a.city = 'Anapa'

SELECT count(1)
FROM dst_project.airports a
JOIN dst_project.flights f ON a.airport_code = f.departure_airport
AND f.arrival_airport not in
  (SELECT airport_code
   FROM dst_project.airports a
   WHERE a.city = 'Moscow')
WHERE a.city = 'Anapa'

SELECT air.model,
       count(1)
FROM
  (SELECT DISTINCT aircraft_code
   FROM dst_project.airports a
   JOIN dst_project.flights f ON a.airport_code = f.departure_airport
   WHERE a.city = 'Anapa' )ac
JOIN dst_project.aircrafts air ON air.aircraft_code = ac.aircraft_code
JOIN dst_project.seats s ON s.aircraft_code = air.aircraft_code
GROUP BY air.model
ORDER BY 2 DESC

