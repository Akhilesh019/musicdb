-- Who is the most senior employee based on job title?
select * from employee
order by levels desc
limit 1

-- Which countries have the most Invoices?
select count(*) as C,billing_country from invoice
group by billing_country
order by C desc

-- What are top three values of total invoices?
select total from invoice
order by total desc 
limit 3

-- Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most 
-- money. Write a query that returns one city that has the highest sum of invoice totals.
-- Return both the city name & sum of all invoice totals
select sum(total) as total_invoices, billing_city from invoice
group by billing_city
order by total_invoices desc

-- Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.
select customer.first_name, customer.last_name, invoice.customer_id, sum(total) as total from invoice
inner join customer 
on customer.customer_id = invoice.customer_id
group by invoice.customer_id,customer.first_name, customer.last_name
order by total desc
limit 1


-- Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
--Return your list ordered alphabetically by email starting with A
select distinct email, first_name, last_name from customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	Where genre.name LIKE 'Rock'
	)
order by email


-- Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands

select A.artist_id, Count(D.name) as count, A.name from artist A
join album B on A.artist_id = B.artist_id
join track C on B.album_id = C.album_id
join genre D on C.genre_id = D.genre_id
group by D.name, A.name, A.artist_id
having D.name = 'Rock'
order by count desc
limit 10


-- Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.

select track.name, track.milliseconds from track
where track.milliseconds > (select avg(track.milliseconds) from track)
order by milliseconds desc


-- Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

select A.first_name, A.last_name, F.name, sum(C.unit_price * C.quantity) from customer A
join invoice B on A.customer_id = B.customer_id
join invoice_line C on B.invoice_id = C.invoice_id
join track D on C.track_id = D.track_id
join album E on D.album_id = E.album_id
join artist F on E.artist_id = F.artist_id
group by A.first_name, A.last_name, F.name
order by sum(C.unit_price * C.quantity) desc


-- We want to find out the most popular music Genre for each country.
-- We determine the most popular genre as the genre with the highest amount of purchases. 
-- Write a query that returns each country along with the top Genre. 
-- For countries where the maximum number of purchases is shared return all Genres.

WITH popular_genre AS
(
	SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS ROWNO
	FROM invoice_line
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN traCK ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popUlar_genre WHERE ROWNO <= 1