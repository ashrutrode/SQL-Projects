# get user_response
user_input = request.get_json()

# get the start and end dates
startDate = user_input[0]
endDate = user_input[1]

# convert to int then back to str
startDate = str(int(startDate))
endDate = str(int(endDate))

# create connection
conn = mysql.connector.connect(
	host = dbhost,
	user = dbuser,
	password = dbpass,
	database = dbname
)
cursor = conn.cursor()

# insert data into database
def data_insertion():

	# extracting data from csv
	import csv
	file = open("static/data/tsla.csv", "r")
	tsla_data = list(csv.reader(file, delimiter=","))
	file.close()

	# convert all the data - skip 0th element since its the column name
	for i in range(1, len(tsla_data)):

		# convert the first element (the date) to a numerical format of YYYYMMDD
		date = tsla_data[i][0]
		year = "20"+date[6:8]
		month = date[:2]
		day = date[3:5]
		dateNum = int(year+month+day)
		tsla_data[i][0] = dateNum

		# convert the open, high, low, close data to floats
		for j in range(1, 5):
		    tsla_data[i][j] = float(tsla_data[i][j])

		# delete last element, the volume
		tsla_data[i] = tsla_data[i][:-1]

	# display the result
	print("Step #1: The count of the array is " + str(len(tsla_data)) + ".");

	# sql to create the table
	sql = '''CREATE TABLE tsla_stock (
		date INT,
		open FLOAT,
		high FLOAT,
		low FLOAT,
		close FLOAT
	)'''
	#cursor.execute(sql)
	#result = cursor.fetchall()

	# display the result
	print("Step #2: The table tsla_stock was successfully created.");
	
	# inserting data into table
	row_counter = 0
	for i in range(1, len(tsla_data)):

		# get all information
		date = tsla_data[i][0];
		open_ = tsla_data[i][1];
		high = tsla_data[i][2];
		low = tsla_data[i][3];
		close = tsla_data[i][4];

		# peform the query
		sql = f"INSERT INTO tsla_stock (date, open, high, low, close) VALUES ({date}, {open_}, {high}, {low}, {close})";
		cursor.execute(sql)
		result = cursor.fetchall()

		# iterate the counter if successful
		if result:
			row_counter = row_counter + 1

	# show the results
	print("Step #3: " + str(row_counter) + " rows were inserted.")

# result function
def show_result(result):
	for x in result: 
		print(x)

# get data
def get_data():

	# all stock prices
	sql = '''SELECT * 
		FROM tsla_stock 
		WHERE date >= %s AND date <= %s'''
	sql_tuple = (startDate, endDate)
	cursor.execute(sql, sql_tuple)
	result = cursor.fetchall()
	#show_result(result)

	# stock price: highest
	sql = '''SELECT close 
			FROM tsla_stock 
			WHERE date >= %s AND date <= %s
			ORDER BY close DESC
			LIMIT 1'''
	sql_tuple = (startDate, endDate)
	cursor.execute(sql, sql_tuple)
	result = cursor.fetchall()
	stock_price_highest = result[0][0]
	#show_result(result)

	# stock price: lowest
	sql = '''SELECT low 
			FROM tsla_stock 
			WHERE date >= %s AND date <= %s
			ORDER BY close ASC
			LIMIT 1'''
	sql_tuple = (startDate, endDate)
	cursor.execute(sql, sql_tuple)
	result = cursor.fetchall()
	stock_price_lowest = result[0][0]
	#show_result(result)

	# stock price: average
	sql = '''SELECT AVG(close) 
			FROM tsla_stock 
			WHERE date >= %s AND date <= %s'''
	sql_tuple = (startDate, endDate)
	cursor.execute(sql, sql_tuple)
	result = cursor.fetchall()
	stock_price_average = result[0][0]
	#show_result(result)

	# stock price: median

	# first, get the number of rows in the dates
	sql = '''SELECT COUNT(*) 
			FROM tsla_stock 
			WHERE date >= %s AND date <= %s'''
	sql_tuple = (startDate, endDate)
	cursor.execute(sql, sql_tuple)
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
		sql = '''SELECT AVG(close)
					FROM (
						SELECT close 
						FROM tsla_stock 
						WHERE date >= %s AND date <= %s
						LIMIT %s, 2
					) q'''
		sql_tuple = (startDate, endDate, median_row_minus1)
		cursor.execute(sql, sql_tuple)
		result = cursor.fetchall()
		stock_price_median = result[0][0]
		#show_result(result)

	# count odd
	elif count_rows%2 == 1:
	    
		# mysql rows start at 1, so +1 and divide by 2 to get median row
		median_row = (count_rows+1)/2;
		median_row_minus1 = int(median_row-1);

		# to get the nth row (rows start at 1, not 0), we do LIMIT n-1, 1
		sql = '''SELECT close 
			FROM tsla_stock 
			WHERE date >= %s AND date <= %s
			LIMIT %s, 1'''
		sql_tuple = (startDate, endDate, median_row_minus1)
		cursor.execute(sql, sql_tuple)
		result = cursor.fetchall()
		stock_price_median = result[0][0]
		#show_result(result)

	# standard deviation
	sql = '''SELECT STDDEV(close) 
			FROM tsla_stock
			WHERE date >= %s AND date <= %s'''
	sql_tuple = (startDate, endDate)
	cursor.execute(sql, sql_tuple)
	result = cursor.fetchall()
	stock_price_stddev = result[0][0]
	#show_result(result)

	# the result
	return [stock_price_highest, stock_price_lowest, stock_price_average, stock_price_median, stock_price_stddev]

# call function
#data_insertion()
data_to_return = get_data()

# return the result
return jsonify(data_to_return)
