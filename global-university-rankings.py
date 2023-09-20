	# get user_response
	user_input = request.get_json()

	# get the university, year, and country
	university_input = user_input[0]
	year_input = user_input[1]
	country_input = user_input[2]

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
		file = open("static/data/university.csv", "r", encoding='utf-8-sig')
		data = list(csv.reader(file, delimiter=","))
		file.close()

		# display the number of items received
		print("Step #1: The count of the array is " + str(len(data)) + ".")

		# sql to create the table
		sql = '''CREATE TABLE world_university_ranking (
			university TEXT,
			year YEAR(4),
			worldRank INT,
			country TEXT
		)'''

		# results
		try:
			cursor.execute(sql)
			result = cursor.fetchall()
			print("Step #2: Table world_university_ranking was successfully created.")
		except mysql.connector.Error as err:
			print("Here's the error: {}".format(err))
			exit()

		# inserting data into table
		row_counter = 0
		for i in range(1, len(data)):

			# get all information
			university = data[i][0]
			year = data[i][1]
			worldrank = int(data[i][2])
			country = data[i][3]

			# peform the query
			sql = f'''INSERT INTO world_university_ranking (university, year, worldRank, country) VALUES ("{university}", "{year}", "{worldrank}", "{country}")'''
			cursor.execute(sql)
			result = conn.commit()

			# iterate the counter if successful
			if result == None:
				row_counter = row_counter + 1

		# show the results
		print("Step #3: " + str(row_counter) + " rows were inserted.")

		# close database and exit
		conn.close()
		exit()

	# get data
	def get_data():

		# build sql query based on user inputs
		sql = 'SELECT * FROM world_university_ranking '

		# if at least one doesn't equal all, we need to build the WHERE clause
		sql_tuple = ()
		if not (university_input == "all" and year_input == "all" and country_input == "all"):
			sql = sql + 'WHERE '
			if university_input != "all":
				sql = sql + 'university=%s '
				sql_tuple = (university_input, )
			if year_input != "all":
				if len(sql_tuple) > 0:
					sql = sql + 'AND '
				sql = sql + 'year=%s '
				sql_tuple = sql_tuple + (year_input, )
			if country_input != "all":
				if len(sql_tuple) > 0:
					sql = sql + 'AND '
				sql = sql + 'country=%s '
				sql_tuple = sql_tuple + (country_input, )
		
		# last part of sql
		sql = sql + 'ORDER BY worldRank, year'
		cursor.execute(sql, sql_tuple)
		result = cursor.fetchall()

		# close connection
		conn.close()

		# create the html
		results_html = '''	<tr>
								<th>Rank</th>
								<th>University</th>
								<th>Year</th>
								<th>Country</th>
							</tr>
		'''
		for i in result:
			rank = str(i[2])
			university = i[0]
			year = str(i[1])
			country = i[3]
			results_html = results_html + \
									f'''<tr>
										<td>{rank}</td>
										<td>{university}</td>
										<td>{year}</td>
										<td>{country}</td>
									</tr>'''

		# return the result
		return results_html

	# call function
	#data_insertion()
	data_to_return = get_data()

	# return the result
	return jsonify(data_to_return)
