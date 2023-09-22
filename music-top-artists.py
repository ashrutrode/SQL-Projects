# get artist(s) name
artist_input = request.get_json()

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
	file = open("static/data/charts-edited.csv", "r", encoding='utf-8-sig')
	data = list(csv.reader(file, delimiter=","))
	file.close()

	# display the number of items received
	print("Step #1: The count of the array is " + str(len(data)) + ".")

	# to reduce size, let's only save songs that have a rank of <= 10,
	# if their current rank equals their peak rank, and the most recent 
	# date of their highest rank; because the data are ordered from most 
	# recent, this time component shouldn't be difficult
	new_data = []
	discrete_songs = []
	for i in range(1, len(data)):
		rank = int(data[i][1])
		peak_rank = int(data[i][5])
		song_artist = [data[i][2], data[i][3]]
		if rank <= 10 and rank == peak_rank and song_artist not in discrete_songs:
			discrete_songs.append(song_artist)
			new_data.append(data[i])

	# display the reduced number of songs at their highest rank at the most recent date
	print("Step #2: The reduced number of artists-songs is " + str(len(new_data)) + ".")

	# sql to create the table
	sql = '''CREATE TABLE billboard_top_100 (
		date INT,
		rank INT,
		song TEXT,
		artist TEXT,
		last_week INT,
		peak_rank INT,
		weeks_on_board INT
	)'''

	# results
	try:
		cursor.execute(sql)
		result = cursor.fetchall()
		print("Step #3: Table billboard_top_100 was successfully created.")
	except mysql.connector.Error as err:
		print("Here's the error: {}".format(err))
		exit()

	# inserting new_data into table
	row_counter = 0
	for i in new_data:

		# get all information
		date = int(i[0].replace("-",""))
		rank = int(i[1])
		song = i[2]
		artist = i[3]
		if i[4] == "":
			i[4] = 0
		last_week = int(i[4])
		peak_rank = int(i[5])
		weeks_on_board = int(i[6])

		# peform the query
		sql = f'''INSERT INTO billboard_top_100 (date, rank, song, artist, last_week, peak_rank, weeks_on_board) 
				 VALUES ("{date}", "{rank}", "{song}", "{artist}", "{last_week}", "{peak_rank}", "{weeks_on_board}")'''
		cursor.execute(sql)
		result = conn.commit()

		# iterate the counter if successful
		if result == None:
			row_counter = row_counter + 1

	# show the results
	print("Step #4: " + str(row_counter) + " rows were inserted.")

	# close database and exit
	conn.close()
	exit()

# create dropdowns
def create_dropdowns():

	# select all artists and 
	# the number of times they appear
	sql = f'''SELECT artist, COUNT(artist)
		  FROM billboard_top_100
		  GROUP BY artist
		  ORDER BY COUNT(artist) DESC'''
	cursor.execute(sql)
	result = cursor.fetchall()

	# convert into html dropdown
	dropdown_html = f'<select name="artist" id="artist" class="dropdowns_world_universities"><option value="all">All Artists</option>'
	for i in result:

		# get artist name and number of hits
		artist_name = str(i[0])
		num_hits = i[1]

		# determine whether it was more than one hit
		songs_plural = ""
		if num_hits > 1:
			songs_plural = "s"
		num_hits = str(num_hits)

		# create html
		dropdown_html = dropdown_html + f'<option value="{artist_name}">' + artist_name + " - " + num_hits + " Hit Song" + songs_plural + "</option>"
	dropdown_html = dropdown_html + '</select>'

	# return the result
	print(dropdown_html)
	exit()

# get data
def get_data():

	# build sql query based on user inputs
	sql = 'SELECT * FROM billboard_top_100'

	# if at least one doesn't equal all, we need to build the WHERE clause
	if artist_input != "all":
		sql = sql + ' WHERE artist=%s'
	sql_tuple = (artist_input,)
	cursor.execute(sql, sql_tuple)
	result = cursor.fetchall()

	# close connection
	conn.close()

	# create the html
	results_html = '''<tr>
				<th>Date (MM-DD-YYYY)</th>
				<th>Rank</th>
				<th>Song</th>
				<th>Artist</th>
			</tr>
	'''
	for i in result:

		# get inputs
		date = str(i[0])
		rank = i[1]
		song = i[2]
		artist = i[3]

		# convert date
		year = date[:4]
		month = date[4:6]
		day = date[6:]
		date = month+"-"+day+"-"+year

		# create html
		results_html = results_html + \
						f'''<tr>
							<td>{date}</td>
							<td>{rank}</td>
							<td>{song}</td>
							<td>{artist}</td>
						</tr>'''

	# return the result
	return results_html

# call function
#data_insertion()
#create_dropdowns()
data_to_return = get_data()

# return the result
return jsonify(data_to_return)
