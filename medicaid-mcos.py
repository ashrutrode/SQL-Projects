	# get user_response
	user_input = request.get_json()

	# get the logic sign, number of mcos, and centene present
	mco_contingent = user_input[0]
	mco_cont_num = user_input[1]
	centene_present = user_input[2]

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
		file = open("static/data/Medicaid_data_MCOs_Centene.csv", "r", encoding='utf-8-sig')
		data = list(csv.reader(file, delimiter=","))
		file.close()

		# display the number of items received
		print("Step #1: The count of the array is " + str(len(data)) + ".")

		# sql to create the table
		sql = '''CREATE TABLE medicaid_mcos (
			location TEXT,
			num_medicaid_mcos INT,
			centene_available TEXT
		)'''

		# results
		try:
			cursor.execute(sql)
			result = cursor.fetchall()
			print("Step #2: Table medicaid_mcos was successfully created.")
		except mysql.connector.Error as err:
			print("Here's the error: {}".format(err))
			exit()

		# inserting data into table
		row_counter = 0
		for i in range(1, len(data)):

			# get all information
			location = data[i][0]
			num_medicaid_mcos = int(data[i][1])
			centene_available = data[i][2]

			# peform the query
			sql = f'''INSERT INTO medicaid_mcos (location, num_medicaid_mcos, centene_available) VALUES ("{location}", "{num_medicaid_mcos}", "{centene_available}")'''
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

	# result function
	def show_result(result):
		for x in result: 
			print(x)

	# get data
	def get_data():

		# build sql query based on user inputs
		sql = 'SELECT * FROM medicaid_mcos '

		# if at least one doesn't equal all, we need to build the WHERE clause
		sql_tuple = ()
		if mco_contingent != "all":
			if mco_contingent == "greater than or equal to":
				mco_cont_sign = ">="
			elif mco_contingent == "equal to":
				mco_cont_sign = "="
			elif mco_contingent == "less than or equal to":
				mco_cont_sign = "<="
			sql = sql + f'WHERE num_medicaid_mcos {mco_cont_sign} %s '
			sql_tuple = (mco_cont_num, )
		if centene_present != "all":
			if centene_present == "yes":
				centene_present_sign = "TRUE"
			elif centene_present == "no":
				centene_present_sign = "FALSE"
			if mco_contingent != "all":
				sql = sql + f'AND centene_available = "{centene_present_sign}"'
			else:
				sql = sql + f'WHERE centene_available = "{centene_present_sign}"'
		
		# last part of sql
		#sql = sql + 'ORDER BY worldRank, year
		cursor.execute(sql, sql_tuple)
		result = cursor.fetchall()
		#print(sql, "\n", sql_tuple, "\n", result)
		#exit()

		# close connection
		conn.close()

		# create the html
		results_html = '''<tr>
					<th>Location</th>
					<th># MCOs</th>
					<th>Centene Present</th>
				</tr>
		'''
		for i in result:
			location = i[0]
			num_mcos = str(i[1])
			centene_pres = i[2]
			results_html = results_html + \
			f'''<tr>
				<td>{location}</td>
				<td>{num_mcos}</td>
				<td>{centene_pres}</td>
			</tr>'''

		# return the result
		return results_html

	# call function
	#data_insertion()
	data_to_return = get_data()

	# return the result
	return jsonify(data_to_return)
