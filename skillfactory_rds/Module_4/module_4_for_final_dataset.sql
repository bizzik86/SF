WITH main_t AS
  (SELECT f.*,
          extract(epoch
                  FROM (f.actual_arrival - f.actual_departure))/3600 AS fligth_hour
   FROM dst_project.flights f
   WHERE f.departure_airport = 'AAQ'
     AND (date_trunc('month', f.scheduled_departure) in ('2017-01-01',
                                                         '2017-02-01',
                                                         '2017-12-01'))
     AND f.status not in ('Cancelled') )
SELECT m.flight_id,
       m.flight_no,
       m.scheduled_departure,
       to_char(m.scheduled_departure, 'Day') AS week_day,
       dist.arrival_airport_code,
       dist.arrival_city,
       dist.distance_km,
	   m.fligth_hour,
       m.fligth_hour*cost_km.fuel_cost_value AS fuel_sum_amnt,
       am.amnt AS tickets_sum_amnt,
       am.amnt - m.fligth_hour*cost_km.fuel_cost_value AS profit,
       aircraft_seats.seats_num,
       am.ticket_numbers,
       am.ticket_numbers::decimal/aircraft_seats.seats_num AS percent_fill
FROM main_t m
LEFT JOIN
  (SELECT f.flight_id,
          sum(amount) AS amnt,
          count(1) AS ticket_numbers
   FROM main_t f
   JOIN dst_project.ticket_flights tf ON f.flight_id = tf.flight_id
   GROUP BY f.flight_id) am ON m.flight_id = am.flight_id -- для стоимости топлива высчитываем стоимость топлива на час полета
LEFT JOIN
  (SELECT fuel_cons.aircraft_code,
          fuel_cost.dat,
          fuel_cons.ton_per_hour * fuel_cost.ton_cost AS fuel_cost_value
   FROM
     (SELECT '2017-01-01' AS dat,
             41435 + 41435*0.18 AS ton_cost
      UNION SELECT '2017-02-01' AS dat,
                   39553 + 39553*0.18 AS ton_cost
      UNION SELECT '2017-12-01' AS dat,
                   47101 + 47101*0.18 AS ton_cost) fuel_cost
   JOIN
     (SELECT '733' AS aircraft_code,
             2.6 AS ton_per_hour
      UNION SELECT 'SU9' AS aircraft_code,
                   1.7 AS ton_per_hour) fuel_cons ON 1=1)cost_km ON cost_km.aircraft_code = m.aircraft_code
AND date_trunc('month', m.actual_departure) = cost_km.dat::date
LEFT JOIN
  (SELECT a.aircraft_code,
          count(s.seat_no) AS seats_num
   FROM dst_project.aircrafts a
   JOIN dst_project.seats s ON s.aircraft_code = a.aircraft_code
   WHERE a.aircraft_code in
       (SELECT DISTINCT aircraft_code
        FROM main_t)
   GROUP BY a.aircraft_code) aircraft_seats ON aircraft_seats.aircraft_code = m.aircraft_code
LEFT JOIN
  (SELECT t.departure_airport_code,
          da.city AS departure_city,
          t.arrival_airport_code,
          aa.city AS arrival_city,
          round((acos(sin(radians(da.latitude)) * sin(radians(aa.latitude)) + cos(radians(da.latitude)) * cos(radians(aa.latitude)) * cos(radians(da.longitude) - radians(aa.longitude))) * 6378137)::numeric/1000, 0) AS distance_km
   FROM
     (SELECT DISTINCT f.departure_airport AS departure_airport_code,
                      f.arrival_airport AS arrival_airport_code
      FROM main_t f)t
   JOIN dst_project.airports da ON da.airport_code = t.departure_airport_code
   JOIN dst_project.airports aa ON aa.airport_code = t.arrival_airport_code) dist ON m. departure_airport = dist.departure_airport_code
AND m.arrival_airport = dist.arrival_airport_code
ORDER BY am.ticket_numbers::decimal/aircraft_seats.seats_num,
         am.amnt - m.fligth_hour*cost_km.fuel_cost_value;