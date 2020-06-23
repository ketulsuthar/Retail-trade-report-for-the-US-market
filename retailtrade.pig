
-- Load 2000 sales data
sales2000 = LOAD '2000.txt' using PigStorage(',') as (prod_id:long, product:chararray, jan:double, feb:double, mar:double, apr:double, may:double, jun:double, jul:double, aug:double, sep:double, oct:double, nov:double, dec:double);

-- Load 2001 Sale data
sales2001 = LOAD '2001.txt' using PigStorage(',') as (prod_id:long, product:chararray, jan:double, feb:double, mar:double, apr:double, may:double, jun:double, jul:double, aug:double, sep:double, oct:double, nov:double, dec:double);

--Load 2002 sales data
sales2002 = LOAD '2002.txt' using PigStorage(',') as (prod_id:long, product:chararray, jan:double, feb:double, mar:double, apr:double, may:double, jun:double, jul:double, aug:double, sep:double, oct:double, nov:double, dec:double);

-- Get total sales for 2000
totalsales2000 = FOREACH sales2000 GENERATE $0,$1,$2+$3+$4+$5+$6+$7+$8+$9+$10+$11+$12 as totalsales;

--Get total sales for 2001
totalsales2001 = FOREACH sales2001 GENERATE $0,$1,$2+$3+$4+$5+$6+$7+$8+$9+$10+$11+$12 as totalsales;

--Get total sales for 2002
totalsales2002 = FOREACH sales2002 GENERATE $0,$1,$2+$3+$4+$5+$6+$7+$8+$9+$10+$11+$12 as totalsales;

-- join 3 years sales data based on product id
joinsales = JOIN totalsales2000 by $0, totalsales2001 by $0, totalsales2002 by $0;

-- Get product id , product name, totalsale for 2000, 2001 and 2002
newsalesdata = FOREACH joinsales GENERATE $0,$1,$2,$5,$8;

-- Generate growth percentage
growthpercentage = FOREACH newsalesdata GENERATE $0,$1,$2,$3,$4,($3-$2)/$2*100, ($4-$3)/$2*100;

--Generate growth average
growthavg = FOREACH growthpercentage GENERATE $0,$1,$2,$3,$4,$5,$6,(($5+$6)/2);

-- Filter sales whose average growth percntage is more than 10.0
growth_ten_per = FILTER growthavg BY $7 >= 10.0;

-- Filter sales whose avarage percentage is less than -5.0
growth_five_per = FILTER growthavg BY $7 <= -5.0;

-- Calculate total sales
total_sales = FOREACH newsalesdata GENERATE $0, $1, ($2+$3+$4);

-- Top 5 sales
top5 = LIMIT ( ORDER total_sales BY $2 DESC) 5;

-- Bottom 5 sales
bottom5 = LIMIT (ORDER total_sales BY $2) 5;


STORE bottom5 INTO 'Bottom-5-Sales' using PigStorage(',');
STORE top5 INTO 'Top-10-Sales' using PigStorage(',');
STORE growth_ten_per INTO '10-Percentage-Growth' using PigStorage(',');
STORE growth_five_per INTO '5-Percentage-Growth' using PigStorage(',');
