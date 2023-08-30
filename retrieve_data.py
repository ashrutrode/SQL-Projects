# get the start and end dates
startDate = user_input[0]
endDate = user_input[1]

# convert to int then back to str
startDate = str(int(startDate))
endDate = str(int(endDate))

# login credentials for mySQL database
# insert your own credentials here
dbhost = "XXXXXX";
dbuser = "XXXXXX";
dbpass = "XXXXXX";
dbname = "XXXXXX";

# create connection
conn = mysql.connector.connect(
	host = dbhost,
	user = dbuser,
	password = dbpass,
	database = dbname
)
cursor = conn.cursor()

# result function
def show_result(result):
for x in result: 
	print(x)

# get data
def get_data():

	# all stock prices
	sql = f'''SELECT * 
		FROM tsla_stock 
		WHERE date >= {startDate} AND date <= {endDate}'''
	cursor.execute(sql)
	result = cursor.fetchall()
	#show_result(result)

	# stock price: highest
	sql = f'''SELECT close 
			FROM tsla_stock 
			WHERE date >= {startDate} AND date <= {endDate}
			ORDER BY close DESC
			LIMIT 1'''
	cursor.execute(sql)
	result = cursor.fetchall()
	stock_price_highest = result[0][0]
	#show_result(result)

	# stock price: lowest
	sql = f'''SELECT low 
			FROM tsla_stock 
			WHERE date >= {startDate} AND date <= {endDate}
			ORDER BY close ASC
			LIMIT 1'''
	cursor.execute(sql)
	result = cursor.fetchall()
	stock_price_lowest = result[0][0]
	#show_result(result)

	# stock price: average
	sql = f'''SELECT AVG(close) 
			FROM tsla_stock 
			WHERE date >= {startDate} AND date <= {endDate}'''
	cursor.execute(sql)
	result = cursor.fetchall()
	stock_price_average = result[0][0]
	#show_result(result)

	# stock price: median

	# first, get the number of rows in the dates
	sql = f'''SELECT COUNT(*) 
			FROM tsla_stock 
			WHERE date >= {startDate} AND date <= {endDate}'''
	cursor.execute(sql)
	result = cursor.fetchall()
	count_rows = result[0][0];
	#show_result(result)

	# second, find the average based on whether there are
	# an even or odd number of rows returned

	# count even
	if count_rows%2 == 0:

		# get the first median by dividing by 2 
		median_row = count_rows/2;
		median_row_minus1 = int(median_row-1);

		# get the nth row, plus next element since we need average of the two medians
		sql = f'''SELECT AVG(close)
					FROM (
						SELECT close 
						FROM tsla_stock 
						WHERE date >= {startDate} AND date <= {endDate}
						LIMIT {median_row_minus1}, 2
					) q''' 
		cursor.execute(sql)
		result = cursor.fetchall()
		stock_price_median = result[0][0]
		#show_result(result)

	# count odd
	elif count_rows%2 == 1:
	    
		# mysql rows start at 1, so +1 and divide by 2 to get median row
		median_row = (count_rows+1)/2;
		median_row_minus1 = int(median_row-1);

		# to get the nth row (rows start at 1, not 0), we do LIMIT n-1, 1
		sql = f'''SELECT close 
			FROM tsla_stock 
			WHERE date >= {startDate} AND date <= {endDate}
			LIMIT {median_row_minus1}, 1'''
		cursor.execute(sql)
		result = cursor.fetchall()
		stock_price_median = result[0][0]
		#show_result(result)

	# standard deviation
	sql = f'''SELECT STDDEV(close) 
			FROM tsla_stock
			WHERE date >= {startDate} AND date <= {endDate}'''
	cursor.execute(sql)
	result = cursor.fetchall()
	stock_price_stddev = result[0][0]
	#show_result(result)

	# the result
	return [stock_price_highest, stock_price_lowest, stock_price_average, stock_price_median, stock_price_stddev]

# call function
data_to_return = get_data()

# print the result
print(data_to_return)
